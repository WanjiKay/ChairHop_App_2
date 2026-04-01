class Appointment < ApplicationRecord
  belongs_to :customer, class_name: "User", optional: true
  belongs_to :stylist, class_name: "User"
  belongs_to :location, optional: true
  belongs_to :cancelled_by_user, class_name: "User", foreign_key: :cancelled_by_id, optional: true
  belongs_to :availability_block, optional: true
  has_many :chats, dependent: :nullify
  has_one :conversation, dependent: :nullify
  has_one :review, dependent: :destroy
  has_many :appointment_add_ons, dependent: :destroy
  has_one_attached :image
  has_neighbors :embedding
  after_create :set_embedding
  before_save :set_end_time
  validates :time, presence: true
  validate :no_overlapping_appointments, on: [:create, :update]
  validates :location_id, presence: true, on: :create
  validates :payment_status, inclusion: { in: %w[pending deposit_paid balance_due paid refunded deposit_kept failed] }, allow_nil: true

  enum status: {
    pending: 0,
    booked: 1,
    completed: 2,
    cancelled: 3
  }


  def total_add_ons_price
    appointment_add_ons.sum(:price)
  end

  def total_duration_minutes
    total = 0

    if selected_service.present?
      service_name = selected_service.split(' - $').first
      service = stylist.services.find_by(name: service_name)
      total += service.duration_minutes.to_i if service
    end

    appointment_add_ons.each do |add_on|
      total += add_on.service.duration_minutes.to_i if add_on.service
    end

    total
  end

  def formatted_duration
    mins = total_duration_minutes
    hours   = mins / 60
    minutes = mins % 60

    if hours > 0 && minutes > 0
      "#{hours}h #{minutes}m"
    elsif hours > 0
      "#{hours}h"
    else
      "#{minutes}m"
    end
  end

  def base_service_price
    selected_service ? selected_service.split(" - $").last.to_f : 0
  end

  def total_price
    base_service_price + total_add_ons_price
  end

  def accept!
    return false unless pending?
    self.status = :booked
    save
  end

  def cancel!(cancelled_by: nil)
    self.status = :cancelled
    self.cancelled_by_user = cancelled_by if cancelled_by
    self.customer = nil
    save
  end

  CANCELLATION_WINDOW_HOURS = 24

  def cancellable_by_customer?
    (pending? || booked?) && !completed? && !cancelled?
  end

  def full_refund_eligible?
    time > CANCELLATION_WINDOW_HOURS.hours.from_now
  end

  def hours_until_appointment
    ((time - Time.current) / 1.hour).round(1)
  end

  def location_display
    if location.present?
      location.full_address
    else
      "Location not specified"
    end
  end

  def calculated_end_time
    return nil unless time.present?
    duration = total_duration_minutes
    duration = 60 if duration == 0
    time + duration.minutes
  end

  private

  def set_end_time
    self.end_time = calculated_end_time if time.present?
  end

  def no_overlapping_appointments
    return unless time.present? && stylist_id.present? && selected_service.present?

    duration = total_duration_minutes
    duration = 60 if duration == 0
    appt_end = time + duration.minutes

    conflicts = Appointment
      .where(stylist_id: stylist_id)
      .where(status: [:pending, :booked])
      .where.not(id: id)
      .where(
        '(appointments.time < ? AND appointments.end_time > ?) OR
         (appointments.time >= ? AND appointments.time < ?)',
        appt_end, time,
        time, appt_end
      )

    if conflicts.exists?
      conflict = conflicts.first
      errors.add(:time,
        "conflicts with an existing appointment at #{conflict.time.strftime('%b %-d at %-I:%M %p')}. " \
        "Please choose a different time.")
    end
  end

  def set_embedding
    embedding = RubyLLM.embed("Time: #{time}. Location: #{location_display}. Stylist: #{stylist.name}.")
    update(embedding: embedding.vectors)
  rescue => e
    # Silently skip embedding if API is not configured or rate limit is hit
    Rails.logger.warn "Skipping embedding for appointment #{id}: #{e.message}"
  end

end
