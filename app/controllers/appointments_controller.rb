class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [:show, :check_in, :confirmation, :book, :destroy]

  def index
    @appointments = Appointment.where(booked: false)

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

      if search_params[:time].present?
        time_input = search_params[:time].strip
        # Use HH12 for 12-hour format and ILIKE for case-insensitive matching
        # This handles formats like: "7:00 am", "7:00 AM", "07:00 am", "7 am", etc.
        time_term = "%#{time_input}%"
        @appointments = @appointments.where("TO_CHAR(time, 'HH12:MI AM') ILIKE ?", time_term)
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
    @my_appointments = current_user.appointments_as_customer.where(booked: true)
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
  if @appointment.booked?
    redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
  elsif params[:selected_service].blank?
    redirect_to appointment_path(@appointment), alert: "Please select a service first."
  else
    @selected_service = params[:selected_service]
    @service_price = extract_price(@selected_service)
    @selected_add_ons = params[:selected_add_ons] || []
    @add_ons_total = calculate_add_ons_total(@selected_add_ons)
  end
end


  def confirmation
    if @appointment.booked?
      redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
    else
      @selected_service = params[:selected_service]
      @service_price = extract_price(@selected_service)
    end
  end

  def book
    if @appointment.booked?
      redirect_to appointment_path(@appointment), alert: "Sorry this chair has already been filled."
    elsif @appointment.update(customer: current_user, booked: true, selected_service: params[:selected_service])
      # Save add-ons if any were selected
      if params[:selected_add_ons].present?
        params[:selected_add_ons].each do |add_on_service|
          @appointment.appointment_add_ons.create(
            service_name: add_on_service,
            price: extract_price(add_on_service)
          )
        end
      end
      @service_price = extract_price(@appointment.selected_service)
      @add_ons_total = @appointment.total_add_ons_price
      render :booked
    else
      redirect_to check_in_appointment_path(@appointment, selected_service: params[:selected_service]), alert: "Something went wrong."
    end
  end

  def destroy
    if @appointment.customer == current_user
      @appointment.update(customer: nil, booked: false)
      redirect_back fallback_location: my_appointments_path, notice: "Your appointment has been cancelled, let us know when you want to take another seat!"
    else
      redirect_back fallback_location: appointment_path(@appointment), alert: "Sorry, you didn't book this seat."
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def extract_price(service_string)
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
