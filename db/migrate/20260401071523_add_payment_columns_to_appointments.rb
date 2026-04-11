class AddPaymentColumnsToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :square_checkout_id, :string
    add_column :appointments, :balance_collected, :decimal,
               precision: 10, scale: 2
    add_index :appointments, :square_checkout_id
  end
end
