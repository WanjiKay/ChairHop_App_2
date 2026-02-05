class AddUniqueIndexToReviewsAppointmentId < ActiveRecord::Migration[7.1]
  def change
    remove_index :reviews, :appointment_id
    add_index :reviews, :appointment_id, unique: true
  end
end
