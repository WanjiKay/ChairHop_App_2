class AddIsAddOnToServices < ActiveRecord::Migration[7.1]
  def change
    add_column :services, :is_add_on, :boolean, default: false
  end
end
