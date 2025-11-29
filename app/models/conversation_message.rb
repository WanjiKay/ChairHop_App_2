class ConversationMessage < ApplicationRecord
  belongs_to :conversation
  validates :content, presence: true
  validates :role, presence: true
  validates :conversation, presence: true

  after_create_commit :broadcast_conversation

  private

  def broadcast_conversation
    broadcast_append_to "conversation_#{conversation.id}_messages",
                        partial: "conversation_messages/conversation_message",
                        target: "conversation_messages",
                        locals: { conversation_message: self }
  end
end
