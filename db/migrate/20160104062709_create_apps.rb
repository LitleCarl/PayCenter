class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name, comment: '应用名称'
      t.boolean :live_mode, comment: '沙盒模式'
      t.string :code, comment: 'app编码'
      t.references :customers, comment: '关联客户'
      t.timestamps null: false
    end
  end
end
