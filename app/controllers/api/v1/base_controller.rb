module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      # Skip CSRF verification for API requests
      skip_before_action :verify_authenticity_token, raise: false

      # Authenticate users via JWT for API requests
      before_action :authenticate_user!

      # Set default response format to JSON
      respond_to :json

      # Rescue from Pundit authorization errors with JSON response
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      # Rescue from record not found errors
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      private

      def user_not_authorized
        render json: {
          error: 'Unauthorized',
          message: 'You are not authorized to perform this action.'
        }, status: :forbidden
      end

      def record_not_found
        render json: {
          error: 'Not Found',
          message: 'The requested resource was not found.'
        }, status: :not_found
      end

      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end

      def render_success(data, status = :ok)
        render json: data, status: status
      end
    end
  end
end
