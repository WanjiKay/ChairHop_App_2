class Review < ApplicationRecord
  belongs_to :appointment
  belongs_to :customer, class_name: "User"
  belongs_to :stylist, class_name: "User"
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true, length: { maximum: 500 }
end
