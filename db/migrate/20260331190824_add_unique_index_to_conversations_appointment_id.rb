class AddUniqueIndexToConversationsAppointmentId < ActiveRecord::Migration[7.1]
  def change
    remove_index :conversations, :appointment_id, if_exists: true
    add_index :conversations, :appointment_id, unique: true
  end
end
