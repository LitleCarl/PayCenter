class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :channel, comment: '支付渠道'
      t.references :charge, comment: '关联支付'
      t.boolean :received, comment: '客服服务器已接收到通知'
      t.integer :send_time, comment: '当前向客户服务器发送通知次数'
      t.text :original_notification, comment: '微信服务器发来的原始通知内容'
      t.timestamps null: false
    end
  end
end
