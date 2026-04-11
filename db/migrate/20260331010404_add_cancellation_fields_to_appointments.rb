class AddCancellationFieldsToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :cancellation_reason, :text
    add_column :appointments, :cancelled_by, :string
    add_column :appointments, :cancelled_at, :datetime
  end
end
