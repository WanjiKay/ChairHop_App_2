# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Appointment.destroy_all
User.destroy_all
# ----------------------------
# Create a Stylist User
# ----------------------------
stylist_user = User.create!(
  email: "chico@example.com",
  password: "password"
)

# ----------------------------
# Create a Customer User
# ----------------------------
customer_user = User.create!(
  email: "customer@example.com",
  password: "password"
)

# ----------------------------
# Create an Appointment
# ----------------------------
Appointment.create!(
  time: Time.current + 3.hours,
  location: "Brows and Locks Salon",
  booked: false,
  content: "Mama said the works, darling! (wash, cut, colour, style, and face)",
  customer: customer_user,
  stylist: stylist_user
)
