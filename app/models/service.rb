class Service < ApplicationRecord
  belongs_to :stylist, class_name: 'User'
  has_many :appointment_add_ons, dependent: :restrict_with_error
  has_one_attached :photo

  validates :name, presence: true,
                   uniqueness: { scope: :stylist_id,
                                 message: "You already have a service with this name." }
  validates :price_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :stylist_id, presence: true

  scope :active,        -> { where(active: true) }
  scope :for_stylist,   ->(stylist_id) { where(stylist_id: stylist_id) }
  scope :main_services, -> { where(is_add_on: false) }
  scope :add_ons,       -> { where(is_add_on: true) }

  # Convert price from cents to dollars
  def price
    price_cents&./(100.0)
  end

  # Set price in dollars (stored as cents)
  def price=(dollars)
    self.price_cents = (dollars.to_f * 100).round if dollars.present?
  end
end
