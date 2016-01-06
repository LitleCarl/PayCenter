# == Schema Information
#
# Table name: authentication_tokens # 认证令牌
#
#  id            :integer          not null, primary key # 认证令牌
#  auth_token    :string(255)                            # 令牌内容
#  expired_at    :datetime                               # 过期时间
#  resource_id   :integer                                # 多态关联
#  resource_type :string(255)                            # 多态关联
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class AuthenticationToken < ActiveRecord::Base

  # 通用查询方法
  include Concerns::Query::Methods

  # 多态关联
  belongs_to :resource, polymorphic: true
end
