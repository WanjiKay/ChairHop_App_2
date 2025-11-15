class ConversationMessage < ApplicationRecord
  belongs_to :conversation
  validates :content, presence: true
  validates :role, presence: true
  validates :conversation, presence: true
end
