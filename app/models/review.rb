class Review < ApplicationRecord
  belongs_to :appointment
  belongs_to :customer, class_name: "User"
  belongs_to :stylist, class_name: "User"
  has_many_attached :photos
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 500 }
  validates :appointment_id, uniqueness: true

  validate :appointment_must_be_completed
  validate :customer_must_match_appointment
  validate :within_review_window, on: :create

  def editable?
    appointment&.completed_at.present? &&
      Time.current <= appointment.completed_at + 3.days
  end

  private

  def within_review_window
    return unless appointment&.completed_at
    if Time.current > appointment.completed_at + 3.days
      errors.add(:base, "Reviews can only be submitted within 3 days of appointment completion.")
    end
  end

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
