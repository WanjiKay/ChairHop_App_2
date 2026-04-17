class AddCityToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :city, :string
  end
end
