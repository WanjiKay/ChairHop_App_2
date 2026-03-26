module Api
  module V1
    class UploadsController < BaseController
      # POST /api/v1/uploads/avatar
      def upload_avatar
        if params[:avatar].present?
          current_user.avatar.attach(params[:avatar])

          if current_user.avatar.attached?
            render json: {
              message: 'Avatar uploaded successfully',
              avatar_url: url_for(current_user.avatar)
            }, status: :ok
          else
            render json: {
              error: 'Failed to upload avatar',
              errors: current_user.errors.full_messages
            }, status: :unprocessable_entity
          end
        else
          render json: { error: 'No file provided' }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/appointments/:appointment_id/upload_image
      def upload_appointment_image
        appointment = Appointment.find(params[:appointment_id])

        unless appointment.stylist_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
          return
        end

        if params[:image].present?
          appointment.image.attach(params[:image])

          if appointment.image.attached?
            render json: {
              message: 'Image uploaded successfully',
              image_url: url_for(appointment.image)
            }, status: :ok
          else
            render json: {
              error: 'Failed to upload image',
              errors: appointment.errors.full_messages
            }, status: :unprocessable_entity
          end
        else
          render json: { error: 'No file provided' }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/conversations/:conversation_id/upload_photo
      def upload_message_photo
        conversation = Conversation.find(params[:conversation_id])

        unless conversation.customer_id == current_user.id || conversation.stylist_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
          return
        end

        if params[:photo].present?
          message = conversation.conversation_messages.build(
            role: current_user.role,
            content: params[:caption] || ''
          )

          message.photos.attach(params[:photo])

          if message.save
            render json: {
              message: 'Photo uploaded successfully',
              message_id: message.id,
              photo_urls: message.photos.map { |photo| url_for(photo) }
            }, status: :created
          else
            render json: {
              error: 'Failed to upload photo',
              errors: message.errors.full_messages
            }, status: :unprocessable_entity
          end
        else
          render json: { error: 'No file provided' }, status: :unprocessable_entity
        end
      end
    end
  end
end
