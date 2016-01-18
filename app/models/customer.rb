# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      not null               # 邮箱
#  test_key               :string(255)      not null               # 沙盒模式key
#  live_key               :string(255)      not null               # 正式环境key
#  company_name           :string(255)                             # 公司名
#  company_address        :string(255)                             # 公司地址
#  contact_name           :string(255)                             # 联系人
#  contact_phone          :string(255)                             # 联系电话
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#

class Customer < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联应用
  has_many :apps

  # 关联支付信息
  has_many :charges, through: :apps

  # 关联微信渠道
  has_many :wx_channels

  # 关联支付宝渠道
  has_many :alipay_channels

  #
  # 根据options获取当前客户下的指定渠道
  #
  # @param options [Hash]
  # option options [String] :app_code 应用code
  # option options [String] :channel 支付渠道
  #
  # @return [Response, WxChannel/AlipayChannel] 响应,渠道对象
  #
  def channel_by_options(options = {})
    channel = nil
    response = Response.__rescue__ do |res|
      app_code, channel = options[:app_code], options[:channel]

      res.__raise__miss_request_params('参数缺失') if app_code.blank? || channel.blank?

      if channel == Charge::Channel::ALIPAY
        channel = self.alipay_channels.joins(:app).where(apps: {code: app_code}).first

        res.__raise__data_miss_error('此app没有开通支付宝渠道') if channel.blank?
      elsif channel == Charge::Channel::WX
        channel = self.wx_channels.joins(:app).where(apps: {code: app_code}).first

        res.__raise__data_miss_error('此app没有开通微信渠道') if channel.blank?
      else
        res.__raise__data_miss_error('Channel参数错误') if channel.blank?
      end
    end

    return response, channel
  end

  #
  # 根据session_key查找客户
  #
  def self.query_first_by_user_session_key(options)
    Customer.joins(:authentication_tokens).where('authentication_tokens.auth_token = ? and authentication_tokens.expired_at > ?', options[:user_session_key], Time.now).first
  end

end
