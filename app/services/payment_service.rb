class PaymentService
  PLATFORM_FEE_RATE    = 0.045 # 4.5% per payment (deposit + balance), totalling 4.5% of full appointment
  CANADIAN_PROVINCES   = %w[AB BC MB NB NL NS NT NU ON PE QC SK YT].freeze

  def initialize(stylist)
    @stylist = stylist

    unless @stylist.square_connected?
      raise "Stylist must have Square account connected"
    end

    @client = Square::Client.new(
      token:    @stylist.square_access_token,
      base_url: ENV['SQUARE_ENVIRONMENT'] == 'production' ?
                  Square::Environment::PRODUCTION :
                  Square::Environment::SANDBOX
    )
  end

  # Find or create a Square Customer in this stylist's account for the given client.
  # Looks up by (user, stylist) pair in user_square_customers.
  # Returns the Square customer_id string. Raises on unrecoverable failure.
  def create_or_find_customer(user)
    existing = UserSquareCustomer.find_by(user: user, stylist: @stylist)
    return existing.square_customer_id if existing

    result = @client.customers.create(
      idempotency_key: "customer-#{@stylist.id}-#{user.id}",
      given_name:      user.first_name,
      family_name:     user.last_name,
      email_address:   user.email,
      reference_id:    user.id.to_s
    )

    customer_id = result.customer.id
    UserSquareCustomer.create!(user: user, stylist: @stylist, square_customer_id: customer_id)
    customer_id
  rescue => e
    Rails.logger.error "create_or_find_customer failed for user #{user.id}, stylist #{@stylist.id}: #{e.class}: #{e.message}"
    raise "Could not create Square customer: #{e.message}"
  end

  # Vault a payment nonce as a Card on File in the stylist's Square account.
  # Returns { success: true, card_id: "ccof_..." } or { success: false, error: "..." }.
  def create_card(user, payment_nonce, appointment)
    customer_record = UserSquareCustomer.find_by(user: user, stylist: @stylist)
    raise "No Square customer record for user #{user.id} / stylist #{@stylist.id} — call create_or_find_customer first" unless customer_record

    result = @client.cards.create(
      idempotency_key: "card-#{appointment.id}",
      source_id:       payment_nonce,
      card: {
        customer_id: customer_record.square_customer_id
      }
    )

    { success: true, card_id: result.card.id }
  rescue => e
    Rails.logger.error "create_card failed for user #{user.id}, appointment #{appointment.id}: #{e.class}: #{e.message}"
    { success: false, error: "Could not save card: #{e.message}" }
  end

  # Deactivate a stored card. Best-effort cleanup when deposit charge fails
  # after card creation but before appointment save.
  def disable_card(card_id)
    return if card_id.blank?

    @client.cards.disable(card_id: card_id)
  rescue => e
    Rails.logger.error "disable_card best-effort failed for #{card_id}: #{e.class}: #{e.message}"
    # Do not re-raise — cleanup failure should not surface to user
  end

  # Charge 50% deposit with platform fee applied to the total.
  # v45 gem raises Square::ApiException on any API error — no .success? needed.
  def charge_deposit(appointment, card_id, customer_id)
    total_cents   = total_amount_cents(appointment)
    deposit_cents = (total_cents * 0.5).to_i
    fee_cents     = @stylist.founding_stylist? ? 0 : (deposit_cents * PLATFORM_FEE_RATE).to_i

    Rails.logger.info "Charging deposit: #{deposit_cents} cents, platform fee: #{fee_cents} cents"

    begin
      result = @client.payments.create(
        source_id:       card_id,
        idempotency_key: "deposit-#{appointment.id}",
        amount_money:    { amount: deposit_cents, currency: currency_for(appointment) },
        app_fee_money:   { amount: fee_cents,   currency: currency_for(appointment) },
        autocomplete:    true,
        customer_id:     customer_id,
        location_id:     @stylist.square_location_id,
        note:            "Deposit for appointment ##{appointment.id}"
      )

      payment = result.payment
      {
        success:        true,
        payment_id:     payment.id,
        amount_charged: deposit_cents / 100.0,
        platform_fee:   fee_cents / 100.0,
        status:         payment.status
      }
    rescue => e
      Rails.logger.error "Deposit charge failed: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      { success: false, error: "Payment processing error: #{e.message}" }
    end
  end

  # Charge remaining 50% balance when appointment is completed.
  # Card and customer IDs are read from the appointment and its customer record.
  def charge_balance(appointment)
    card_id = appointment.square_card_id
    unless card_id.present?
      return { success: false, error: "No vaulted card on file for appointment ##{appointment.id}" }
    end

    customer_record = UserSquareCustomer.find_by(user: appointment.customer, stylist: @stylist)
    customer_id = customer_record&.square_customer_id

    total_cents   = total_amount_cents(appointment)
    balance_cents = (total_cents * 0.5).to_i
    fee_cents     = @stylist.founding_stylist? ? 0 : (balance_cents * PLATFORM_FEE_RATE).to_i

    Rails.logger.info "Charging balance: #{balance_cents} cents, platform fee: #{fee_cents} cents"

    begin
      result = @client.payments.create(
        source_id:       card_id,
        idempotency_key: "completion-#{appointment.id}",
        amount_money:    { amount: balance_cents, currency: currency_for(appointment) },
        app_fee_money:   { amount: fee_cents,    currency: currency_for(appointment) },
        autocomplete:    true,
        customer_id:     customer_id,
        location_id:     @stylist.square_location_id,
        note:            "Balance payment for appointment ##{appointment.id}"
      )

      payment = result.payment
      {
        success:        true,
        payment_id:     payment.id,
        amount_charged: balance_cents / 100.0,
        platform_fee:   fee_cents / 100.0,
        status:         payment.status
      }
    rescue => e
      Rails.logger.error "Balance charge failed: #{e.class}: #{e.message}"
      { success: false, error: "Payment processing error: #{e.message}" }
    end
  end

  # Create a Square payment link for the remaining 50% balance.
  def create_payment_link(appointment)
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
                  currency: currency_for(appointment)
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
        amount_money:    { amount: deposit_cents, currency: currency_for(appointment) }
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

  def currency_for(appointment)
    CANADIAN_PROVINCES.include?(appointment.location&.state&.upcase) ? 'CAD' : 'USD'
  end

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
