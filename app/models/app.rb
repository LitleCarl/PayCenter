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
#

class App < ActiveRecord::Base

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联客户
  belongs_to :customer

end
