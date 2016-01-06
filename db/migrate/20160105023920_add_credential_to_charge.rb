class AddCredentialToCharge < ActiveRecord::Migration
  def change
    add_column :charges, :credential, :text, comment: '支付渠道凭据'
    remove_column :apps, :live_mode
  end
end
