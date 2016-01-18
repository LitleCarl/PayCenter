class AddBatchNoToCharge < ActiveRecord::Migration
  def change
    add_column :charges, :batch_no, :string, comment: '支付宝用: 退款号'
  end
end
