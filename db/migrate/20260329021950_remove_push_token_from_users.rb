class RemovePushTokenFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :push_token, :string
  end
end
