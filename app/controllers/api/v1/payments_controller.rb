class Api::V1::PaymentsController < Api::V1::BaseController
  def create_payment
    appointment = Appointment.find(params[:appointment_id])

    unless appointment.customer_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    # Use price_cents from the service record, fall back to parsing selected_service string
    service = appointment.stylist.services.find_by(name: appointment.selected_service&.split(" - $")&.first)
    amount_cents = service&.price_cents || (appointment.base_service_price * 100).to_i

    if amount_cents <= 0
      render json: { error: 'Invalid amount' }, status: :unprocessable_entity
      return
    end

    begin
      result = SQUARE_CLIENT.payments.create(
        source_id: params[:source_id],
        idempotency_key: SecureRandom.uuid,
        amount_money: {
          amount: amount_cents,
          currency: 'USD'
        },
        autocomplete: true,
        location_id: ENV['SQUARE_LOCATION_ID'],
        note: "Appointment ##{appointment.id} - #{appointment.selected_service}"
      )

      payment = result.payment

      appointment.update!(
        payment_amount: amount_cents / 100.0,
        payment_status: 'paid',
        payment_id: payment.id,
        payment_method: payment.card_details&.card&.last_4,
        status: :booked
      )

      render json: {
        message: 'Payment successful',
        payment_id: payment.id,
        appointment: appointment.as_json(only: [:id, :status, :payment_status, :payment_amount, :payment_method])
      }, status: :ok
    rescue Square::Errors::ResponseError => e
      Rails.logger.error "Square payment error: #{e.message}"
      render json: { error: 'Payment failed', details: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Payment error: #{e.message}"
      render json: { error: 'Payment processing failed', details: e.message }, status: :unprocessable_entity
    end
  end

  def payment_status
    appointment = Appointment.find(params[:appointment_id])

    unless appointment.customer_id == current_user.id || appointment.stylist_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    render json: {
      payment_status: appointment.payment_status,
      payment_amount: appointment.payment_amount,
      payment_method: appointment.payment_method
    }
  end

  def refund_payment
    appointment = Appointment.find(params[:appointment_id])

    unless appointment.customer_id == current_user.id || appointment.stylist_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :forbidden
      return
    end

    unless appointment.payment_id.present?
      render json: { error: 'No payment to refund' }, status: :unprocessable_entity
      return
    end

    begin
      result = SQUARE_CLIENT.refunds.refund_payment(
        idempotency_key: SecureRandom.uuid,
        payment_id: appointment.payment_id,
        amount_money: {
          amount: (appointment.payment_amount * 100).to_i,
          currency: 'USD'
        },
        reason: 'Appointment cancelled'
      )

      appointment.update!(payment_status: 'refunded')

      render json: {
        message: 'Refund successful',
        refund_id: result.refund.id
      }, status: :ok
    rescue Square::Errors::ResponseError => e
      Rails.logger.error "Square refund error: #{e.message}"
      render json: { error: 'Refund failed', details: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Refund error: #{e.message}"
      render json: { error: 'Refund processing failed', details: e.message }, status: :unprocessable_entity
    end
  end
end
