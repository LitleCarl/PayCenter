# == Schema Information
#
# Table name: charges
#
#  id             :integer          not null, primary key
#  live_mode      :boolean          not null              # 沙盒模式
#  paid           :boolean          not null              # 已经支付
#  refunded       :boolean          not null              # 已经退款
#  app_id         :integer                                # 关联的应用
#  channel        :string(255)      not null              # 支付渠道
#  order_no       :string(255)                            # 客户订单号
#  amount         :integer                                # 订单金额
#  subject        :string(255)                            # 交易主题
#  body           :string(255)                            # 交易介绍
#  time_paid      :datetime                               # 支付时间
#  time_expired   :datetime                               # 失效时间
#  transaction_no :string(255)                            # 支付平台交易号
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  credential     :text(65535)                            # 支付渠道凭据
#  deleted_at     :datetime                               # 删除时间
#  batch_no       :string(255)                            # 支付宝用: 退款号
#

class Charge < ActiveRecord::Base

  acts_as_paranoid column: 'deleted_at', column_type: 'time'

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联应用
  belongs_to :app

  # 支付渠道
  module Channel
    include Concerns::Dictionary::Module::I18n

    # 支付宝
    ALIPAY = 'alipay'

    # 微信
    WX = 'wx'

    # 全部
    ALL = get_all_values
  end

  #
  # 申请支付信息并返回Charge对象
  #
  # @param options [Hash]
  # option options [Customer] :customers 客户
  # option options [Customer] :id 支付信息id
  #
  # @return [Response, Hash] 状态，支付凭证
  #
  def self.query_charge_with_options(options = {})
    charge = nil

    response = Response.__rescue__ do |res|
      id, customer = options[:id], options[:customers]

      res.__raise__miss_request_params('参数缺失') if customer.blank? || id.blank?

      charge = customer.charges.where(id: id).first

      res.__raise__data_miss_error('支付信息不存在') if charge.blank?
    end

    return response, charge

  end

  #
  # 申请支付信息并返回Charge对象
  #
  # @param options [Hash]
  # option options [Customer] :customers 客户
  # option options [String] :live_mode 使用环境(true表示正式,false表示测试)
  # option options [Customer] :app_code 应用code
  # option options [String] :subject 商品名称
  # option options [String] :body 商品描述
  # option options [String] :order_no 订单号
  # option options [String] :amount 总金额(单位为分)
  # option options [String] :client_ip 客户端ip
  # option options [String] :channel 支付渠道
  #
  # @return [Response, Hash] 状态，支付凭证
  #
  def self.create_with_options(options)
    charge = nil

    catch_proc = proc{ charge = nil }

    response = Response.__rescue__(catch_proc) do |res|
      customer, subject, body, order_no, amount, client_ip, channel, live_mode, app_code = options[:customers], options[:subject], options[:body], options[:order_no], options[:amount], options[:client_ip], options[:channel], options[:live_mode], options[:app_code]

      res.__raise__miss_request_params('参数缺失') if customer.blank? || subject.blank? || body.blank? || order_no.blank? || amount.blank? || client_ip.blank? || channel.blank? || live_mode.blank? || app_code.blank?

      res.__raise__data_process_error('非法的channel参数') unless Channel::ALL.include?(channel)

      transaction do
        app = customer.apps.where(code: app_code).first

        res.__raise__data_miss_error('APP未发现') if app.blank?

        # 是否是正式模式

        # 查找是否有过此订单号的charge,有则软删除
        charge = app.charges.where(order_no: order_no).first

        if charge.present?
          # 软删除
          charge.destroy
        end

        charge = Charge.new
        charge.live_mode = live_mode
        charge.app = app
        charge.channel = channel
        charge.order_no = order_no
        charge.amount = amount
        charge.body = body
        charge.subject = subject
        charge.paid = false
        charge.refunded = false

        charge.save!

        case channel
        when Channel::WX
          inner_response, wx_channel = customer.channel_by_options(app_code: app_code, channel: channel)

          res.__raise__response__(inner_response)

          res.__raise__data_miss_error('此客户没有开通微信支付渠道') if wx_channel.blank?

          pay_info = {
              id: wx_channel.id,
              body: body,
              order_no: order_no,
              total_fee: amount,
              client_ip: client_ip
          }

          inner_response, weixin_info = WxChannel.request_prepay(pay_info)

          res.__raise__response__ inner_response

          charge.credential = {wx: weixin_info}.to_json


          charge.save!
        when Channel::ALIPAY
          inner_response, alipay_channel = customer.channel_by_options(app_code: app_code, channel: channel)

          res.__raise__response__(inner_response)

           res.__raise__data_miss_error('此客户没有开通支付宝支付渠道') if alipay_channel.blank?

           pay_info = {
               id: alipay_channel.id,
               body: body,
               order_no: order_no,
               total_fee: amount,
               client_ip: client_ip,
               subject: subject
           }

          inner_response, alipay_info = AlipayChannel.request_prepay(pay_info)

           res.__raise__response__ inner_response

           charge.credential = {alipay: alipay_info}.to_json

           charge.save!
        end
      end

    end

    return response, charge
  end

  #
  # 申请退款
  #
  # @param options [Hash]
  # option options [Customer] :customer 客户
  # option options [String] :id Charge id
  # option options [String] :out_refund_no 商户退款号
  #
  # @return [Response, Hash] 状态，支付凭证
  #
  def self.refund_request(options = {})
    charge = nil

    catch_proc = proc{ charge = nil }

    response = Response.__rescue__(catch_proc) do |res|
      id, customer, out_refund_no = options[:id], options[:customer], options[:out_refund_no]

      res.__raise__miss_request_params('参数缺失') if id.blank? || customer.blank? || out_refund_no.blank?

      charge = Charge.query_first_by_id(id)

      res.__raise__data_miss_error('此charge不存在') if charge.blank?
      res.__raise__data_miss_error('此订单尚未付款') unless charge.paid
      res.__raise__data_miss_error('此订单已经退款') if charge.refunded

      case charge.channel
        # 微信退款
        when Channel::WX
          wx_channel = charge.app.try(:wx_channel)

          op_user_id = wx_channel.try(:refund_operator)
          client_certificate_secret = wx_channel.client_certificate_secret
          client_certificate = wx_channel.client_certificate

          res.__raise__miss_request_params('微信渠道未添加退款操作员,请完善信息') if op_user_id.blank?
          res.__raise__miss_request_params('微信渠道证书及私钥未提供,无法完成操作') if client_certificate.blank? || client_certificate_secret.blank?

          result = WxPay::Service.invoke_refund(transaction_id: charge.transaction_no, out_refund_no: out_refund_no,total_fee: charge.amount, refund_fee: charge.amount, op_user_id: op_user_id).deep_symbolize_keys

          if result[:result_code] == 'SUCCESS'
            charge.refunded = true
            charge.save!
          end
        # 支付宝退款
        when Channel::ALIPAY
          alipay_channel = charge.app.try(:alipay_channel)
          batch_no = Alipay::Utils.generate_batch_no

          result = Alipay::Service.refund_fastpay_by_platform_pwd_url(
              batch_no: batch_no,
              data: [{
                         trade_no: charge.transaction_no,
                         amount: charge.amount,
                         reason: '退款'
                     }],
              notify_url: 'http://pay.doteetv.com.cn/charges/alipay_notify.json'
          )

      end

    end
  end

  #
  # 支付宝退款请求异步通知
  #
  # @param options [Hash]
  # option options [String] :batch_no batch_no
  #
  # @return [Response, Charge] 状态，支付
  #
  def self.alipay_refund_async_notification(options = {})
    response = Response.__rescue__(catch_proc) do |res|
      batch_no = options[:batch_no]

      res.__raise__miss_request_params('参数缺失') if batch_no.blank?

      charge = Charge.query_first_by_options(batch_no: batch_no)

      res.__raise__data_miss_error('订单不存在') unless charge.paid

      chagre.refunded = true
      charge.save!
    end

    return response, charge
  end

end
