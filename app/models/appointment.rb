class Appointment < ApplicationRecord
  belongs_to :customer,class_name: "User", optional: true
  belongs_to :stylist, class_name: "User"
  has_many :chats, dependent: :nullify
  has_one :conversation, dependent: :nullify
  has_one :review, dependent: :destroy
  has_many :appointment_add_ons, dependent: :destroy
  has_one_attached :image
  has_neighbors :embedding
  after_create :set_embedding
  validate :user_cannot_book_multiple, on: :update

  validates :time, presence: true
  validates :location, presence: true

  enum status: {
    pending: 0,
    booked: 1,
    completed: 2,
    cancelled: 3
  }

  SALON_ADD_ONS = {
    "Glow Lounge" => [
      "Scalp Massage - $15",
      "Scalp Treatment - $25",
      "Deep Conditioning Treatment - $20",
      "Hair Mask - $22",
      "Hot Oil Treatment - $15",
      "Hair Steaming - $18",
      "Split-End Repair Treatment - $18",
      "Bond Builder Treatment (Olaplex, K18) - $45",
      "Toning / Gloss Refresh - $25"
    ],
    "Brows and Locks Salon" => [
      "Deep Conditioning Treatment - $20",
      "Scalp Treatment - $25",
      "Split-End Repair Treatment - $18",
      "Hair Mask - $22",
      "Olaplex Treatment - $35",
      "Keratin Smoothing Add-On - $40",
      "Toning / Gloss Refresh - $25",
      "Hot Oil Treatment - $15",
      "Hair Steaming - $18",
      "Extra-Long or Thick-Hair Charge - $15",
      "Curl Definition Add-On - $20"
    ],
    "Chic Studio" => [
      "Olaplex Treatment - $35",
      "Hair Mask - $22",
      "Deep Conditioning Treatment - $20",
      "Split-End Repair Treatment - $18",
      "Keratin Smoothing Add-On - $40",
      "Toning / Gloss Refresh - $25",
      "Hot Oil Treatment - $15",
      "Scalp Treatment - $25",
      "Hair Steaming - $18",
      "Extra-Long or Thick-Hair Charge - $15",
      "Curl Definition Add-On - $20",
      "Bond Builder Treatment (Olaplex, K18) - $45"
    ],
    "Downtown Cuts" => [
      "Beard Trim - $10",
      "Beard Line-Up - $8",
      "Razor Shape-Up - $10",
      "Neck Razor Shave - $12",
      "Beard Conditioning - $12",
      "Hot Towel Treatment - $5",
      "Hair Wash / Shampoo - $8",
      "Scalp Massage - $15"
    ]
  }.freeze

  # Default add-ons for salons not in the list
  DEFAULT_ADD_ONS = [
    "Scalp Massage - $15",
    "Hair Wash / Shampoo - $8",
    "Deep Conditioning Treatment - $20",
    "Hot Towel Treatment - $5"
  ].freeze

  def relevant_add_ons
    SALON_ADD_ONS[salon] || DEFAULT_ADD_ONS
  end

  def total_add_ons_price
    appointment_add_ons.sum(:price)
  end

  def base_service_price
    selected_service ? selected_service.split(" - $").last.to_f : 0
  end

  def total_price
    base_service_price + total_add_ons_price
  end

  def accept!
    return false unless pending?
    self.status = :booked
    self.booked = true
    save
  end

  def cancel!
    self.status = :cancelled
    self.booked = false
    self.customer = nil
    save
  end

  private

  def set_embedding
    embedding = RubyLLM.embed("Time: #{time}.
    Booked: #{booked}.
    Location #{location}.
    Stylist: #{stylist.name}.
    Services: #{services}.")
    update(embedding: embedding.vectors)
  rescue => e
    # Silently skip embedding if API is not configured or rate limit is hit
    Rails.logger.warn "Skipping embedding for appointment #{id}: #{e.message}"
  end

  def user_cannot_book_multiple
    if booked && customer && customer.appointments_as_customer.where(booked: true).where.not(id: id).exists?
      errors.add(:base, "Honey, you can't sit in two chairs at once!")
    end
  end
end
