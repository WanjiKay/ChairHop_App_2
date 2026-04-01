class AddEndTimeToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :end_time, :datetime
  end
end
