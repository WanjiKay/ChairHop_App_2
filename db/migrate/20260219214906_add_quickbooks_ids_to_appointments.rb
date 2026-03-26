class AddQuickbooksIdsToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :quickbooks_invoice_id, :string
    add_column :appointments, :quickbooks_payment_id, :string
    add_index :appointments, :quickbooks_invoice_id
  end
end
