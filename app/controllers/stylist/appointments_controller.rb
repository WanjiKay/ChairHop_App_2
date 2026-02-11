class Stylist::AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!
  before_action :set_appointment, only: [:accept, :decline, :cancel, :complete]

  def index
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
    @appointment = Appointment.new
    @services = current_user.services.active
  end

  def create
    @appointment = Appointment.new(availability_params)
    @appointment.stylist = current_user
    @appointment.status = :pending
    @appointment.booked = false

    # Build services text from selected Service records
    if params[:service_ids].present?
      selected_services = current_user.services.where(id: params[:service_ids])
      @appointment.services = selected_services.map { |s| "#{s.name} - $#{sprintf('%.2f', s.price)}" }.join("\n")
    end

    if @appointment.save
      redirect_to stylist_appointments_path, notice: "Availability slot created."
    else
      @services = current_user.services.active
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    if @appointment.customer_id.blank?
      redirect_to stylist_appointments_path, alert: "No customer has requested this slot yet."
      return
    end

    if @appointment.accept!
      redirect_to stylist_appointments_path, notice: "Booking accepted!"
    else
      redirect_to stylist_appointments_path, alert: "Failed to accept booking."
    end
  end

  def decline
    if @appointment.customer_id.blank?
      redirect_to stylist_appointments_path, alert: "No customer to decline."
      return
    end

    # Remove customer but keep the slot available
    @appointment.update(customer_id: nil, selected_service: nil)
    redirect_to stylist_appointments_path, notice: "Booking declined — slot reopened."
  end

  def cancel
    if @appointment.booked?
      @appointment.cancel!
      redirect_to stylist_appointments_path, notice: "Appointment cancelled."
    elsif @appointment.pending? && @appointment.customer_id.blank?
      @appointment.destroy
      redirect_to stylist_appointments_path, notice: "Availability slot removed."
    else
      @appointment.cancel!
      redirect_to stylist_appointments_path, notice: "Appointment cancelled."
    end
  end

  def complete
    unless @appointment.booked?
      redirect_to stylist_appointments_path, alert: "Only booked appointments can be completed."
      return
    end

    @appointment.update(status: :completed)
    redirect_to stylist_appointments_path, notice: "Appointment marked as completed!"
  end

  private

  def set_appointment
    @appointment = current_user.appointments_as_stylist.find(params[:id])
  end

  def availability_params
    params.require(:appointment).permit(:time, :location, :salon, :services, :content)
  end

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied" unless current_user.stylist?
  end
end
