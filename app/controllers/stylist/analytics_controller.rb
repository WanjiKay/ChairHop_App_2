class Stylist::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!

  def index
    skip_authorization

    # Date range — default to last 30 days, support from/to params
    @period_start = params[:from].present? ?
      Date.parse(params[:from]) : 30.days.ago.to_date
    @period_end = params[:to].present? ?
      Date.parse(params[:to]) : Date.today

    completed = Appointment.where(
      stylist_id: current_user.id,
      status: :completed
    )

    completed_in_period = completed.where(
      completed_at: @period_start.beginning_of_day..@period_end.end_of_day
    )

    # Key metrics
    @total_earned       = completed.sum('COALESCE(payment_amount, 0)')
    @period_earned      = completed_in_period.sum('COALESCE(payment_amount, 0)')
    @total_appointments = completed.count
    @period_appointments = completed_in_period.count
    @cancelled_count    = Appointment.where(
      stylist_id: current_user.id,
      status: :cancelled
    ).where(
      cancelled_at: @period_start.beginning_of_day..@period_end.end_of_day
    ).count
    @pending_count = Appointment.where(
      stylist_id: current_user.id,
      status: :pending
    ).count
    @avg_rating = Review.joins(:appointment)
      .where(appointments: { stylist_id: current_user.id })
      .average(:rating)&.round(1)

    # Top services in period
    @top_services = completed_in_period
      .where.not(selected_service: nil)
      .group(:selected_service)
      .count
      .sort_by { |_, v| -v }
      .first(5)

    # Monthly earnings for the last 6 months
    @monthly_earnings = (0..5).map do |i|
      month_start = i.months.ago.beginning_of_month
      month_end   = i.months.ago.end_of_month
      earned = completed.where(
        completed_at: month_start..month_end
      ).sum('COALESCE(payment_amount, 0)')
      {
        month:  month_start.strftime("%b %Y"),
        earned: earned.to_f
      }
    end.reverse

    # Recent completed appointments
    @recent_completed = completed
      .includes(:customer, :appointment_add_ons)
      .order(completed_at: :desc)
      .limit(10)

  rescue ArgumentError
    redirect_to stylist_analytics_path, alert: "Invalid date range."
  end

  private

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied." unless current_user.stylist?
  end
end
