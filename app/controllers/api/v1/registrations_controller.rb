module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      # POST /api/v1/signup
      def create
        build_resource(sign_up_params)

        # Default new users to customer role
        resource.role ||= :customer

        if resource.save
          sign_in(resource)
          render json: {
            message: 'Signed up successfully',
            user: user_data(resource)
          }, status: :created
        else
          render json: {
            error: 'Signup failed',
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name, :username, :location, :role)
      end

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
        if resource.persisted?
          render json: {
            message: 'Signed up successfully',
            user: user_data(resource)
          }, status: :created
        else
          render json: {
            error: 'Signup failed',
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
