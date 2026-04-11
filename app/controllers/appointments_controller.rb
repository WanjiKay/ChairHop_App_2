class AppointmentsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_appointment, only: [:show, :review, :confirmation, :balance_receipt, :invoice, :book, :booked, :destroy, :complete, :cancel]

  def index
    authorize Appointment

    @availability_blocks = AvailabilityBlock
      .includes(:location, stylist: :services)
      .joins(:stylist)
      .where('availability_blocks.end_time > ?', Time.current)
      .where(users: { role: :stylist })
      .order('availability_blocks.start_time ASC')

    # Full-text / name search — matches stylist name, about bio, service names, or location names
    if params[:query].present?
      query_term = "%#{params[:query].downcase}%"
      @availability_blocks = @availability_blocks.where(
        "LOWER(users.name) ILIKE :q OR LOWER(users.about) ILIKE :q OR " \
        "EXISTS (SELECT 1 FROM services s2 WHERE s2.stylist_id = users.id AND LOWER(s2.name) ILIKE :q) OR " \
        "EXISTS (SELECT 1 FROM locations l2 WHERE l2.user_id = users.id AND " \
        "(LOWER(l2.city) ILIKE :q OR LOWER(l2.name) ILIKE :q))",
        q: query_term
      )
    end

    # Service filter
    if filter_params[:service].present?
      service_term = "%#{filter_params[:service].downcase}%"
      @availability_blocks = @availability_blocks
        .joins("INNER JOIN services ON services.stylist_id = users.id")
        .where("LOWER(services.name) LIKE ?", service_term)
        .where(
          "availability_blocks.available_for_all_services = true OR " \
          "services.id::text = ANY(availability_blocks.service_ids)"
        )
    end

    # Date filter
    if filter_params[:date].present?
      begin
        date = Date.parse(filter_params[:date])
        @availability_blocks = @availability_blocks.where(
          'availability_blocks.start_time <= ? AND availability_blocks.end_time >= ?',
          date.end_of_day, date.beginning_of_day
        )
      rescue ArgumentError
        # invalid date — ignore
      end
    end

    # Location filter
    if filter_params[:location].present?
      location_term = "%#{filter_params[:location].downcase}%"
      @availability_blocks = @availability_blocks
        .joins("INNER JOIN locations ON locations.id = availability_blocks.location_id")
        .where(
          "LOWER(locations.city) LIKE :t OR LOWER(locations.name) LIKE :t",
          t: location_term
        )
    end

    @availability_blocks = @availability_blocks.distinct
  end

  def show
    authorize @appointment
    store_location_for(:user, request.fullpath) unless user_signed_in?

    @available_add_ons = @appointment.stylist.services.add_ons.active

    @pending_appointments = if current_user
      current_user.appointments.where(
        stylist_id: @appointment.stylist_id,
        status: [:pending, :booked]
      ).where.not(id: @appointment.id)
    else
      Appointment.none
    end

    base_services = if @appointment.availability_block.present?
      @appointment.availability_block.available_services.main_services
    else
      @appointment.stylist.services.active.main_services
    end
    @services = base_services.map { |s| "#{s.name} - $#{sprintf('%.2f', s.price)}" }

    # Build a lookup map from service string value → Service object (with photo)
    service_ids = base_services.map(&:id)
    @service_photo_map = Service.where(id: service_ids)
      .includes(photo_attachment: :blob)
      .index_by { |s| "#{s.name} - $#{sprintf('%.2f', s.price)}" }

    @available_slots = @appointment.stylist.availability_blocks
      .where('start_time >= ?', Time.current)
      .order(:start_time)
      .flat_map do |block|
        slots = []
        t = block.start_time
        while t + 30.minutes <= block.end_time
          slots << { time: t.iso8601, label: t.strftime("%A, %B %-d at %l:%M %p UTC") }
          t += 30.minutes
        end
        slots
      end
  end

  def my_appointments
    authorize Appointment, :my_appointments?
    base = Appointment.where(customer_id: current_user.id)
                      .includes(:stylist, :location, :appointment_add_ons)
                      .order(time: :desc)

    @pending   = base.where(status: :pending)
    @upcoming  = base.where(status: :booked)
    @completed = base.where(status: :completed)
    @cancelled = base.where(status: :cancelled)
  end

