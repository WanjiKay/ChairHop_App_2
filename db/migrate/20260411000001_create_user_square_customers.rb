class CreateUserSquareCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :user_square_customers do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :stylist, null: false, foreign_key: { to_table: :users }
      t.text       :square_customer_id   # text — AR Encryption ciphertext needs room

      t.timestamps
    end

    add_index :user_square_customers, [:user_id, :stylist_id], unique: true
  end
end
