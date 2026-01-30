class AppointmentAddOn < ApplicationRecord
  belongs_to :appointment
  belongs_to :service, optional: true

  # Validate that either service_id OR service_name+price are present
  validate :service_or_legacy_fields_present

  # Get price from Service if available, otherwise use legacy price field
  def final_price
    if service.present?
      service.price
    else
      price
    end
  end

  # Get name from Service if available, otherwise use legacy service_name field
  def final_name
    if service.present?
      service.name
    else
      service_name
    end
  end

  private

  def service_or_legacy_fields_present
    if service_id.blank? && (service_name.blank? || price.blank?)
      errors.add(:base, "Must either reference a Service or provide service_name and price")
    end
  end
end
