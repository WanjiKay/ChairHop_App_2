class AddSquareLocationIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :square_location_id, :string
    add_index  :users, :square_location_id
  end
end
