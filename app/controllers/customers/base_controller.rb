class Customers::BaseController < ActionController::Base

  before_action :authenticate_customer!

  private

  # # 验证用户有效性
  # def authentication_customer
  #   response = Response.__rescue__ do |response|
  #
  #   end
  #
  # end

end
