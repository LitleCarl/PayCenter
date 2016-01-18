class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

  # 验证用户
  #before_filter :authentication_token_before_filter

  private

  #
  # 验证 user_session_key 必须传递且用户存在
  #
  # 需要验证 user_session_key 的接口必须使用的过滤器方法。如查看用户登录后去修改密码
  # 根据 user_session_key, timestamps, platform, salt来验证用户合法身份
  #
  # 初始化 current_user, 会直接返回异常.
  #
  # @param timestamps [String] Unix时间戳(毫秒)
  # @param user_session_key [String] 用户会话Key
  # @param platform [String] 客户端平台(ios/android)
  # @param salt [String] 客户端经过加密运算后得到的密钥
  #
  def authentication_token_before_filter
    response = Response.__rescue__ do |response|
      # TODO: 给开发留的后门 后续删除
      if params[:backdoor_customer_di].present?
        customer = Customer.query_first_by_id(params[:backdoor_user_di])

        response.__raise__(Response::Code::DATA_MISS_ERROR, '客户不存在') if customer.blank?
      else
        customer_key = params[:customer_key]

        response.__raise__(Response::Code::INVALID_USER_SESSION_KEY, '缺少参数') if customer_key.blank?

        live_mode = !customer_key.start_with?('sk_test_')
        if live_mode
          query = {live_key: customer_key}
        else
          query = {test_key: customer_key}
        end

        customer = Customer.query_first_by_options(query)

        response.__raise__(Response::Code::DATA_MISS_ERROR, '客户不存在') if customer.blank?

        params[:customers] = customer
        params[:customer_id] = customer.id
        # 标明使用环境
        params[:live_mode] = live_mode
      end


    end

    render json: response, status: 200 if response.code != Response::Code::SUCCESS
  end
end
