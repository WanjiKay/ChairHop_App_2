class Conversation < ApplicationRecord
  belongs_to :appointment
  belongs_to :customer, class_name: "User"
  belongs_to :stylist, class_name: "User"
  has_many :conversation_messages, dependent: :destroy
end
