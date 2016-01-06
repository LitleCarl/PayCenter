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
    WEIXIN = 'wx'

    # 全部
    ALL = get_all_values
  end

  #
  # 申请支付信息并返回Charge对象
  #
  # @param options [Hash]
  # option options [Customer] :customer 客户
  # option options [Customer] :app_id 应用id
  # option options [String] :subject 商品名称
  # option options [String] :body 商品描述
  # option options [String] :customer_key 客户key
  # option options [String] :order_no 订单号
  # option options [String] :amount 总金额(单位为分)
  # option options [String] :client_ip 客户端ip
  # option options [String] :channel 支付渠道
  #
  # @return [Response, Hash] 状态，微信支付凭证
  #
  def self.create_with_options(options)
    charge = nil

    catch_proc = proc{ charge = nil }

    response = Response.__rescue__(catch_proc) do |res|
      customer, subject, body, order_no, amount, client_ip, channel, customer_key, app_id = options[:customer], options[:subject], options[:body], options[:order_no], options[:amount], options[:client_ip], options[:channel], options[:customer_key], options[:app_id]

      res.__raise__miss_request_params('参数缺失') if customer.blank? || subject.blank? || body.blank? || order_no.blank? || amount.blank? || client_ip.blank? || channel.blank? || customer_key.blank? || app_id.blank?

      res.__raise__data_process_error('非法的channel参数') unless Channel::ALL.include?(channel)

      transaction do
        app = customer.apps.where(id: app_id).first

        res.__raise__data_miss_error('APP未发现') if app.blank?

        # 是否是正式模式
        live_mode = (customer.live_key == customer_key)

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

        charge.save!

        case channel
        when Chanel::WEIXIN
          wx_channel = customer.wx_channel

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
        when Chanel::ALIPAY
           alipay_channel = customer.alipay_channel

           res.__raise__data_miss_error('此客户没有开通支付宝支付渠道') if alipay_channel.blank?

           pay_info = {
               id: wx_channel.id,
               body: body,
               order_no: order_no,
               total_fee: amount,
               client_ip: client_ip,
               subject: subject
           }
           inner_response, alipay_info = AlipayChannel.request_prepay(pay_info)

           res.__raise__response__ inner_response

           charge.credential = {alipay: alipay_info}.to_json
        end
      end

    end

    return response, charge
  end
end
