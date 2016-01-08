class AddAppIdToChannels < ActiveRecord::Migration
  def change
    add_column :wx_channels, :app_id, :integer, comment: '关联应用'
    add_column :alipay_channels, :app_id, :integer, comment: '关联应用'
  end
end
