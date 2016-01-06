class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :email, null: false, unique: true, comment: '邮箱'
      t.string :test_key, null: false, comment: '沙盒模式key'
      t.string :live_key, null: false, comment: '正式环境key'
      t.string :company_name, comment: '公司名'
      t.string :company_address, comment: '公司地址'
      t.string :contact_name, comment: '联系人'
      t.string :contact_phone, comment: '联系电话'
      t.timestamps null: false
    end
  end
end
