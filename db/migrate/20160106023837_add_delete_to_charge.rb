class AddDeleteToCharge < ActiveRecord::Migration
  def change
    add_column :charges, :deleted_at, :datetime, comment: '删除时间'
  end
end
