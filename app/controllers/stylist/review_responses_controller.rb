class Stylist::ReviewResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_stylist!
  before_action :set_review

  def create
    skip_authorization
    if @review.update(
      stylist_response: params[:stylist_response],
      stylist_responded_at: Time.current
    )
      AppointmentMailer.review_response_notification(@review).deliver_later
      redirect_to stylist_dashboard_path, notice: "Your response has been posted."
    else
      redirect_to stylist_dashboard_path, alert: "Could not save response."
    end
  end

  def update
    skip_authorization
    if @review.update(
      stylist_response: params[:stylist_response],
      stylist_responded_at: Time.current
    )
      AppointmentMailer.review_response_notification(@review).deliver_later
      redirect_to stylist_dashboard_path, notice: "Your response has been updated."
    else
      redirect_to stylist_dashboard_path, alert: "Could not update response."
    end
  end

  private

  def set_review
    @review = Review.joins(:appointment)
      .where(appointments: { stylist_id: current_user.id })
      .find(params[:review_id] || params[:id])
  end

  def ensure_stylist!
    redirect_to root_path, alert: "Access denied" unless current_user.stylist?
  end
end
