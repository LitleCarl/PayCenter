class Customers::SessionsController < Customers::BaseController
  skip_before_action :authenticate_customer!, only: [:new]
  def new

  end
end
