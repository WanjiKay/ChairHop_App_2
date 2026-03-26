class QuickBooksToken < ApplicationRecord
  belongs_to :user

  validates :access_token, presence: true
  validates :refresh_token, presence: true
  validates :realm_id, presence: true
  validates :expires_at, presence: true

  # Check if token is expired or will expire soon (within 10 minutes)
  def expired?
    expires_at <= Time.current + 10.minutes
  end
end
