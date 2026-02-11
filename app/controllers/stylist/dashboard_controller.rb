class Stylist::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!

  def index
    @pending_requests = current_user.appointments_as_stylist.pending.where.not(customer_id: nil).count
    @upcoming_appointments = current_user.appointments_as_stylist.booked.where("time >= ?", Time.current).count
    @completed_count = current_user.appointments_as_stylist.completed.count
    @total_earnings = current_user.appointments_as_stylist.completed.sum do |apt|
      apt.total_price
    end
    @recent_appointments = current_user.appointments_as_stylist
                                       .includes(:customer)
                                       .order(time: :desc)
                                       .limit(5)
    @recent_reviews = current_user.reviews_for_stylist
                                  .includes(:customer)
                                  .order(created_at: :desc)
                                  .limit(3)
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied" unless current_user.stylist?
  end
end
