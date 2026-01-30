module Api
  module V1
    class ProfilesController < BaseController
      # GET /api/v1/profile
      def show
        render json: {
          id: current_user.id,
          email: current_user.email,
          name: current_user.name,
          username: current_user.username,
          role: current_user.role,
          location: current_user.location,
          about: current_user.about,
          avatar_url: current_user.avatar.attached? ? url_for(current_user.avatar) : nil
        }, status: :ok
      end

      # PATCH /api/v1/profile
      def update
        if current_user.update(profile_params)
          render json: {
            message: 'Profile updated successfully',
            user: {
              id: current_user.id,
              email: current_user.email,
              name: current_user.name,
              username: current_user.username,
              role: current_user.role,
              location: current_user.location,
              about: current_user.about,
              avatar_url: current_user.avatar.attached? ? url_for(current_user.avatar) : nil
            }
          }, status: :ok
        else
          render json: {
            error: 'Update failed',
            errors: current_user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:user).permit(:name, :username, :location, :about, :avatar)
      end
    end
  end
end
