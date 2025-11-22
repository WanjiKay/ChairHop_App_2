class AddSalonToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :salon, :string
  end
end
