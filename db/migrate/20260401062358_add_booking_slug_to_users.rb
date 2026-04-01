class AddBookingSlugToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :booking_slug, :string
    add_index :users, :booking_slug, unique: true
  end
end
