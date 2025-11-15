class Message < ApplicationRecord
  belongs_to :chat
  has_many_attached :photos

  validates :content, length: { minimum: 10, maximum: 1000 }, if: -> { role == "user" }
  validates :role, presence: true
  validates :chat, presence: true
  validate :file_size_validation
  validate :user_message_limit, if: -> { role == "user" }
end
