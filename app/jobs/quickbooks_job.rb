class QuickbooksJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find(appointment_id)
    return unless appointment.stylist.quickbooks_connected?

    qb_service = QuickbooksService.new(appointment.stylist)

    # Create invoice
    invoice_id = qb_service.create_invoice(appointment)

    # If there's a payment, record it
    if invoice_id && appointment.payment_intent_id.present?
      total = appointment.total_price
      qb_service.record_payment(appointment, total, 'Square')
    end

    Rails.logger.info "QuickBooks sync completed for appointment #{appointment_id}"
  rescue => e
    Rails.logger.error "QuickBooks sync failed: #{e.message}"
  end
end
