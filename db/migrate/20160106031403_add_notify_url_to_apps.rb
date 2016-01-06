class AddNotifyUrlToApps < ActiveRecord::Migration
  def change
    add_column :apps, :notify_url, :string, comment: '客户服务器异步通知地址'
  end
end
