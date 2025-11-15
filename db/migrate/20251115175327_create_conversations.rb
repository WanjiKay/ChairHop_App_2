class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :stylist, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
