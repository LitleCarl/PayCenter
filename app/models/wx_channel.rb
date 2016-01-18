# == Schema Information
#
# Table name: wx_channels
#
#  id                        :integer          not null, primary key
#  wx_app_id                 :string(255)                            # 微信App id
#  wx_app_secret             :string(255)                            # 微信App Secret
#  parter_id                 :string(255)                            # 商户id
#  pay_secret                :text(65535)                            # 商户支付密钥
#  refund_operator           :string(255)                            # 商户添加的退款操作员 ID
#  client_certificate        :text(65535)                            # 微信客户端证书
#  client_certificate_secret :text(65535)                            # 微信客户端证书密钥
#  customer_id               :integer                                # 所属客户
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  app_id                    :integer                                # 关联应用
#

class WxChannel < ActiveRecord::Base

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联客户
  belongs_to :customer

  # 关联应用
  belongs_to :app

  #
  # 请求微信服务器获取支付凭证
  #
  # @param options [Hash]
  # option options [String] :id 渠道id
  # option options [String] :body 商品描述
  # option options [String] :order_no 订单号
  # option options [String] :total_fee 总金额(单位为分)
  # option options [String] :client_ip 客户端ip
  #
  # @return [Response, Hash] 状态，微信支付凭证
  #
  def self.request_prepay(options = {})
    result = nil

    catch_proc = proc{ result = nil }

    response = Response.__rescue__(catch_proc) do |res|
      id =  options[:id]
      body, order_no, total_fee, client_ip = options[:body], options[:order_no], options[:total_fee], options[:client_ip]
      res.__raise__miss_request_params('参数错误') if id.blank? || body.blank? || order_no.blank? || total_fee.blank? || client_ip.blank?

      wx = query_first_by_id(id)

      RequestStore.store[:wx] = wx

      res.__raise__data_miss_error('渠道信息不存在') if wx.blank?

      nonce_str = SecureRandom.uuid.tr('-', '')

      # 发起支付请求的参数
      params = {
          body: body,
          out_trade_no: order_no,
          total_fee: total_fee,
          spbill_create_ip: client_ip,
          notify_url: 'http://pay.doteetv.com.cn/charges/wx_notify.json',#TODO 回调地址需更新
          trade_type: 'APP',
          nonce_str: nonce_str
      }
      result = WxPay::Service.invoke_unifiedorder(params).deep_symbolize_keys
      # => {
      #      "return_code"=>"SUCCESS",
      #      "return_msg"=>"OK",
      #      "appid"=>"YOUR APPID",
      #      "mch_id"=>"YOUR MCH_ID",
      #      "nonce_str"=>"8RN7YfTZ3OUgWX5e",
      #      "sign"=>"623AE90C9679729DDD7407DC7A1151B2",
      #      "result_code"=>"SUCCESS",
      #      "prepay_id"=>"wx2014111104255143b7605afb0314593866",
      #      "trade_type"=>"APP"
      #    }

      puts "微信支付返回结果1#{result}"


      # 重新签名结果
      result = WxPay::Service::generate_app_pay_req({
                                                        noncestr: nonce_str,
                                                        prepayid: result[:prepay_id]
                                                    }).deep_symbolize_keys
      puts "微信支付返回结果2#{result}"

      # => {
      #      appid: 'wxd930ea5d5a258f4f',
      #      partnerid: '1900000109',
      #      prepayid: '1101000000140415649af9fc314aa427',
      #      package: 'Sign=WXPay',
      #      noncestr: '1101000000140429eb40476f8896f4c9',
      #      timestamp: '1398746574',
      #      sign: '7FFECB600D7157C5AA49810D2D8F28BC2811827B'
      #    }

    end

    return response, result
  end

end
