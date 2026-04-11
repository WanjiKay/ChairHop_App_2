class Stylist::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!

  def index
    skip_authorization
    @pending_requests = current_user.appointments_as_stylist
                                    .where(status: :pending, payment_status: 'deposit_paid')
                                    .count
    @upcoming_appointments = current_user.appointments_as_stylist.booked.where("time >= ?", Time.current).count
    @completed_count = current_user.appointments_as_stylist.completed.count
    @total_earnings = current_user.appointments_as_stylist
                                   .completed
                                   .sum('COALESCE(payment_amount, 0)')
    @recent_appointments = current_user.appointments_as_stylist
                                       .where.not(status: :pending)
                                       .includes(:customer)
                                       .order(time: :desc)
                                       .limit(5)
    @total_review_count = Review.joins(:appointment)
                                 .where(appointments: { stylist_id: current_user.id }).count
    @recent_reviews = Review.joins(:appointment)
                             .where(appointments: { stylist_id: current_user.id })
                             .includes(:customer, :appointment, photos_attachments: :blob)
                             .order(created_at: :desc)
                             .limit(5)
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied" unless current_user.stylist?
  end
end
