class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  # def home
  #   @time_range = Time.current..(Time.current + 4.hours)
  #   @upcoming_appointments = Appointment.where(time: @time_range, booked: false).order(:time)
  # end

  def home
  @upcoming_appointments = Appointment
    .where(time: Time.current..(Time.current + 24.hours), booked: false)
    .order(:time)
end
end
