# TODO: Remove BYPASS_SQUARE_PAYMENTS before production!
# This bypass is ONLY for development testing while Square Sandbox is configured.
# To enable: export BYPASS_SQUARE_PAYMENTS=true in terminal before starting Rails

# TODO: Platform fees (app_fee_money) require Square Platform approval.
# Apply at: https://developer.squareup.com/docs/platform/overview
# Disabled for now to allow testing — re-enable after approval.
class PaymentService
  PLATFORM_FEE_RATE = 0.035 # 3.5% platform fee on total (reserved for when Platform is approved)

  # Development bypass for testing without Square Sandbox
  def self.bypass_payments?
    Rails.env.development? && ENV['BYPASS_SQUARE_PAYMENTS'] == 'true'
  end

  def initialize(stylist)
    @stylist = stylist

    unless @stylist.square_connected? || PaymentService.bypass_payments?
      raise "Stylist must have Square account connected"
    end

    return if PaymentService.bypass_payments?

    # Create a per-stylist Square client using their OAuth access token.
    # square_merchant_id is used as location_id — replace with a dedicated
    # square_location_id column once fetched from the Locations API.
    @client = Square::Client.new(
      token:    @stylist.square_access_token,
      base_url: ENV['SQUARE_ENVIRONMENT'] == 'production' ?
                  Square::Environment::PRODUCTION :
                  Square::Environment::SANDBOX
    )
  end

  # Charge 50% deposit with platform fee applied to the total.
  # v45 gem raises Square::ApiException on any API error — no .success? needed.
  def charge_deposit(appointment, payment_nonce)
    # DEVELOPMENT BYPASS: Skip Square API in development
    if PaymentService.bypass_payments?
      Rails.logger.info "⚠️  DEVELOPMENT MODE: Bypassing Square deposit charge"
      payment_amount = appointment.payment_amount.to_f
      return {
        success:        true,
        payment_id:     "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
        amount_charged: (payment_amount * 0.5).round(2),
        platform_fee:   0
      }
    end

    # Original Square API logic continues below...
    total_cents   = total_amount_cents(appointment)
    deposit_cents = (total_cents * 0.5).to_i
    fee_cents     = (total_cents * PLATFORM_FEE_RATE).to_i

    Rails.logger.info "Charging deposit: #{deposit_cents} cents, platform fee: #{fee_cents} cents"

    begin
      result = @client.payments.create(
        source_id:       payment_nonce,
        idempotency_key: SecureRandom.uuid,
        amount_money:    { amount: deposit_cents, currency: 'USD' },
        # app_fee_money: { amount: fee_cents, currency: 'USD' }, # Requires Square Platform approval
        autocomplete:    true,
        location_id:     @stylist.square_location_id,
        note:            "Deposit for appointment ##{appointment.id}"
      )

      payment = result.payment
      {
        success:        true,
        payment_id:     payment.id,
        amount_charged: deposit_cents / 100.0,
        platform_fee:   0,
        status:         payment.status
      }
    rescue => e
      Rails.logger.error "Deposit charge failed: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      { success: false, error: "Payment processing error: #{e.message}" }
    end
  end

  # Charge remaining 50% balance when appointment is completed.
  def charge_balance(appointment, payment_nonce)
    # DEVELOPMENT BYPASS: Skip Square API in development
    if PaymentService.bypass_payments?
      Rails.logger.info "⚠️  DEVELOPMENT MODE: Bypassing Square balance charge"
      balance_amount = (appointment.payment_amount.to_f * 100 * 0.5).round
      return {
        success:        true,
        payment_id:     "DEV_BALANCE_#{SecureRandom.hex(8)}",
        amount_charged: balance_amount,
        platform_fee:   0
      }
    end

    # Original Square API logic continues below...
    total_cents   = total_amount_cents(appointment)
    balance_cents = (total_cents * 0.5).to_i
    fee_cents     = (total_cents * PLATFORM_FEE_RATE).to_i

    Rails.logger.info "Charging balance: #{balance_cents} cents, platform fee: #{fee_cents} cents"

    begin
      result = @client.payments.create(
        source_id:       payment_nonce,
        idempotency_key: SecureRandom.uuid,
        amount_money:    { amount: balance_cents, currency: 'USD' },
        # app_fee_money: { amount: fee_cents, currency: 'USD' }, # Requires Square Platform approval
        autocomplete:    true,
        location_id:     @stylist.square_location_id,
        note:            "Balance payment for appointment ##{appointment.id}"
      )

      payment = result.payment
      {
        success:        true,
        payment_id:     payment.id,
        amount_charged: balance_cents / 100.0,
        platform_fee:   0,
        status:         payment.status
      }
    rescue => e
      Rails.logger.error "Balance charge failed: #{e.class}: #{e.message}"
      { success: false, error: "Payment processing error: #{e.message}" }
    end
  end

  # Create a Square payment link for the remaining 50% balance.
  def create_payment_link(appointment)
    if PaymentService.bypass_payments?
      Rails.logger.info "⚠️  DEV MODE: Bypassing Square payment link creation"
      fake_checkout_id = "DEV_CHECKOUT_#{SecureRandom.hex(8)}"
      fake_url = "https://squareup.com/pay/DEV_#{SecureRandom.hex(4)}"
      return {
        success:     true,
        checkout_id: fake_checkout_id,
        payment_url: fake_url
      }
    end

    total_cents   = total_amount_cents(appointment)
    balance_cents = (total_cents * 0.5).to_i

    begin
      result = @client.checkout.create_payment_link(
        body: {
          idempotency_key: SecureRandom.uuid,
          order: {
            location_id: @stylist.square_location_id,
            line_items: [
              {
                name:     "Balance: #{appointment.selected_service&.split(' - $')&.first || 'Appointment'}",
                quantity: "1",
                base_price_money: {
                  amount:   balance_cents,
                  currency: "USD"
                }
              }
            ]
          },
          checkout_options: {
            redirect_url: Rails.application.routes.url_helpers
              .appointment_url(appointment, host: ENV.fetch('APP_HOST', 'localhost:3000'))
          },
          pre_populated_data: {
            buyer_email: appointment.customer&.email
          },
          description: "Remaining balance for appointment ##{appointment.id} with #{@stylist.name}"
        }
      )

      link = result.payment_link
      {
        success:     true,
        checkout_id: link.id,
        payment_url: link.url
      }
    rescue => e
      Rails.logger.error "Payment link creation failed: #{e.class}: #{e.message}"
      { success: false, error: "Could not create payment link: #{e.message}" }
    end
  end

  # Refund deposit when cancelled 24+ hours before appointment.
  def refund_deposit(appointment)
    # DEVELOPMENT BYPASS: Skip Square API in development
    if PaymentService.bypass_payments?
      Rails.logger.info "⚠️  DEVELOPMENT MODE: Bypassing Square refund"
      return {
        success:         true,
        refund_id:       "DEV_REFUND_#{SecureRandom.hex(8)}",
        amount_refunded: (appointment.payment_amount.to_f * 0.5).round(2)
      }
    end

    # Original Square API logic continues below...
    unless appointment.payment_id.present?
      return { success: false, error: "No payment to refund" }
    end

    hours_until = (appointment.time - Time.current) / 1.hour
    unless hours_until >= 24
      return {
        success: false,
        error:   "Cannot refund — cancellation must be 24+ hours before appointment"
      }
    end

    total_cents   = total_amount_cents(appointment)
    deposit_cents = (total_cents * 0.5).to_i

    begin
      result = @client.refunds.refund_payment(
        payment_id:      appointment.payment_id,
        idempotency_key: SecureRandom.uuid,
        amount_money:    { amount: deposit_cents, currency: 'USD' }
      )

      refund = result.refund
      {
        success:         true,
        refund_id:       refund.id,
        amount_refunded: deposit_cents / 100.0,
        status:          refund.status
      }
    rescue => e
      Rails.logger.error "Refund failed: #{e.class}: #{e.message}"
      { success: false, error: "Refund processing error: #{e.message}" }
    end
  end

  private

  # Derives total amount in cents. Falls back to deposit_amount * 2
  # if payment_amount wasn't explicitly set on the appointment.
  def total_amount_cents(appointment)
    if appointment.payment_amount.present?
      (appointment.payment_amount * 100).to_i
    elsif appointment.payment_amount_before_type_cast.present?
      (appointment.payment_amount_before_type_cast.to_f * 100).to_i
    else
      raise "Appointment ##{appointment.id} has no payment_amount set"
    end
  end
end
