class AddFoundingStylistToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :founding_stylist, :boolean, default: false, null: false
  end
end
