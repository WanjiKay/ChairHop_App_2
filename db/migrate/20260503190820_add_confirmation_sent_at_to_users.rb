class AddConfirmationSentAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :confirmation_sent_at, :datetime
  end
end
