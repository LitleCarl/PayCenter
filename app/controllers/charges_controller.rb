# encoding: UTF-8

class ChargesController < ApplicationController

  # 创建支付请求
  def create
    @response, @charge = Charge.create_with_options(params)
  end



end