def review
  authorize @appointment
  if !@appointment.pending?
    redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
    return
  end

  # Enforce hold expiry
  if @appointment.hold_expires_at.present? && @appointment.hold_expires_at < Time.current
    stylist = @appointment.stylist
    session.delete("appointment_#{@appointment.id}_selections")
    @appointment.destroy
    redirect_to stylist_path(stylist),
      alert: "Your hold on this time slot has expired. Please select a new time."
    return
  end

  # Handle GET requests - try to restore from session
  if request.get?
    session_key = "appointment_#{@appointment.id}_selections"

    if session[session_key].present? && session[session_key]["selected_service"].present?
      # Restore selections from session (using string keys)
      @selected_service         = session[session_key]["selected_service"]
      @selected_add_on_services = Service.where(id: session[session_key]["add_on_ids"] || [])
      @selected_time            = session[session_key]["selected_time"]
      @service_price = extract_price(@selected_service)
      @add_ons_total = @selected_add_on_services.sum(&:price)
      @total   = @service_price + @add_ons_total
      @deposit = (@total * 0.5).round(2)
      service_name = @selected_service&.split(' - $')&.first
      @selected_service_object = @appointment.stylist.services
        .includes(photo_attachment: :blob)
        .find_by(name: service_name)
    else
      # No valid session data, redirect back to appointment page
      redirect_to appointment_path(@appointment), notice: "Please select your services to continue."
      return
    end
  else
    # Handle POST requests - store selections in session and redirect
    if params[:selected_service].blank?
      redirect_to appointment_path(@appointment), alert: "Please select a service first."
      return
    end

    # Store in session for later retrieval (using string keys for consistency)
    session_key = "appointment_#{@appointment.id}_selections"
    session[session_key] = {
      "selected_service" => params[:selected_service],
      "add_on_ids"       => (params[:add_on_ids] || []).map(&:to_i),
      "selected_time"    => params[:selected_time]
    }

    # Redirect to GET review to prevent form resubmission and enable browser back
    redirect_to review_appointment_path(@appointment)
    return
  end
