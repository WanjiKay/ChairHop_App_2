class ChangeCustomerIdToOptionalInAppointments < ActiveRecord::Migration[7.1]
  def change
    change_column_null :appointments, :customer_id, true
  end
end
