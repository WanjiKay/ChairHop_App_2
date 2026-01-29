class Service < ApplicationRecord
  belongs_to :stylist, class_name: 'User'
  has_many :appointment_add_ons, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :stylist_id, presence: true

  scope :active, -> { where(active: true) }
  scope :for_stylist, ->(stylist_id) { where(stylist_id: stylist_id) }

  # Convert price from cents to dollars
  def price
    price_cents / 100.0
  end

  # Set price in dollars (stored as cents)
  def price=(dollars)
    self.price_cents = (dollars.to_f * 100).round
  end
end
