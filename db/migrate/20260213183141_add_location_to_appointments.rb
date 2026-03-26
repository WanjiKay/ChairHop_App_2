class AddLocationToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_reference :appointments, :location, foreign_key: true, null: true
  end
end
