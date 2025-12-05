class Chat < ApplicationRecord
  attr_accessor :content

  belongs_to :customer, class_name: "User"
  belongs_to :appointment, optional: true

  has_many :messages, dependent: :destroy
end
