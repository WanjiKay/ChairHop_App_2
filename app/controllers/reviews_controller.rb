class ReviewsController < ApplicationController
  before_action :authenticate_user!  # you use Devise
  before_action :set_appointment
  before_action :authorize_review

  def new
    # prevent double reviews for the same appointment
    if @appointment.review.present?
      redirect_to my_appointments_path, alert: "You already left a review for this appointment."
      return
    end

    @review = Review.new
  end

  def create
    # build the review linked to this appointment
    @review = @appointment.build_review(review_params)

    # who is the customer and stylist? from the appointment
    @review.customer = @appointment.customer
    @review.stylist  = @appointment.stylist

    if @review.save
      redirect_to my_appointments_path, notice: "Thanks for your review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:appointment_id])
  end

  def review_params
    # IMPORTANT: your model uses :content, not :comment
    params.require(:review).permit(:rating, :content)
  end

  def authorize_review
    # Only the customer can review their own appointment
    unless @appointment.customer == current_user
      redirect_to my_appointments_path, alert: "You can only review your own appointments."
      return
    end

    # Only completed appointments can be reviewed
    unless @appointment.completed?
      redirect_to my_appointments_path, alert: "You can only review completed appointments."
      return
    end
  end
end
