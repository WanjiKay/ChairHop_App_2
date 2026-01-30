class AddServiceToAppointmentAddOns < ActiveRecord::Migration[7.1]
  def change
    # Make service_id nullable for backward compatibility with existing add-ons
    # that use service_name and price directly
    add_reference :appointment_add_ons, :service, null: true, foreign_key: true
  end
end
