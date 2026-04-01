class MakeServicesNameUniquePerStylist < ActiveRecord::Migration[7.1]
  def change
    remove_index :services, [:stylist_id, :name], if_exists: true
    add_index :services, [:stylist_id, :name], unique: true
  end
end
