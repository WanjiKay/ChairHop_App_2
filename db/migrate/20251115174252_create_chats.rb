class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.string :title
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :appointment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
