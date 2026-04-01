class Webhooks::SquareController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_after_action :verify_authorized

  WEBHOOK_SIGNATURE_KEY = ENV.fetch('SQUARE_WEBHOOK_SIGNATURE_KEY', '')

  def receive
    payload = request.body.read
    signature = request.headers['X-Square-Hmacsha256-Signature']

    unless valid_signature?(payload, signature)
      Rails.logger.warn "Square webhook: invalid signature"
      head :unauthorized
      return
    end

    event = JSON.parse(payload)
    event_type = event.dig('type')

    case event_type
    when 'payment.updated'
      handle_payment_updated(event)
    else
      Rails.logger.info "Square webhook: unhandled event type #{event_type}"
    end

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error "Square webhook JSON parse error: #{e.message}"
    head :bad_request
  end

  private

  def handle_payment_updated(event)
    # Extract checkout/order ID from the payment event
    payment_data = event.dig('data', 'object', 'payment')
    return unless payment_data

    # Only process payments that have reached COMPLETED status
    return unless payment_data['status'] == 'COMPLETED'

    order_id = payment_data['order_id']
    amount_cents = payment_data.dig('amount_money', 'amount').to_i

    # Find appointment by square_checkout_id
    # Square payment links create an order — we find by order_id
    # which is stored as square_checkout_id
    appointment = Appointment.find_by(square_checkout_id: order_id)

    unless appointment
      Rails.logger.warn "Square webhook: no appointment for order_id #{order_id}"
      return
    end

    return if appointment.completed?

    appointment.update!(
      status: :completed,
      completed_at: Time.current,
      balance_payment_id: payment_data['id'],
      balance_collected: amount_cents / 100.0,
      payment_status: 'paid'
    )

    AppointmentMailer.appointment_completed(appointment).deliver_later
    AppointmentMailer.balance_payment_received(appointment).deliver_later
    AppointmentMailer.review_request(appointment).deliver_later

    Rails.logger.info "Square webhook: appointment ##{appointment.id} completed via payment link"
  end

  def valid_signature?(payload, signature)
    return true if WEBHOOK_SIGNATURE_KEY.blank? # skip in dev/test
    expected = Base64.strict_encode64(
      OpenSSL::HMAC.digest('SHA256', WEBHOOK_SIGNATURE_KEY, payload)
    )
    ActiveSupport::SecurityUtils.secure_compare(expected, signature.to_s)
  end
end
