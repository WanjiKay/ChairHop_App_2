class AddPaymentTermsAcceptedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :payment_terms_accepted_at, :datetime
  end
end
