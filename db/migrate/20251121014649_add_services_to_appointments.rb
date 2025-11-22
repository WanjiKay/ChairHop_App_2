class AddServicesToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :services, :text
  end
end
