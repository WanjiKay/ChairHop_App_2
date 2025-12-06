class Chat < ApplicationRecord
  attr_accessor :content

  belongs_to :customer, class_name: "User"
  belongs_to :appointment, optional: true

  has_many :messages, dependent: :destroy

  # Scope to only show chats with messages
  scope :with_messages, -> { joins(:messages).distinct }

  # Check if chat has any messages
  def has_messages?
    messages.any?
  end
end
