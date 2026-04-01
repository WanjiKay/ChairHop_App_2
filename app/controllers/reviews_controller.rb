class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment

  def new
    skip_authorization
    # prevent double reviews for the same appointment
    if @appointment.review.present?
      redirect_to my_appointments_path, alert: "You already left a review for this appointment."
      return
    end

    # Only the customer on this appointment can leave a review
    unless @appointment.customer == current_user
      redirect_to my_appointments_path, alert: "You can only review your own appointments."
      return
    end

    unless @appointment.completed?
      redirect_to my_appointments_path, alert: "You can only review completed appointments."
      return
    end

    @review = Review.new
  end

  def edit
    skip_authorization
    @review = @appointment.review
    unless @review&.customer == current_user
      redirect_to my_appointments_path, alert: "You can only edit your own reviews."
      return
    end
    unless @review.editable?
      redirect_to my_appointments_path, alert: "The review window has passed. Reviews can only be edited within 3 days of your appointment."
      return
    end
  end

  def update
    @review = @appointment.review
    authorize @review
    unless @review.editable?
      redirect_to my_appointments_path, alert: "The review window has passed."
      return
    end
    if params[:review][:photos].present? && params[:review][:photos].length > 2
      @review.errors.add(:photos, "You can only attach up to 2 photos.")
      render :edit, status: :unprocessable_entity
      return
    end
    if @review.update(review_params)
      redirect_to my_appointments_path, notice: "Your review has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    # build the review linked to this appointment
    @review = @appointment.build_review(review_params)

    # who is the customer and stylist? from the appointment
    @review.customer = @appointment.customer
    @review.stylist  = @appointment.stylist
    authorize @review

    unless @appointment.completed?
      redirect_to my_appointments_path, alert: "You can only review completed appointments."
      return
    end

    if params[:review][:photos].present? && params[:review][:photos].length > 2
      @review.errors.add(:photos, "You can only attach up to 2 photos.")
      render :new, status: :unprocessable_entity
      return
    end

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
    params.require(:review).permit(:rating, :content, photos: [])
  end
end
