class ConversationMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    @conversation_message = ConversationMessage.new(conversation_message_params)
    @conversation_message.conversation = @conversation

    # Determine role based on who is sending the message
    if current_user.id == @conversation.customer_id
      @conversation_message.role = "customer"
    elsif current_user.id == @conversation.stylist_id
      @conversation_message.role = "stylist"
    else
      redirect_to root_path, alert: "You don't have access to this conversation." and return
    end

    if @conversation_message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:messages, partial: "conversation_messages/conversation_message",
            locals: { conversation_message: @conversation_message })
        end
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      render "conversations/show", status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def conversation_message_params
    params.require(:conversation_message).permit(:content)
  end
end
