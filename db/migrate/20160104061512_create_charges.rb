class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.boolean :live_mode, null: false, comment: '沙盒模式'
      t.boolean :paid, null: false, comment: '已经支付'
      t.boolean :refunded, null: false, comment: '已经退款'
      t.references :app, comment: '关联的应用'
      t.string :channel, null: false, comment: '支付渠道'
      t.string :order_no, comment: '客户订单号'
      t.integer :amount, comment: '订单金额'
      t.string :subject, comment: '交易主题'
      t.string :body, comment: '交易介绍'
      t.datetime :time_paid, comment: '支付时间'
      t.datetime :time_expired, comment: '失效时间'
      t.string :transaction_no, comment: '支付平台交易号'

      t.timestamps null: false
    end
  end
end
