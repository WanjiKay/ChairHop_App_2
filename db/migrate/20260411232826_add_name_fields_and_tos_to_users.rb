class AddNameFieldsAndTosToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string, null: false, default: ''
    add_column :users, :last_name, :string, null: false, default: ''
    add_column :users, :tos_accepted_at, :datetime, null: true
  end
end
