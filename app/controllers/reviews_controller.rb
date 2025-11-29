class ReviewsController < ApplicationController
  before_action :authenticate_user!  # you use Devise
  before_action :set_appointment

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
end
