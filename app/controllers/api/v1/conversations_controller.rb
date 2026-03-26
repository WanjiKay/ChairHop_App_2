module Api
  module V1
    class ConversationsController < BaseController
      include Rails.application.routes.url_helpers

      before_action :set_conversation, only: [:show]

      # GET /api/v1/conversations
      def index
        @conversations = if current_user.customer?
                           current_user.conversations_as_customer
                         else
                           current_user.conversations_as_stylist
                         end

        @conversations = @conversations
          .includes(:customer, :stylist, :appointment, conversation_messages: :photos_attachments)
          .order(updated_at: :desc)

        render json: {
          conversations: @conversations.map { |conv| conversation_json(conv) }
        }, status: :ok
      end

      # GET /api/v1/conversations/:id
      def show
        # Mark messages from other user as read
        other_role = current_user.customer? ? 'stylist' : 'customer'
        @conversation.conversation_messages
          .where(role: other_role)
          .unread
          .each(&:mark_as_read!)

        render json: {
          conversation: conversation_detail_json(@conversation)
        }, status: :ok
      end

      # POST /api/v1/appointments/:appointment_id/conversations
      def create
        @appointment = Appointment.find(params[:appointment_id])

        # Check if conversation already exists
        @conversation = Conversation.find_by(appointment_id: @appointment.id)

        if @conversation
          render json: { conversation: conversation_json(@conversation) }, status: :ok
        else
          @conversation = Conversation.create!(
            appointment_id: @appointment.id,
            customer_id: @appointment.customer_id,
            stylist_id: @appointment.stylist_id
          )

          render json: { conversation: conversation_json(@conversation) }, status: :created
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Appointment not found' }, status: :not_found
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:id])

        unless @conversation.customer_id == current_user.id || @conversation.stylist_id == current_user.id
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def conversation_json(conversation)
        last_message = conversation.conversation_messages.order(created_at: :desc).first
        other_user = current_user.customer? ? conversation.stylist : conversation.customer
        other_role = current_user.customer? ? 'stylist' : 'customer'
        unread_count = conversation.conversation_messages
          .where(role: other_role)
          .unread
          .count

        {
          id: conversation.id,
          appointment_id: conversation.appointment_id,
          other_user: {
            id: other_user.id,
            name: other_user.name,
            username: other_user.username
          },
          last_message: last_message ? {
            content: last_message.content,
            created_at: last_message.created_at,
            sent_by_me: last_message.role == current_user.role
          } : nil,
          unread_count: unread_count,
          updated_at: conversation.updated_at
        }
      end

      def conversation_detail_json(conversation)
        messages = conversation.conversation_messages
          .order(created_at: :asc)
          .map do |msg|
            {
              id: msg.id,
              content: msg.content,
              role: msg.role,
              sent_by_me: msg.role == current_user.role,
              created_at: msg.created_at,
              read: msg.read?,
              photos: msg.photos.attached? ? msg.photos.map { |photo| url_for(photo) } : []
            }
          end

        other_user = current_user.customer? ? conversation.stylist : conversation.customer

        {
          id: conversation.id,
          appointment: {
            id: conversation.appointment.id,
            time: conversation.appointment.time,
            location: conversation.appointment.location,
            selected_service: conversation.appointment.selected_service
          },
          other_user: {
            id: other_user.id,
            name: other_user.name,
            username: other_user.username
          },
          messages: messages
        }
      end
    end
  end
end
