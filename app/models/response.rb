# encoding: UTF-8

class Response

  # 添加属性
  attr_accessor :code, :message, :messages

  #
  # 引入常量Gem中的响应编码
  #
  module Code
    # 添加模型常量国际化方法
    include Concerns::Dictionary::Module::I18n

    ################################################################################
    #
    # 20000 成功
    #
    ################################################################################

    SUCCESS = '20000'

    ################################################################################
    #
    # 3xxxx 数据相关
    #
    ################################################################################

    # 用户绑定第三方账户

    # 第三方账户已绑定其它用户
    PROVIDER_BIND_ANOTHER_USER = '30010'

    ################################################################################
    #
    # 4xxxx 业务相关
    #
    ################################################################################

    # 非法请求
    INVALID_REQUEST = '40300'

    # 终端密钥错误
    INVALID_TERMINAL_SESSION_KEY = '40301'

    # 用户密钥错误
    INVALID_USER_SESSION_KEY = '40302'

    # 超出请求限制数
    EXCEED_REQUEST_LIMIT = '40303'

    # 版本号不适配
    NOT_COMPATIBLE_REVISION = '40304'

    ################################################################################
    #
    # 5xxxx 系统相关
    #
    ################################################################################

    # 未知错误（通常在捕捉异常后使用）
    ERROR = '50000'

    # 请求参数缺失
    MISS_REQUEST_PARAMS = '50001'

    # 数据处理错误
    DATA_PROCESS_ERROR = '51000'

    # 数据缺失错误
    DATA_MISS_ERROR = '51001'

    ORDER_PAYMENT_COMPLETED = '55000'

    # 选项
    OPTIONS = get_all_options

    # 全部
    ALL = get_all_values
  end

  #
  # 实例对象
  #
  # @param code [Code] 编码
  # @param message [String] 返回信息
  # @param messages [Array] 可能的错误信息
  #
  # @return [Response] 返回实例化的对象
  #
  def initialize(code = Code::SUCCESS, message = '', messages = [])
    @code = code
    @message = message
    @messages = messages
  end

  #
  # 接口请求方法
  #
  # @example 订单确认收货
  #	 catch_proc = proc { xx = nil }
  #
  #  response = Response.__rescue__(catch_proc) do |res|
  #     order = Order.where(xxx: 'xxx').first
  #
  #     res.__raise__(Response::Code::ERROR, '订单未找到') if order.blank?
  #
  #     order.status = Order::Status::Completed
  #
  #     order.save!
  #  end
  #
  # @return [Response] 返回对象
  #
  def self.__rescue__(catch_proc = nil)
    response = self.new

    begin
      yield(response)
    rescue => e
      # 执行catch块
      catch_proc.call if catch_proc.present?

      # 如果是非开发者自己抛出的异常
      if response.code == Code::SUCCESS
        response.code = Code::ERROR
        response.message = e.message
        Rails.logger.debug do
          #puts e.backtrace
        end
        # yloge(e, e.message)
      else
        Rails.logger.info response.message
      end
    end

    response
  end

  #
  # 抛出异常
  #
  # @example
  #   Response.new.__raise__(Response::Code::ERROR, 'some error message')
  #
  # @param code [Code] 编码
  # @param message [String] 信息
  #
  def __raise__(code, message)
    @code = code
    @message = message

    raise StandardError, message
  end

  #
  # 如果参数中的response有异常则继续抛出异常
  #
  # @example
  #   Response.new.__raise__response__(response)
  #
  def __raise__response__(response)
    if response.code != Code::SUCCESS
      self.__raise__(response.code, response.message)
    end
  end

  #
  # 抛出 #Code::INVALID_USER_SESSION_KEY 异常
  #
  # @example
  #   Response.new.__raise__invalid_user_session_key('some error message')
  #
  def __raise__invalid_user_session_key(message)

  end

  #
  # 抛出 #Code::MISS_REQUEST_PARAMS 异常
  #
  # @example
  #   Response.new.__raise__miss_request_params('some error message')
  #
  def __raise__miss_request_params(message)
    # This is a stub, used for indexing
  end

  #
  # 抛出 #Code::DATA_MISS_ERROR 异常
  #
  # @example
  #   Response.new.__raise__data_miss_error('some error message')
  #
  def __raise__data_miss_error(message)
    # This is a stub, used for indexing
  end

  #
  # 抛出 #Code::DATA_PROCESS_ERROR 异常
  #
  # @example
  #   Response.new.__raise__data_process_error('some error message')
  #
  def __raise__data_process_error(message)
    # This is a stub, used for indexing
  end

  #
  # 抛出 #Code::ERROR 异常
  #
  # @example
  #   Response.new.__raise__error('some error message')
  #
  def __raise__error(message)
    # This is a stub, used for indexing
  end

  #
  # 动态定义抛异常实例方法
  #
  self.class_eval do
    Code::ALL.each do |code|
      unless code == 'success'
        define_method "__raise__#{code}" do |arg|
          __raise__(eval("Code::#{code.upcase}"), arg)
        end
      end
    end
  end

  #
  # 合并状态码
  #
  # @param status_one [Response] 状态1
  # @param status_two [Response] 状态2
  #
  def self.merge_status(status_one, status_two)
    response = status_one

    if status_one.code == Code::SUCCESS && status_two.code == Code::SUCCESS
      response.code = Response::Code::SUCCESS
    else
      response.code = status_two if status_two.code != Code::SUCCESS
      response.message = "#{status_one.message}, #{status_two.message}"
    end
    response
  end

end