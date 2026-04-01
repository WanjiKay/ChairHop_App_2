class CreateAvailabilityBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :availability_blocks do |t|
      t.references :stylist, null: false, foreign_key: { to_table: :users }
      t.references :location, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.boolean :available_for_all_services, default: true
      t.text :service_ids, array: true, default: []
      t.text :notes

      t.timestamps
    end

    add_index :availability_blocks, :start_time
    add_index :availability_blocks, :end_time
    add_index :availability_blocks, [:stylist_id, :start_time]
  end
end
