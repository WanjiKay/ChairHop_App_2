class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [:book, :destroy]

  def index
    @available_appointments = Appointment.where(booked: false)
    #@upcoming_appointments = current_user.appointments.where(booked: true) if user_signed_in?
    #@my_appointments = current_user.appointments
    @appointments = Appointment.all
      respond_to do |format|
        format.html {render :index}
      end
  end

  def book
    if @appointment.booked?
      redirect_to appointment_path(@appointmet), alert: "Sorry this chair has already been filled."
    elsif @ppointment.update(user: current_user, booked: true)
      redirect_to appointments_path, notice: "You may now take your seat!"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    if @appointment.user == current_user
      @appointment.update(user: nil, booked: false)
      redirect_to appointments_path, notice: "Your appointment has been cancelled, let us know when you want to take another seat!"
    else
      redirect_to appointment_path, alert: "Sorry, you didn't book this seat."
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

end
