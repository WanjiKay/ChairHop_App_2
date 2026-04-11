class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    customer: 0,
    stylist: 1,
    admin: 2
  }

  has_many :appointments_as_customer, class_name: "Appointment", foreign_key: :customer_id, dependent: :nullify
  has_many :appointments,             class_name: "Appointment", foreign_key: :customer_id
  has_many :appointments_as_stylist,  class_name: "Appointment", foreign_key: :stylist_id,  dependent: :nullify
  has_many :chats, foreign_key: :customer_id, dependent: :destroy
  has_many :conversations_as_customer, class_name: "Conversation", foreign_key: :customer_id, dependent: :nullify
  has_many :conversations_as_stylist,  class_name: "Conversation", foreign_key: :stylist_id, dependent: :nullify

  has_many :reviews_for_stylist, class_name: "Review", foreign_key: :stylist_id, dependent: :nullify
  has_many :reviews_by_customer, class_name: "Review", foreign_key: :customer_id, dependent: :nullify

  has_many :services, foreign_key: :stylist_id, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :availability_blocks, foreign_key: :stylist_id, dependent: :destroy
  has_one_attached :avatar
  has_many_attached :portfolio_photos

  before_create :default_role
  before_create :generate_booking_slug

  validates :name, presence: true
  validates :booking_slug, uniqueness: true, allow_nil: true

  # Validate avatar file upload
  validate :avatar_validation
  validate :portfolio_photo_limit

  def portfolio_photo_limit
    if portfolio_photos.length > 12
      errors.add(:portfolio_photos, "You can attach a maximum of 12 portfolio photos.")
    end
  end

  # Build full address for geocoding
  def full_address
    [street_address, city, state, zip_code].compact_blank.join(', ')
  end

  # Comma-separated unique cities from the stylist's location records
  def location_cities
    locations.map(&:city).compact.uniq.join(", ")
  end

  # Name + city for each location: "Glam Studio · San Francisco, Curl Bar · Oakland"
  def location_display
    locations.map { |l| [l.name, l.city].compact.join(" · ") }.uniq.join(", ")
  end

  # Check if any address field changed
  def address_changed?
    street_address_changed? || city_changed? || state_changed? || zip_code_changed?
  end

  def onboarding_complete?
    return true if customer?

    # Avatar temporarily optional until Cloudinary permissions are resolved
    about.present? && about.length >= 50 &&
      services.any? &&
      locations.any?
  end

  def mark_onboarding_complete!
    update(onboarding_completed_at: Time.current) if onboarding_complete?
  end

  # TODO: run 'rails db:encryption:init' and add the output to credentials.yml.enc before deploying.
  # WARNING: Existing plain-text tokens in the DB will become unreadable after enabling encryption.
  #          Stylists will need to reconnect their Square account after this change is deployed.
  encrypts :square_access_token,  deterministic: false
  encrypts :square_refresh_token, deterministic: false

  def square_connected?
    square_access_token.present? &&
      square_merchant_id.present? &&
      square_location_id.present?
  end

  def disconnect_square!
    update(
      square_access_token:  nil,
      square_refresh_token: nil,
      square_merchant_id:   nil,
      square_location_id:   nil,
      square_connected_at:  nil
    )
  end

  def can_accept_bookings?
    onboarding_complete? && square_connected?
  end

  def ensure_booking_slug!
    return if booking_slug.present?
    generate_booking_slug
    save(validate: false)
  end

  private

  def default_role
    self.role ||= :customer
  end

  def generate_booking_slug
    return if booking_slug.present?
    base = name.to_s.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '-').strip
    base = 'stylist' if base.blank?
    slug = base
    counter = 1
    while User.where(role: :stylist).exists?(booking_slug: slug)
      slug = "#{base}-#{counter}"
      counter += 1
    end
    self.booking_slug = slug
  end

  def avatar_validation
    return unless avatar.attached?

    unless avatar.content_type.in?(['image/png', 'image/jpeg', 'image/jpg', 'image/webp'])
      errors.add(:avatar, 'must be a PNG, JPEG, JPG, or WEBP image')
    end

    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, 'must be less than 5MB')
    end
  end
end
