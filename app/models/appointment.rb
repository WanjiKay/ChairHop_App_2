class Appointment < ApplicationRecord
  belongs_to :customer,class_name: "User", optional: true
  belongs_to :stylist, class_name: "User"
  has_many :chats, dependent: :nullify
  has_one :conversation, dependent: :nullify
  has_one :review, dependent: :destroy
  has_one_attached :image
  validate :user_cannot_book_multiple, on: :update

  validates :time, presence: true
  validates :location, presence: true

  private

  def user_cannot_book_multiple
    if booked && customer && customer.appointments_as_stylist.where(booked: true).where.not(id: id).exists?
      errors.add(:base, "Honey, you can't sit in two chairs at once!")
    end
  end
end
