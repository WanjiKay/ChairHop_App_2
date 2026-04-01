class AvailabilityBlock < ApplicationRecord
  belongs_to :stylist, class_name: 'User'
  belongs_to :location
  has_many :appointments, dependent: :nullify

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_blocks

  scope :active, -> { where('end_time > ?', Time.current) }
  scope :for_date, ->(date) { where('DATE(start_time) = ?', date) }

  # Get all services available in this block
  def available_services
    if available_for_all_services?
      stylist.services.active
    else
      stylist.services.active.where(id: service_ids)
    end
  end

  # Calculate available time slots for a specific service
  def available_slots_for(service)
    return [] unless can_accommodate?(service)

    duration = service.duration_minutes || 60
    slots = []
    current_slot = start_time

    while current_slot + duration.minutes <= end_time
      slots << current_slot if slot_available?(current_slot, duration)
      current_slot += 15.minutes
    end

    slots
  end

  # Check if service can fit in this block
  def can_accommodate?(service)
    return false unless available_services.include?(service)
    duration = service.duration_minutes || 60
    (end_time - start_time) >= duration.minutes
  end

  # Check if a specific time slot is available (no overlapping appointments)
  def slot_available?(slot_time, duration_minutes)
    slot_end = slot_time + duration_minutes.minutes

    !appointments.where(
      '(time >= ? AND time < ?) OR (time < ? AND time + INTERVAL \'1 minute\' * ? > ?)',
      slot_time, slot_end,
      slot_time, duration_minutes, slot_time
    ).exists?
  end

  # Get all booked appointments in this block
  def booked_appointments
    appointments.where('time >= ? AND time < ?', start_time, end_time).order(:time)
  end

  # Human-readable time range
  def time_range
    "#{start_time.strftime('%-l:%M %p')} - #{end_time.strftime('%-l:%M %p')}"
  end

  # Date for grouping
  def date
    start_time.to_date
  end

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_overlapping_blocks
    return if start_time.blank? || end_time.blank?

    overlapping = AvailabilityBlock
      .where(stylist: stylist)
      .where.not(id: id)
      .where('start_time < ? AND end_time > ?', end_time, start_time)

    errors.add(:base, "This time block overlaps with an existing availability block") if overlapping.exists?
  end
end
