class Review < ApplicationRecord
  belongs_to :appointment
  belongs_to :customer, class_name: "User"
  belongs_to :stylist, class_name: "User"
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 500 }
  validates :appointment_id, uniqueness: true

  validate :appointment_must_be_completed
  validate :customer_must_match_appointment

  private

  def appointment_must_be_completed
    if appointment && !appointment.completed?
      errors.add(:appointment, 'must be completed before reviewing')
    end
  end

  def customer_must_match_appointment
    if appointment && customer_id != appointment.customer_id
      errors.add(:customer, 'must be the one who booked the appointment')
    end
  end
end
