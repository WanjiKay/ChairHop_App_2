class AddSelectedServiceToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :selected_service, :string
  end
end
