class CreateWxChannels < ActiveRecord::Migration
  def change
    create_table :wx_channels do |t|
      t.string :wx_app_id, comment: '微信App id'
      t.string :wx_app_secret, comment: '微信App Secret'
      t.string :parter_id, comment: '商户id'
      t.text :pay_secret, comment: '商户支付密钥'
      t.string :refund_operator, comment: '商户添加的退款操作员 ID'
      t.text :client_certificate, comment: '微信客户端证书'
      t.text :client_certificate_secret, comment: '微信客户端证书密钥'
      t.references :customers, comment: '所属客户'
      t.timestamps null: false
    end
  end
end
