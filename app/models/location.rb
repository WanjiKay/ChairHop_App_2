class Location < ApplicationRecord
  belongs_to :user
  has_many :appointments
  has_many :availability_blocks, dependent: :restrict_with_error

  validates :name, presence: true
  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true, length: { is: 2 }
  validates :zip_code, presence: true

  # Display full address
  def full_address
    [street_address, city, state, zip_code].compact.join(', ')
  end

  # Short display
  def short_address
    "#{city}, #{state}"
  end
end
