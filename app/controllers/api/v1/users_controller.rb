module Api
  module V1
    class UsersController < BaseController
      def update_push_token
        if current_user.update(push_token: params[:push_token])
          render json: { message: 'Push token registered' }, status: :ok
        else
          render json: { error: 'Failed to register push token' }, status: :unprocessable_entity
        end
      end
    end
  end
end
