class ConversationMessage < ApplicationRecord
  belongs_to :conversation
  has_many_attached :photos

  validates :role, presence: true
  validates :conversation, presence: true
  validate :content_or_photos_present
  validate :file_size_validation

  MAX_FILE_SIZE_MB = 10

  after_create_commit :broadcast_conversation

  private

  def content_or_photos_present
    if content.blank? && photos.blank?
      errors.add(:base, "Message must have either content or photos")
    end
  end

  def file_size_validation
    photos.each do |photo|
      if photo.byte_size > MAX_FILE_SIZE_MB.megabytes
        errors.add(:photos, "size must be less than #{MAX_FILE_SIZE_MB}MB")
      end
    end
  end

  def broadcast_conversation
    broadcast_append_to "conversation_#{conversation.id}_messages",
                        partial: "conversation_messages/conversation_message",
                        target: "conversation_messages",
                        locals: { conversation_message: self }
  end
end