end


  def confirmation
    authorize @appointment

    unless @appointment.customer_id == current_user&.id
      redirect_to appointments_path, alert: "You don't have access to that receipt."
      return
    end

    @selected_service = @appointment.selected_service&.split(' - $')&.first
    @add_ons_total    = @appointment.total_add_ons_price
    @service_price    = @appointment.total_price
    @deposit_paid     = (@service_price * 0.5).round(2)
    @balance_due      = @deposit_paid
  end

  def balance_receipt
    authorize @appointment

    unless @appointment.customer_id == current_user&.id
      redirect_to appointments_path, alert: "You don't have access to that receipt."
      return
    end

    unless @appointment.balance_payment_id.present?
      redirect_to confirmation_appointment_path(@appointment)
      return
    end

    @selected_service = @appointment.selected_service&.split(' - $')&.first
    @service_price    = @appointment.total_price
    @balance_paid     = (@service_price * 0.5).round(2)
  end

  def invoice
    authorize @appointment

    unless @appointment.customer_id == current_user&.id
      redirect_to appointments_path, alert: "You don't have access to that invoice."
      return
    end

    @selected_service = @appointment.selected_service&.split(' - $')&.first
    @add_ons_total    = @appointment.total_add_ons_price
    @service_price    = @appointment.total_price
    @deposit_paid     = (@service_price * 0.5).round(2)
    @balance_paid     = @deposit_paid
  end

  def book
    authorize @appointment

    if !@appointment.pending? || @appointment.customer_id.present?
      redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
      return
    end

    # Enforce hold expiry
    if @appointment.hold_expires_at.present? && @appointment.hold_expires_at < Time.current
      stylist = @appointment.stylist
      session.delete("appointment_#{@appointment.id}_selections")
      @appointment.destroy
      redirect_to stylist_path(stylist),
        alert: "Your hold on this time slot has expired. Please select a new time."
      return
    end

    payment_nonce = params[:payment_nonce]

    unless payment_nonce.present?
      flash[:alert] = "Payment information is required to book an appointment."
      redirect_to review_appointment_path(@appointment)
      return
    end

    unless params[:card_save_consent] == '1'
      flash[:alert] = "You must agree to save your card to complete the booking."
      redirect_to review_appointment_path(@appointment)
      return
    end

    selected_service = params[:selected_service]

    # Pre-check: validate for double booking before charging payment
    @appointment.selected_service = selected_service
    @appointment.validate
    if @appointment.errors[:time].any?
      flash[:alert] = @appointment.errors[:time].first
      @appointment.reload
      redirect_to appointment_path(@appointment)
      return
    end
    @appointment.reload

    # Set payment_amount before calling any service method (total_amount_cents depends on it)
    add_ons = @appointment.stylist.services.add_ons.where(id: params[:add_on_ids] || [])
    @appointment.payment_amount = calculate_total(selected_service, add_ons)

    payment_service = PaymentService.new(@appointment.stylist)

    # Step 1 — Ensure customer record exists in stylist's Square account
    begin
      customer_id = payment_service.create_or_find_customer(current_user)
    rescue => e
      flash[:alert] = "Booking setup failed: #{e.message}"
      redirect_to review_appointment_path(@appointment)
      return
    end

    # Step 2 — Vault the card (nonce → stored card on file)
    card_result = payment_service.create_card(current_user, payment_nonce, @appointment)
    unless card_result[:success]
      flash[:alert] = "Could not save your card: #{card_result[:error]}"
      redirect_to review_appointment_path(@appointment)
      return
    end
    card_id = card_result[:card_id]

    # Step 3 — Charge deposit using the vaulted card
    result = payment_service.charge_deposit(@appointment, card_id, customer_id)
    unless result[:success]
      payment_service.disable_card(card_id)  # best-effort cleanup of orphaned card
      flash[:alert] = "Payment failed: #{result[:error]}"
      redirect_to review_appointment_path(@appointment)
      return
    end

    # Step 4 — Persist appointment with card_id
    @appointment.assign_attributes(
      customer:         current_user,
      selected_service: selected_service,
      payment_id:       result[:payment_id],
      payment_status:   'deposit_paid',
      payment_method:   'square',
      square_card_id:   card_id
    )

    add_ons.each do |svc|
      @appointment.appointment_add_ons.build(
        service_id:   svc.id,
        service_name: svc.name,
        price:        svc.price
      )
    end

    if @appointment.save
      session.delete("appointment_#{@appointment.id}_selections")
      Rails.logger.info "Appointment ##{@appointment.id} booked. Deposit: $#{sprintf('%.2f', result[:amount_charged])}, Platform fee: $#{sprintf('%.2f', result[:platform_fee])}"
      AppointmentMailer.new_booking_request(@appointment).deliver_later
      AppointmentMailer.booking_request_confirmation(@appointment).deliver_later
      redirect_to booked_appointment_path(@appointment),
                  notice: "Appointment requested! Deposit of $#{sprintf('%.2f', result[:amount_charged])} charged."
    else
      # Deposit captured + card vaulted but DB save failed — do NOT disable card (needed for refund)
      Rails.logger.error "PAYMENT CAPTURED but save failed! Payment ID: #{result[:payment_id]}, Card ID: #{card_id}, Appointment: #{@appointment.id}, Errors: #{@appointment.errors.full_messages}"
      redirect_to payment_failed_appointment_path(@appointment),
                  alert: "Payment was processed but your booking couldn't be saved. Reference: #{result[:payment_id]}"
    end
  end

  def booked
    authorize @appointment
    if @appointment.customer == current_user && (@appointment.pending? || @appointment.booked?)
      @service_price = extract_price(@appointment.selected_service)
      @add_ons_total = @appointment.total_add_ons_price
    else
      redirect_to appointments_path, alert: "Appointment not found."
    end
  end

  def payment_failed
    @appointment = Appointment.find_by(id: params[:id])

    if @appointment.nil?
      redirect_to appointments_path, alert: "Appointment not found."
      return
    end

    unless @appointment.stylist_id == current_user.id || @appointment.customer_id == current_user.id
      redirect_to appointments_path, alert: "You don't have access to that page."
      return
    end

    skip_authorization
  end

  def cancel
    authorize @appointment

    unless @appointment.cancellable_by_customer?
      redirect_to appointment_path(@appointment),
        alert: "This appointment cannot be cancelled."
      return
    end

    cancellation_reason = params[:cancellation_reason]
    refund_result = nil

    if @appointment.payment_id.present?
      if @appointment.full_refund_eligible?
        # More than 24 hours notice — full refund
        refund_result = PaymentService.new(@appointment.stylist).refund_deposit(@appointment)

        if refund_result[:success]
          @appointment.payment_status = 'refunded'
        else
          redirect_to appointment_path(@appointment),
            alert: "Cancellation failed: refund could not be processed. Please contact support."
          return
        end
      else
        # Less than 24 hours notice — no refund
        @appointment.payment_status = 'deposit_kept'
      end
    end

    @appointment.assign_attributes(
      status: :cancelled,
      cancelled_by: 'customer',
      cancelled_at: Time.current,
      cancellation_reason: cancellation_reason.presence
    )

    if @appointment.save
      session.delete("appointment_#{@appointment.id}_selections")

      AppointmentMailer.cancellation_notice(
        @appointment,
        cancelled_by: 'customer',
        refund_issued: refund_result&.dig(:success)
      ).deliver_later
      AppointmentMailer.deposit_refunded(@appointment).deliver_later if @appointment.payment_status == 'refunded'

      if @appointment.payment_status == 'deposit_kept'
        redirect_to my_appointments_path,
          notice: "Appointment cancelled. As this is within 24 hours of your appointment, your deposit has been kept per our cancellation policy."
      elsif @appointment.payment_status == 'refunded'
        redirect_to my_appointments_path,
          notice: "Appointment cancelled successfully. Your deposit refund will appear within 5-10 business days."
      else
        redirect_to my_appointments_path, notice: "Booking request withdrawn."
      end
    else
      redirect_to appointment_path(@appointment),
        alert: "Could not cancel appointment. Please try again."
    end
  end

  def destroy
    authorize @appointment
    if @appointment.customer == current_user
      # Clear session data
      session.delete("appointment_#{@appointment.id}_selections")

      if @appointment.pending?
        # Pending request — just withdraw, reopen the slot
        @appointment.update(customer_id: nil, selected_service: nil)
        @appointment.appointment_add_ons.destroy_all
        redirect_back fallback_location: my_appointments_path, notice: "Your booking request has been withdrawn."
      else
        # Booked appointment — full cancellation
        @appointment.cancel!(cancelled_by: current_user)
        redirect_back fallback_location: my_appointments_path, notice: "Your appointment has been cancelled, let us know when you want to take another seat!"
      end
    else
      redirect_back fallback_location: appointment_path(@appointment), alert: "Sorry, you didn't book this seat."
    end
  end

  def complete
    authorize @appointment
    # Check if user is either the customer or stylist
    is_customer = @appointment.customer == current_user
    is_stylist = @appointment.stylist == current_user

    # Check if appointment time has passed
    time_has_passed = @appointment.time < Time.current

    # Check if appointment is booked
    if !@appointment.booked?
      redirect_back fallback_location: root_path, alert: "This appointment is not booked."
    # Stylists can complete at any time, customers must wait until after appointment time
    elsif is_stylist
      @appointment.update(status: :completed)
      redirect_back fallback_location: root_path, notice: "Appointment marked as completed!"
    elsif is_customer && time_has_passed
      @appointment.update(status: :completed)
      redirect_back fallback_location: root_path, notice: "Appointment marked as completed!"
    elsif is_customer && !time_has_passed
      redirect_back fallback_location: root_path, alert: "This appointment hasn't occurred yet."
    else
      redirect_back fallback_location: root_path, alert: "You don't have permission to complete this appointment."
    end
  end

  private

  def filter_params
    params.fetch(:search, {}).permit(:service, :date, :location)
  end

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def calculate_total(service_string, add_ons)
    extract_price(service_string) + add_ons.sum(&:price)
  end

  def extract_price(service_string)
    return 0.0 if service_string.blank?
    service_string.split(" - $").last.to_f
  end

end
