# == Schema Information
#
# Table name: alipay_channels
#
#  id                :integer          not null, primary key
#  pid               :string(255)                            # PID
#  alipay_account    :string(255)                            # 支付宝账号
#  alipay_verify_key :string(255)                            # 支付宝安全校验码（Key）
#  public_key        :text(65535)                            # 支付宝公钥
#  rsa_key           :text(65535)                            # 商户RSA私钥
#  customer_id       :integer                                # 所属客户
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AlipayChannel < ActiveRecord::Base

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联客户
  belongs_to :customer

  #
  # 请求支付宝服务器获取支付凭证
  #
  # @param options [Hash]
  # option options [String] :id 渠道id
  # option options [String] :subject 商品名称
  # option options [String] :body 商品描述
  # option options [String] :order_no 订单号
  # option options [String] :total_fee 总金额(单位为分)
  # option options [String] :client_ip 客户端ip
  #
  # @return [Response, Hash] 状态，支付宝支付凭证
  #
  def self.request_prepay(options = {})
    result = nil

    catch_proc = proc{ result = nil }

    response = Response.__rescue__(catch_proc) do |res|
      id =  options[:id]
      subject, body, order_no, total_fee, client_ip = options[:subject], options[:body], options[:order_no], options[:total_fee], options[:client_ip]
      res.__raise__miss_request_params('参数错误') if id.blank? || subject.blank? || body.blank? || order_no.blank? || total_fee.blank? || client_ip.blank?

      alipay = query_first_by_id(id)

      RequestStore.store[:alipay] = alipay

      res.__raise__data_miss_error('渠道信息不存在') if alipay.blank?

      # 发起支付请求的参数
      params = {
          body: body,
          out_trade_no: order_no,
          total_fee: total_fee,
          notify_url: 'http://making.dev/notify',#TODO 回调地址需更新
          subject: subject
      }

      pid_key = {
          pid: alipay.pid,
          key: alipay.rsa_key
      }
      result = Alipay::Mobile::Service.mobile_securitypay_pay_string params, pid_key

    end

    return response, result
  end

end
