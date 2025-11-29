class CreateAppointmentAddOns < ActiveRecord::Migration[7.1]
  def change
    create_table :appointment_add_ons do |t|
      t.references :appointment, null: false, foreign_key: true
      t.string :service_name
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
