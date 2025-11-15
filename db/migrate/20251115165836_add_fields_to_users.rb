class AddFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string
    add_column :users, :username, :string
    add_column :users, :location, :string
    add_column :users, :about, :text
  end
end
