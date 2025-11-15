class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :appointments_as_customer, class_name: "Appointment", foreign_key: :customer_id, dependent: :nullify
  has_many :appointments_as_stylist, class_name: "Appointment", foreign_key: :stylist_id, dependent: :nullify
  has_many :chats
  has_many :conversations_as_customer, class_name: "Conversation", foreign_key: :customer_id, dependent: :nullify
  has_many :conversations_as_stylist,  class_name: "Conversation", foreign_key: :stylist_id, dependent: :nullify

  has_many :reviews_for_stylist, class_name: "Review", foreign_key: :stylist_id, dependent: :nullify

  has_one_attached :avatar
end
