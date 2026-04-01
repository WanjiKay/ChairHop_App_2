class Stylist::AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!
  before_action :ensure_profile_complete!, only: [:index, :accept]
  before_action :set_appointment, only: [:accept, :decline, :cancel, :complete, :send_payment_link]

  def index
    skip_authorization
    @appointments = current_user.appointments_as_stylist
                                .includes(:customer)
                                .order(time: :desc)
    @filter = params[:filter] || "all"

    case @filter
    when "requests"
      @appointments = @appointments.pending.where.not(customer_id: nil)
    when "available"
      @appointments = @appointments.pending.where(customer_id: nil)
    when "confirmed"
      @appointments = @appointments.booked
    when "past"
      @appointments = @appointments.where(status: [:completed, :cancelled])
    end
  end

  def new
    skip_authorization
    @appointment = Appointment.new
    @services = current_user.services.active
  end

  def create
    skip_authorization
    @appointment = Appointment.new(availability_params)
    @appointment.stylist = current_user
    @appointment.status = :pending

    if @appointment.save
      redirect_to stylist_appointments_path, notice: "Availability slot created."
    else
      @services = current_user.services.active
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    skip_authorization
    if @appointment.customer_id.blank?
      redirect_to stylist_appointments_path, alert: "No customer has requested this slot yet."
      return
    end

    if @appointment.accept!
      AppointmentMailer.booking_accepted(@appointment).deliver_later
      redirect_to stylist_appointments_path, notice: "Booking accepted!"
    else
      redirect_to stylist_appointments_path, alert: "Failed to accept booking."
    end
  end

  def decline
    skip_authorization
    if @appointment.customer_id.blank?
      redirect_to stylist_appointments_path, alert: "No customer to decline."
      return
    end

    # Capture customer before update clears customer_id
    customer = @appointment.customer
    had_payment = @appointment.payment_id.present?

    @appointment.update(
      customer_id:    nil,
      status:         :pending,
      selected_service: nil,
      payment_status: nil
    )

    # Send emails using captured customer (not @appointment.customer
    # which is now nil after update)
    if customer.present?
      AppointmentMailer.booking_declined(@appointment, customer: customer).deliver_later
      AppointmentMailer.deposit_refunded(@appointment, customer: customer).deliver_later if had_payment
    end

    redirect_to stylist_appointments_path, notice: "Booking declined."
  end

  def cancel
    skip_authorization
    # Empty slot — just remove it entirely
    if @appointment.customer_id.blank?
      @appointment.destroy
      redirect_to stylist_appointments_path, notice: "Availability slot removed."
      return
    end

    cancellation_reason = params[:cancellation_reason]
    refund_result = nil

    # Always refund the customer if a deposit was collected
    if @appointment.payment_id.present? && @appointment.payment_status == 'deposit_paid'
      refund_result = PaymentService.new(current_user).refund_deposit(@appointment)

      if refund_result[:success]
        @appointment.payment_status = 'refunded'
      else
        redirect_to stylist_appointments_path,
          alert: "Cancellation failed: refund could not be processed. Please contact support."
        return
      end
    end

    @appointment.assign_attributes(
      status: :cancelled,
      cancelled_by: 'stylist',
      cancelled_at: Time.current,
      cancellation_reason: cancellation_reason.presence
    )

    if @appointment.save
      AppointmentMailer.cancellation_notice(
        @appointment,
        cancelled_by: 'stylist',
        refund_issued: refund_result&.dig(:success)
      ).deliver_later

      notice_msg = if refund_result&.dig(:success)
        "Appointment cancelled. The customer's deposit has been refunded."
      else
        "Appointment cancelled."
      end
      redirect_to stylist_appointments_path, notice: notice_msg
    else
      redirect_to stylist_appointments_path,
        alert: "Could not cancel appointment. Please try again."
    end
  end

  def send_payment_link
    skip_authorization
    unless @appointment.booked?
      redirect_to stylist_appointments_path,
        alert: "Only booked appointments can have a payment link sent."
      return
    end

    payment_service = PaymentService.new(current_user)
    result = payment_service.create_payment_link(@appointment)

    if result[:success]
      @appointment.update!(
        square_checkout_id: result[:checkout_id],
        payment_status: 'link_sent'
      )
      AppointmentMailer.payment_link(
        @appointment, result[:payment_url]
      ).deliver_later
      redirect_to stylist_appointments_path,
        notice: "Payment link sent to #{@appointment.customer&.name}."
    else
      redirect_to stylist_appointments_path,
        alert: "Could not create payment link: #{result[:error]}"
    end
  end

  def complete
    skip_authorization
    unless @appointment.booked?
      redirect_to stylist_appointments_path, alert: "Only booked appointments can be completed."
      return
    end

    # If a deposit was already charged, attempt to collect the remaining 50% balance.
    # If no payment on record (legacy/test appointments) skip straight to completing.
    if @appointment.payment_id.present? && @appointment.payment_amount.present?
      payment_nonce = params[:payment_nonce]

      if payment_nonce.present?
        # Nonce supplied (e.g. stylist collected card in-person or via future UI)
        payment_service = PaymentService.new(current_user)
        result = payment_service.charge_balance(@appointment, payment_nonce)

        if result[:success]
          @appointment.assign_attributes(
            status:             :completed,
            balance_payment_id: result[:payment_id],
            payment_status:     'paid'
          )

          @appointment.completed_at = Time.current
          if @appointment.save
            AppointmentMailer.appointment_completed(@appointment).deliver_later
            AppointmentMailer.balance_payment_received(@appointment).deliver_later
            AppointmentMailer.review_request(@appointment).deliver_later
            Rails.logger.info "Appointment ##{@appointment.id} completed. Balance charged: $#{sprintf('%.2f', result[:amount_charged])}"
            redirect_to stylist_appointments_path, notice: "Appointment completed! Balance of $#{sprintf('%.2f', result[:amount_charged])} collected."
          else
            Rails.logger.error "BALANCE CAPTURED but save failed! Payment ID: #{result[:payment_id]}, Appointment: #{@appointment.id}"
            redirect_to stylist_appointments_path,
                        alert: "Balance collected but status could not be saved. Contact support: #{result[:payment_id]}"
          end
        else
          AppointmentMailer.balance_payment_failed(@appointment).deliver_later
          redirect_to stylist_appointments_path,
                      alert: "Payment failed: #{result[:error]}. The customer has been notified."
        end
      else
        # No nonce — stylist chose one of two in-person completion modes.
        if params[:balance_waived] == '1'
          @appointment.update(status: :completed, completed_at: Time.current, payment_status: 'balance_waived')
          AppointmentMailer.appointment_completed(@appointment).deliver_later
          AppointmentMailer.review_request(@appointment).deliver_later
          redirect_to stylist_appointments_path,
                      notice: "Appointment marked as complete. Balance recorded as outstanding."
        else
          # Collected in person (cash, Square app, etc.)
          @appointment.update(
            status: :completed,
            completed_at: Time.current,
            payment_status: 'collected_in_person',
            balance_collected: params[:balance_collected].present? ?
              params[:balance_collected].to_f : nil
          )
          AppointmentMailer.appointment_completed(@appointment).deliver_later
          AppointmentMailer.balance_collected_notification(@appointment).deliver_later
          AppointmentMailer.review_request(@appointment).deliver_later
          collected_msg = @appointment.balance_collected.present? ?
            "$#{sprintf('%.2f', @appointment.balance_collected)} collected in person." :
            "Balance recorded as collected in person."
          redirect_to stylist_appointments_path,
                      notice: "Appointment marked as complete. #{collected_msg}"
        end
      end
    else
      # No deposit on file — complete without payment processing
      @appointment.update(status: :completed, completed_at: Time.current, payment_status: 'paid')
      AppointmentMailer.appointment_completed(@appointment).deliver_later
      AppointmentMailer.review_request(@appointment).deliver_later
      redirect_to stylist_appointments_path, notice: "Appointment marked as completed!"
    end
  end

  private

  def set_appointment
    @appointment = current_user.appointments_as_stylist.find(params[:id])
  end

  def availability_params
    params.require(:appointment).permit(:time, :location_id, :salon, :content)
  end

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied" unless current_user.stylist?
  end

  def ensure_profile_complete!
    unless current_user.can_accept_bookings?
      if !current_user.onboarding_complete?
        redirect_to step1_stylist_onboarding_path,
                    alert: "Please complete your profile before accepting bookings."
      elsif !current_user.square_connected?
        redirect_to stylist_dashboard_path,
                    alert: "Please connect your Square account before accepting bookings."
      end
    end
  end
end
