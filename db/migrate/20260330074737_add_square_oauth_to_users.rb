class AddSquareOauthToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :square_access_token, :text
    add_column :users, :square_refresh_token, :text
    add_column :users, :square_merchant_id, :string
    add_column :users, :square_connected_at, :datetime

    add_index :users, :square_merchant_id
  end
end
