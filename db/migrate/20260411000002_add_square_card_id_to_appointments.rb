class AddSquareCardIdToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :square_card_id, :text
  end
end
