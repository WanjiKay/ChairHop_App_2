class ExpireAppointmentHoldsJob < ApplicationJob
  queue_as :default

  def perform
    expired = Appointment
      .where(status: :pending)
      .where("hold_expires_at IS NOT NULL AND hold_expires_at < ?", Time.current)

    count = expired.count
    expired.find_each(&:destroy)

    Rails.logger.info "ExpireAppointmentHoldsJob: destroyed #{count} expired hold(s)"
  end
end
