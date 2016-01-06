class CreateAlipayChannels < ActiveRecord::Migration
  def change
    create_table :alipay_channels do |t|
      t.string :pid, comment: 'PID'
      t.string :alipay_account, comment: '支付宝账号'
      t.string :alipay_verify_key, comment: '支付宝安全校验码（Key）'
      t.text :public_key, comment: '支付宝公钥'
      t.text :rsa_key, comment: '商户RSA私钥'
      t.references :customer, comment: '所属客户'
      t.timestamps null: false
    end
  end
end
