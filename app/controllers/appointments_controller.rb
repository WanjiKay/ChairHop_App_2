class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [:show, :check_in, :confirmation, :book, :booked, :destroy, :complete]

  def index
    @appointments = Appointment.where(status: :pending)

    # Handle simple search query with smart synonyms (from search bar)
    if params[:query].present?
      search_terms = expand_search_terms(params[:query].downcase)

      conditions = []
      values = []

      search_terms.each do |term|
        search_pattern = "%#{term}%"
        conditions << "(LOWER(appointments.salon) LIKE ? OR
                       LOWER(appointments.location) LIKE ? OR
                       LOWER(appointments.services) LIKE ? OR
                       LOWER(appointments.content) LIKE ? OR
                       LOWER(users.name) LIKE ?)"
        values += [search_pattern] * 5
      end

      @appointments = @appointments.joins(:stylist).where(conditions.join(" OR "), *values)
    end

    # Handle advanced filters (from "Show Filters" button)
    if params[:search].present?
      search_params = params[:search]

      if search_params[:location].present?
        location_term = "%#{search_params[:location].downcase}%"
        @appointments = @appointments.where("LOWER(location) LIKE ?", location_term)
      end

      if search_params[:date].present?
        date = Date.parse(search_params[:date]) rescue nil
        if date
          @appointments = @appointments.where("DATE(time) = ?", date)
        end
      end

      # Handle time range filtering
      if search_params[:time_from].present? || search_params[:time_to].present?
        if search_params[:time_from].present? && search_params[:time_to].present?
          # Both time_from and time_to are present - filter between the range
          time_from = Time.parse(search_params[:time_from])
          time_to = Time.parse(search_params[:time_to])
          @appointments = @appointments.where(
            "EXTRACT(HOUR FROM time) * 60 + EXTRACT(MINUTE FROM time) >= ? AND
             EXTRACT(HOUR FROM time) * 60 + EXTRACT(MINUTE FROM time) <= ?",
            time_from.hour * 60 + time_from.min,
            time_to.hour * 60 + time_to.min
          )
        elsif search_params[:time_from].present?
          # Only time_from is present - filter appointments at or after this time
          time_from = Time.parse(search_params[:time_from])
          @appointments = @appointments.where(
            "EXTRACT(HOUR FROM time) * 60 + EXTRACT(MINUTE FROM time) >= ?",
            time_from.hour * 60 + time_from.min
          )
        elsif search_params[:time_to].present?
          # Only time_to is present - filter appointments at or before this time
          time_to = Time.parse(search_params[:time_to])
          @appointments = @appointments.where(
            "EXTRACT(HOUR FROM time) * 60 + EXTRACT(MINUTE FROM time) <= ?",
            time_to.hour * 60 + time_to.min
          )
        end
      end

      if search_params[:service].present?
        service_conditions = search_params[:service].map { |service| "LOWER(services) LIKE ?" }
        service_terms = search_params[:service].map { |service| "%#{service.downcase}%" }
        @appointments = @appointments.where(service_conditions.join(" OR "), *service_terms)
      end
    end

    @available_appointments = @appointments

    respond_to do |format|
      format.html { render :index }
    end
  end

  def my_appointments
    @my_appointments = current_user.appointments_as_customer.where(status: [:booked, :completed, :cancelled])
  end

  # def check_in
  #   if @appointment.booked?
  #     redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
  #   else
  #     @selected_service = params[:selected_service]
  #     # Extract price from service string (format: "Service Name - $Price")
  #     @service_price = extract_price(@selected_service)
  #   end
  # end

def check_in
  if !@appointment.pending?
    redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
    return
  end

  # Handle GET requests - try to restore from session
  if request.get?
    session_key = "appointment_#{@appointment.id}_selections"
    Rails.logger.debug "GET check_in: Session key: #{session_key}"
    Rails.logger.debug "GET check_in: Session data: #{session[session_key].inspect}"
    Rails.logger.debug "GET check_in: All session keys: #{session.keys.inspect}"

    if session[session_key].present? && session[session_key]["selected_service"].present?
      # Restore selections from session (using string keys)
      @selected_service = session[session_key]["selected_service"]
      @selected_add_ons = session[session_key]["selected_add_ons"] || []
      @service_price = extract_price(@selected_service)
      @add_ons_total = calculate_add_ons_total(@selected_add_ons)
      Rails.logger.debug "GET check_in: Restored service: #{@selected_service}"
    else
      # No valid session data, redirect back to appointment page
      Rails.logger.debug "GET check_in: No valid session data found, redirecting"
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
      "selected_add_ons" => params[:selected_add_ons] || []
    }
    Rails.logger.debug "POST check_in: Stored in session: #{session[session_key].inspect}"
    Rails.logger.debug "POST check_in: Session keys after store: #{session.keys.inspect}"

    # Redirect to GET check_in to prevent form resubmission and enable browser back
    redirect_to check_in_appointment_path(@appointment)
    return
  end
