module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :authenticate_api_user!, only: [:index]
      before_action :set_appointment, only: [:create]
      before_action :set_appointment_for_show, only: [:show]

      # GET /api/v1/reviews?stylist_id=X
      # List reviews for a specific stylist
      def index
        unless params[:stylist_id]
          render json: { error: 'stylist_id required' }, status: :bad_request
          return
        end

        stylist = User.find(params[:stylist_id])
        @reviews = Review.where(stylist_id: stylist.id)
                         .includes(:customer, :appointment)
                         .order(created_at: :desc)

        render json: {
          reviews: @reviews.map { |review| review_index_json(review) },
          average_rating: @reviews.average(:rating)&.round(1) || 0,
          total_reviews: @reviews.count
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Stylist not found' }, status: :not_found
      end

      # POST /api/v1/appointments/:appointment_id/review
      # Create a review for a completed appointment
      def create
        # Verify appointment is completed
        unless @appointment.completed?
          render json: {
            error: 'Cannot review',
            message: 'Appointment must be completed before leaving a review'
          }, status: :unprocessable_entity
          return
        end

        # Verify current user is participant
        unless participant?(@appointment)
          render json: {
            error: 'Unauthorized',
            message: 'You must be part of this appointment to leave a review'
          }, status: :forbidden
          return
        end

        # Verify appointment doesn't already have a review
        if @appointment.review.present?
          render json: {
            error: 'Review already exists',
            message: 'This appointment has already been reviewed'
          }, status: :unprocessable_entity
          return
        end

        # Determine who is being reviewed
        if current_user.id == @appointment.customer_id
          # Customer is reviewing the stylist
          review_params_hash = review_params.merge(
            appointment_id: @appointment.id,
            customer_id: current_user.id,
            stylist_id: @appointment.stylist_id
          )
        elsif current_user.id == @appointment.stylist_id
          # Stylist is reviewing the customer
          review_params_hash = review_params.merge(
            appointment_id: @appointment.id,
            customer_id: @appointment.customer_id,
            stylist_id: current_user.id
          )
        else
          render json: { error: 'Unauthorized' }, status: :forbidden
          return
        end

        @review = Review.new(review_params_hash)

        if @review.save
          render json: {
            review: review_json(@review),
            message: 'Review submitted successfully'
          }, status: :created
        else
          render json: {
            error: 'Review creation failed',
            errors: @review.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/appointments/:appointment_id/reviews
      # Get review for a specific appointment
      def show
        # Verify current user is participant
        unless participant?(@appointment)
          render json: {
            error: 'Unauthorized',
            message: 'You must be part of this appointment to view its review'
          }, status: :forbidden
          return
        end

        if @appointment.review.present?
          render json: {
            review: review_json(@appointment.review)
          }, status: :ok
        else
          render json: {
            error: 'Not found',
            message: 'No review found for this appointment'
          }, status: :not_found
        end
      end

      private

      def set_appointment
        @appointment = Appointment.find(params[:appointment_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Appointment not found' }, status: :not_found
      end

      def set_appointment_for_show
        @appointment = Appointment.includes(:review).find(params[:appointment_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Appointment not found' }, status: :not_found
      end

      def participant?(appointment)
        current_user.id == appointment.customer_id || current_user.id == appointment.stylist_id
      end

      def review_params
        params.require(:review).permit(:rating, :content)
      end

      def review_index_json(review)
        {
          id: review.id,
          rating: review.rating,
          content: review.content,
          created_at: review.created_at,
          customer: {
            id: review.customer.id,
            name: review.customer.name
          },
          appointment: {
            id: review.appointment.id,
            time: review.appointment.time,
            selected_service: review.appointment.selected_service
          }
        }
      end

      def review_json(review)
        {
          id: review.id,
          appointment_id: review.appointment_id,
          rating: review.rating,
          content: review.content,
          reviewer: {
            id: current_user.id,
            name: current_user.name,
            username: current_user.username,
            role: current_user.role
          },
          reviewed_user: if current_user.id == review.customer_id
                          {
                            id: review.stylist.id,
                            name: review.stylist.name,
                            username: review.stylist.username,
                            role: 'stylist'
                          }
                        else
                          {
                            id: review.customer.id,
                            name: review.customer.name,
                            username: review.customer.username,
                            role: 'customer'
                          }
                        end,
          created_at: review.created_at,
          updated_at: review.updated_at
        }
      end
    end
  end
end
