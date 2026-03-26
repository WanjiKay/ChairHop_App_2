class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])

    # Verify user is participant
    if conversation.customer_id == current_user.id || conversation.stylist_id == current_user.id
      stream_for conversation
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
