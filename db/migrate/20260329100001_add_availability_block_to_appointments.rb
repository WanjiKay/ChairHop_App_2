class AddAvailabilityBlockToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_reference :appointments, :availability_block, foreign_key: true, null: true
    add_index :appointments, [:availability_block_id, :time]
  end
end
