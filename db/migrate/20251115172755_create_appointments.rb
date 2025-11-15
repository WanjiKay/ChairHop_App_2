class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.datetime :time
      t.string :location
      t.boolean :booked
      t.text :content
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :stylist, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
