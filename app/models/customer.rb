# == Schema Information
#
# Table name: customers
#
#  id              :integer          not null, primary key
#  email           :string(255)      not null              # 邮箱
#  test_key        :string(255)      not null              # 沙盒模式key
#  live_key        :string(255)      not null              # 正式环境key
#  company_name    :string(255)                            # 公司名
#  company_address :string(255)                            # 公司地址
#  contact_name    :string(255)                            # 联系人
#  contact_phone   :string(255)                            # 联系电话
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Customer < ActiveRecord::Base

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联应用
  has_many :apps

  # 关联支付信息
  has_many :charges, through: :apps

  # 关联微信渠道
  has_one :wx_channel

  #
  # 根据session_key查找客户
  #
  def self.query_first_by_user_session_key(options)
    Customer.joins(:authentication_tokens).where('authentication_tokens.auth_token = ? and authentication_tokens.expired_at > ?', options[:user_session_key], Time.now).first
  end

end
