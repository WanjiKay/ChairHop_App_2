class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  # def home
  #   @time_range = Time.current..(Time.current + 4.hours)
  #   @upcoming_appointments = Appointment.where(time: @time_range, booked: false).order(:time)
  # end

  def home
    skip_authorization
    @available_stylists = User.where(role: :stylist)
      .where(
        'EXISTS (SELECT 1 FROM availability_blocks WHERE availability_blocks.stylist_id = users.id AND availability_blocks.end_time > ?)',
        Time.current
      )
      .includes(:locations)
      .limit(6)
  end
end
