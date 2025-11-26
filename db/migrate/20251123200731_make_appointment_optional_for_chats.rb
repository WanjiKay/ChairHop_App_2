class MakeAppointmentOptionalForChats < ActiveRecord::Migration[7.1]
  def change
    change_column_null :chats, :appointment_id, true
  end
end
