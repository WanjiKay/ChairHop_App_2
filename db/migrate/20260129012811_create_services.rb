class CreateServices < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.references :stylist, null: false, foreign_key: { to_table: :users }
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :services, [:stylist_id, :name]
  end
end
