class Chat < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :appointment, optional: true

  has_many :messages, dependent: :destroy
end
