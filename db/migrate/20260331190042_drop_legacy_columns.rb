class DropLegacyColumns < ActiveRecord::Migration[7.1]
  def change
    remove_column :appointments, :location, :text
    remove_column :appointments, :services, :text
    remove_column :appointments, :booked, :boolean
    remove_column :users, :location, :string
    remove_column :users, :latitude, :decimal
    remove_column :users, :longitude, :decimal
    remove_column :appointments, :quickbooks_invoice_id, :string
    remove_column :appointments, :quickbooks_payment_id, :string
    remove_column :users, :quickbooks_customer_id, :string
  end
end
