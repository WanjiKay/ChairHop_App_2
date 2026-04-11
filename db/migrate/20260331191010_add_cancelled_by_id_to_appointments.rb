class AddCancelledByIdToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :cancelled_by_id, :integer
    add_index :appointments, :cancelled_by_id
    add_foreign_key :appointments, :users, column: :cancelled_by_id
  end
end
