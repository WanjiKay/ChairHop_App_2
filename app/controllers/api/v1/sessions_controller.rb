module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token
      respond_to :json

      # POST /api/v1/login
      def create
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          sign_in(user)
          render json: {
            message: 'Logged in successfully',
            user: user_data(user)
          }, status: :ok
        else
          render json: {
            error: 'Invalid email or password'
          }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout
      def destroy
        if current_user
          sign_out(current_user)
          render json: {
            message: 'Logged out successfully'
          }, status: :ok
        else
          render json: {
            error: 'No active session'
          }, status: :unauthorized
        end
      end

      private

      def user_data(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          username: user.username,
          role: user.role,
          location: user.location,
          about: user.about,
          avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil
        }
      end

      def respond_with(resource, _opts = {})
        render json: {
          message: 'Logged in successfully',
          user: user_data(resource)
        }, status: :ok
      end

      def respond_to_on_destroy
        render json: {
          message: 'Logged out successfully'
        }, status: :ok
      end
    end
  end
end
