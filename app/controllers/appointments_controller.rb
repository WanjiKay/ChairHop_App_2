class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [:show, :check_in, :confirmation, :book, :destroy]

  def index
    @available_appointments = Appointment.where(booked: false)
    #@upcoming_appointments = current_user.appointments.where(booked: true) if user_signed_in?
    #@my_appointments = current_user.appointments
    @appointments = Appointment.all
      respond_to do |format|
        format.html {render :index}
      end
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
      @service_price = extract_price(@appointment.selected_service)
      render :booked
    else
      redirect_to check_in_appointment_path(@appointment, selected_service: params[:selected_service]), alert: "Something went wrong."
    end
  end

  def destroy
    if @appointment.customer == current_user
      @appointment.update(customer: nil, booked: false)
      redirect_to appointments_path, notice: "Your appointment has been cancelled, let us know when you want to take another seat!"
    else
      redirect_to appointment_path, alert: "Sorry, you didn't book this seat."
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def extract_price(service_string)
    service_string.split(" - $").last.to_f
  end
end
