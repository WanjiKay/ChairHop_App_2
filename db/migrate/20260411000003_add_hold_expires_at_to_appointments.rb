class AddHoldExpiresAtToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :hold_expires_at, :datetime
  end
end
