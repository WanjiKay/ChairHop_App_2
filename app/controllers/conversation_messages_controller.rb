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
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_conversation_message", partial: "conversation_messages/form", locals: { conversation: @conversation, conversation_message: @conversation_message }) }
        format.html { render "conversations/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def conversation_message_params
    params.require(:conversation_message).permit(:content, photos: [])
  end
end
