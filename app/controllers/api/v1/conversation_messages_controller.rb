module Api
  module V1
    class ConversationMessagesController < BaseController
      before_action :set_conversation

      # POST /api/v1/conversations/:conversation_id/messages
      def create
        @message = @conversation.conversation_messages.build(message_params)
        @message.role = current_user.role

        if @message.save
          # Send push notification to other user
          other_user = current_user.customer? ? @conversation.stylist : @conversation.customer
          send_message_notification(other_user, @message)

          render json: {
            message: message_json(@message)
          }, status: :created
        else
          render json: {
            error: 'Failed to send message',
            errors: @message.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:conversation_id])

        unless @conversation.customer_id == current_user.id || @conversation.stylist_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def message_params
        params.require(:message).permit(:content)
      end

      def message_json(message)
        {
          id: message.id,
          content: message.content,
          role: message.role,
          sent_by_me: message.role == current_user.role,
          created_at: message.created_at,
          read: message.read?
        }
      end

      def send_message_notification(recipient, message)
        notification_service = PushNotificationService.new
        notification_service.send_to_user(
          recipient,
          "New message from #{current_user.name}",
          message.content.truncate(50),
          {
            type: 'new_message',
            conversation_id: @conversation.id,
            message_id: message.id
          }
        )
      rescue => e
        Rails.logger.warn "Push notification failed: #{e.message}"
      end
    end
  end
end
