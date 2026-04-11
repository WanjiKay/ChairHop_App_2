class UserSquareCustomer < ApplicationRecord
  belongs_to :user
  belongs_to :stylist, class_name: 'User', foreign_key: :stylist_id

  encrypts :square_customer_id, deterministic: false

  validates :user_id,    presence: true
  validates :stylist_id, presence: true
  validates :user_id,    uniqueness: { scope: :stylist_id }
  validates :square_customer_id, presence: true
end
