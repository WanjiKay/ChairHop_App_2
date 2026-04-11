class AddCompletedAtToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :completed_at, :datetime
  end
end
