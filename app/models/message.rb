class Message < ApplicationRecord
  belongs_to :chat
  has_many_attached :photos

  validates :content, length: { maximum: 1000 }
  validate :content_or_photos_present, if: -> { role == "user" }
  validates :role, presence: true
  validates :chat, presence: true
  validate :file_size_validation
  validate :file_content_type_validation
  validate :user_message_limit, if: -> { role == "user" }

  MAX_FILE_SIZE_MB = 5
  MAX_USER_MESSAGES = 15
  ALLOWED_CONTENT_TYPES = ['image/png', 'image/jpeg', 'image/jpg', 'image/webp']

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

  def file_content_type_validation
    photos.each do |photo|
      unless ALLOWED_CONTENT_TYPES.include?(photo.content_type)
        errors.add(:photos, "must be a PNG, JPEG, JPG, or WEBP image")
      end
    end
  end

  def user_message_limit
    if chat.messages.where(role: "user").count >= MAX_USER_MESSAGES
      errors.add(:base, "You can only send #{MAX_USER_MESSAGES} messages per chat.")
    end
  end
end
