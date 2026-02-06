class AddPaymentFieldsToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :payment_amount, :decimal, precision: 10, scale: 2
    add_column :appointments, :payment_status, :string, default: 'pending'
    add_column :appointments, :payment_id, :string
    add_column :appointments, :payment_method, :string
  end
end
