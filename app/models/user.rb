class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum role: {
    customer: 0,
    stylist: 1,
    admin: 2
  }

  has_many :appointments_as_customer, class_name: "Appointment", foreign_key: :customer_id, dependent: :nullify
  has_many :appointments_as_stylist, class_name: "Appointment", foreign_key: :stylist_id, dependent: :nullify
  has_many :chats, foreign_key: :customer_id, dependent: :destroy
  has_many :conversations_as_customer, class_name: "Conversation", foreign_key: :customer_id, dependent: :nullify
  has_many :conversations_as_stylist,  class_name: "Conversation", foreign_key: :stylist_id, dependent: :nullify

  has_many :reviews_for_stylist, class_name: "Review", foreign_key: :stylist_id, dependent: :nullify
  has_many :reviews_by_customer, class_name: "Review", foreign_key: :customer_id, dependent: :nullify

  has_many :services, foreign_key: :stylist_id, dependent: :destroy

  has_one_attached :avatar

  # Validate avatar file upload
  validate :avatar_validation

  private

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
