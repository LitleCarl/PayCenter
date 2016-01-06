class CreateAuthenticationTokens < ActiveRecord::Migration

  def change
    create_table :authentication_tokens, comment: '认证令牌' do |t|
      t.string :auth_token, index: true, comment: '令牌内容'
      t.datetime :expired_at, comment: '过期时间'

      t.belongs_to :resource, polymorphic: true, index: true, comment: '多态关联'

      t.timestamps null: false
    end
  end

end