# encoding: UTF-8

class ChargesController < ApplicationController

  # 创建支付请求
  def create
    @response, @charge = Charge.create_with_options(params)
  end

  # 查询支付请求
  def show
    @response, @charge = Charge.query_charge_with_options(params)
  end

  # 微信服务器异步通知
  def wx_notify
    result = Hash.from_xml(request.body.read)['xml'].deep_symbolize_keys

    if WxPay::Sign.verify?(result)

      Notification.create_or_update_by_wx(result)

      render :xml => {return_code: 'SUCCESS'}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: 'FAIL', return_msg: '签名失败'}.to_xml(root: 'xml', dasherize: false)
    end
  end

  # 微信服务器异步通知
  def alipay_notify
    response = Notification.create_or_update_by_alipay(params)
    if response.code != Response::Code::SUCCESS
      render :text => response.message
    else
      render :text => 'success'
    end
  end

end
