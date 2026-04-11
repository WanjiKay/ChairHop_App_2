class AppointmentMailer < ApplicationMailer

  # Already built — customer or stylist cancels
  def cancellation_notice(appointment, cancelled_by:, refund_issued: false)
    @appointment = appointment
    @cancelled_by = cancelled_by
    @refund_issued = refund_issued

    if cancelled_by == "customer"
      @recipient = appointment.stylist
      @recipient_role = "stylist"
    else
      @recipient = appointment.customer
      @recipient_role = "customer"
    end

    mail(
      to: @recipient.email,
      subject: "Appointment Cancelled — #{format_datetime(@appointment.time)}"
    )
  end

  # Customer books → notify stylist of new request
  def new_booking_request(appointment)
    @appointment = appointment
    @stylist = appointment.stylist
    @customer = appointment.customer

    mail(
      to: @stylist.email,
      subject: "New Booking Request from #{@customer.name}"
    )
  end

  # Customer books → confirm to customer their request was sent
  def booking_request_confirmation(appointment)
    @appointment = appointment
    @stylist = appointment.stylist
    @customer = appointment.customer

    mail(
      to: @customer.email,
      subject: "Booking Request Sent — #{format_datetime(@appointment.time)}"
    )
  end

  # Stylist accepts → notify customer
  def booking_accepted(appointment)
    @appointment = appointment
    @stylist = appointment.stylist
    @customer = appointment.customer

    mail(
      to: @customer.email,
      subject: "Booking Confirmed! — #{format_datetime(@appointment.time)}"
    )
  end

  # Stylist declines → notify customer
  def booking_declined(appointment, customer: nil)
    @appointment = appointment
    @stylist = appointment.stylist
    @customer = customer || appointment.customer

    return if @customer.nil?

    mail(
      to: @customer.email,
      subject: "Booking Update — #{format_datetime(@appointment.time)}"
    )
  end

  # Appointment completed → receipt to customer
  def appointment_completed(appointment)
    @appointment        = appointment
    @stylist            = appointment.stylist
    @customer           = appointment.customer
    @deposit_paid       = (appointment.payment_amount.to_f * 0.5).round(2)
    @balance_paid       = @deposit_paid
    @balance_payment_id = appointment.balance_payment_id

    mail(
      to: @customer.email,
      subject: "Your Appointment is Complete — Thank You!"
    )
  end

  # Appointment completed → prompt customer to leave a review
  def review_request(appointment)
    @appointment = appointment
    @customer = appointment.customer
    @stylist = appointment.stylist

    return if @customer.nil?

    mail(
      to: @customer.email,
      subject: "How was your appointment with #{@stylist.name}? Leave a review"
    )
  end

  # Deposit refunded → notify customer
  def deposit_refunded(appointment, customer: nil)
    @appointment = appointment
    @customer = customer || appointment.customer
    @refund_amount = (appointment.payment_amount.to_f * 0.5).round(2)

    return if @customer.nil?

    mail(
      to: @customer.email,
      subject: "Refund Processed — $#{'%.2f' % @refund_amount}"
    )
  end

  # Send payment link to customer for remaining balance
  def payment_link(appointment, payment_url)
    @appointment  = appointment
    @customer     = appointment.customer
    @stylist      = appointment.stylist
    @payment_url  = payment_url
    @amount       = appointment.payment_amount.to_f * 0.5
    mail(
      to: @customer.email,
      subject: "Action required: Pay your remaining balance for your appointment with #{@stylist.name}"
    )
  end

  # Appointment complete with balance collected in person → notify stylist
  def balance_collected_notification(appointment)
    @appointment      = appointment
    @stylist          = appointment.stylist
    @customer         = appointment.customer
    @amount_collected = appointment.balance_collected
    mail(
      to: @stylist.email,
      subject: "Appointment complete — balance recorded for #{@customer&.name}"
    )
  end

  # Stylist responded to a review → notify customer
  def review_response_notification(review)
    @review      = review
    @customer    = review.customer
    @stylist     = review.stylist
    @appointment = review.appointment
    mail(
      to: @customer.email,
      subject: "#{@stylist.name} responded to your review"
    )
  end

  # Balance charged via nonce on completion → notify stylist
  def balance_payment_received(appointment)
    @appointment = appointment
    @stylist     = appointment.stylist
    @customer    = appointment.customer
    mail(
      to: @stylist.email,
      subject: "Balance payment received — #{@customer&.name}"
    )
  end

  # Balance charged on completion → receipt to customer
  def balance_receipt(appointment)
    @appointment        = appointment
    @stylist            = appointment.stylist
    @customer           = appointment.customer
    @selected_service   = appointment.selected_service&.split(' - $')&.first
    @balance_paid       = (appointment.payment_amount.to_f * 0.5).round(2)
    @balance_payment_id = appointment.balance_payment_id

    mail(
      to: @customer.email,
      subject: "Balance Receipt — Booking ##{appointment.id.to_s.rjust(6, '0')}"
    )
  end

  # Balance charge failed on completion → notify customer
  def balance_payment_failed(appointment)
    @appointment = appointment
    @customer    = appointment.customer
    @stylist     = appointment.stylist
    mail(
      to: @customer.email,
      subject: "Action required: Payment issue with your appointment"
    )
  end

end
