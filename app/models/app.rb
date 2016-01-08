# == Schema Information
#
# Table name: apps
#
#  id          :integer          not null, primary key
#  name        :string(255)                            # 应用名称
#  code        :string(255)                            # app编码
#  customer_id :integer                                # 关联客户
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  notify_url  :string(255)                            # 客户服务器异步通知地址
#

class App < ActiveRecord::Base

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联客户
  belongs_to :customer

  # 关联支付
  has_many :charges
end