end


  def confirmation
    if !@appointment.pending?
      redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
    else
      @selected_service = params[:selected_service]
      @service_price = extract_price(@selected_service)
    end
  end

  def book
    if !@appointment.pending?
      redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
    elsif @appointment.update(customer: current_user, booked: true, status: :booked, selected_service: params[:selected_service])
      # Save add-ons if any were selected
      if params[:selected_add_ons].present?
        params[:selected_add_ons].each do |add_on_service|
          @appointment.appointment_add_ons.create(
            service_name: add_on_service,
            price: extract_price(add_on_service)
          )
        end
      end

      # Clear session data after successful booking
      session.delete("appointment_#{@appointment.id}_selections")

      redirect_to booked_appointment_path(@appointment), notice: "Appointment successfully booked!"
    else
      redirect_to check_in_appointment_path(@appointment, selected_service: params[:selected_service]), alert: "Something went wrong."
    end
  end

  def booked
    if @appointment.booked? && @appointment.customer == current_user
      @service_price = extract_price(@appointment.selected_service)
      @add_ons_total = @appointment.total_add_ons_price
    else
      redirect_to appointments_path, alert: "Appointment not found or not booked."
    end
  end

  def destroy
    if @appointment.customer == current_user
      @appointment.update(customer: nil, booked: false, status: :cancelled)

      # Clear session data when unbooking
      session.delete("appointment_#{@appointment.id}_selections")

      redirect_back fallback_location: my_appointments_path, notice: "Your appointment has been cancelled, let us know when you want to take another seat!"
    else
      redirect_back fallback_location: appointment_path(@appointment), alert: "Sorry, you didn't book this seat."
    end
  end

  def complete
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

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def extract_price(service_string)
    return 0.0 if service_string.blank?
    service_string.split(" - $").last.to_f
  end

  def calculate_add_ons_total(add_ons_array)
    add_ons_array.sum { |add_on| extract_price(add_on) }
  end

  # Smart search: maps common search terms to variations and synonyms
  def expand_search_terms(query)
    # Synonym mapping for common hair service terms
    synonyms = {
      'haircut' => ['cut', 'haircut', 'trim'],
      'cut' => ['cut', 'haircut', 'trim'],
      'trim' => ['cut', 'haircut', 'trim'],
      'color' => ['color', 'colour', 'dye', 'highlights'],
      'colour' => ['color', 'colour', 'dye', 'highlights'],
      'dye' => ['color', 'colour', 'dye', 'highlights'],
      'highlights' => ['color', 'colour', 'dye', 'highlights'],
      'style' => ['style', 'styling', 'blowout', 'blow dry'],
      'styling' => ['style', 'styling', 'blowout', 'blow dry'],
      'blowout' => ['style', 'styling', 'blowout', 'blow dry'],
      'blow dry' => ['style', 'styling', 'blowout', 'blow dry'],
      'beard' => ['beard', 'facial hair'],
      'shave' => ['shave', 'razor'],
      'razor' => ['shave', 'razor'],
      'wash' => ['wash', 'shampoo'],
      'shampoo' => ['wash', 'shampoo'],
      'treatment' => ['treatment', 'conditioning', 'mask'],
      'conditioning' => ['treatment', 'conditioning', 'mask'],
      'mask' => ['treatment', 'conditioning', 'mask'],
      'perm' => ['perm', 'wave'],
      'wave' => ['perm', 'wave'],
      'straighten' => ['straighten', 'keratin', 'smoothing'],
      'keratin' => ['straighten', 'keratin', 'smoothing'],
      'smoothing' => ['straighten', 'keratin', 'smoothing'],
      'braid' => ['braid', 'braiding', 'plaits'],
      'braiding' => ['braid', 'braiding', 'plaits'],
      'plaits' => ['braid', 'braiding', 'plaits'],
      'extension' => ['extension', 'extensions', 'weave'],
      'extensions' => ['extension', 'extensions', 'weave'],
      'weave' => ['extension', 'extensions', 'weave']
    }

    # Check if the query matches any synonym key
    matched_terms = synonyms[query] || synonyms.find { |key, _| query.include?(key) }&.last

    # If we found synonyms, use them; otherwise use the original query
    matched_terms || [query]
  end
end
