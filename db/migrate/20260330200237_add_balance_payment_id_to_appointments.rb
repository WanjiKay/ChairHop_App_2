class AddBalancePaymentIdToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :balance_payment_id, :string
  end
end
