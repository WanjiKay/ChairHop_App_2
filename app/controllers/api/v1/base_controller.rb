module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      # Skip CSRF verification for API requests
      skip_before_action :verify_authenticity_token, raise: false

      # Authenticate users via JWT for API requests
      before_action :authenticate_api_user!

      # Set default response format to JSON
      respond_to :json

      # Rescue from Pundit authorization errors with JSON response
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      # Rescue from record not found errors
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      private

      def authenticate_api_user!
        token = request.headers['Authorization']&.split(' ')&.last

        unless token
          render json: { error: 'Missing authentication token' }, status: :unauthorized
          return
        end

        begin
          secret_key = Rails.application.credentials.devise_jwt_secret_key || ENV['DEVISE_JWT_SECRET_KEY']
          jwt_payload = JWT.decode(token, secret_key, true, { algorithm: 'HS256' }).first
          @current_user = User.find(jwt_payload['sub'])

          # Check if token is in denylist
          jti = jwt_payload['jti']
          if JwtDenylist.exists?(jti: jti)
            render json: { error: 'Token has been revoked' }, status: :unauthorized
            return
          end
        rescue JWT::DecodeError => e
          render json: { error: "Invalid authentication token: #{e.message}" }, status: :unauthorized
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'User not found' }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end

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
