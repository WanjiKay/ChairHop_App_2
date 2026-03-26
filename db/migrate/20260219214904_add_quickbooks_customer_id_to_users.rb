class AddQuickbooksCustomerIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :quickbooks_customer_id, :string
    add_index :users, :quickbooks_customer_id
  end
end
