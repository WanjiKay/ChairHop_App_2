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

# -----------------------------------------
# SALON-SPECIFIC DESCRIPTIONS (appointment.content)
# -----------------------------------------
salon_descriptions = {
  "Brows and Locks Salon" => <<~TEXT,
    Brows and Locks Salon specializes in precision cuts, glossy blowouts,
    hair coloring, and brow shaping. We combine modern techniques with
    luxury hair treatments to give clients a polished, camera-ready look.
    Choose from the available services listed below.
  TEXT

  "Chic Studio" => <<~TEXT,
    Chic Studio is known for high-end coloring, balayage, and modern
    layered cuts. Our stylists are trained in runway-inspired styling
    and soft glam finishing. Select a service from our menu below.
  TEXT

  "Glow Lounge" => <<~TEXT,
    Glow Lounge focuses on protective styles, natural hair treatments,
    silk presses, and scalp health. Our team specializes in textured hair
    and long-lasting styles. Pick your desired service from our offerings.
  TEXT

  "Downtown Cuts" => <<~TEXT,
    Downtown Cuts offers sharp fades, beard detailing, clipper precision,
    and classic barbering with a modern twist. Choose from the services
    listed below to complete your appointment.
  TEXT
}

# -----------------------------------------
# SERVICE LIST (stored in appointments.services)
# -----------------------------------------
service_list = [
  { name: "Wash & Blowout", price: 35 },
  { name: "Women's Cut", price: 45 },
  { name: "Men's Cut / Fade", price: 30 },
  { name: "Color Treatment", price: 90 },
  { name: "Highlights", price: 120 },
  { name: "Protective Braids", price: 80 },
  { name: "Silk Press", price: 60 },
  { name: "Loc Maintenance", price: 75 },
  { name: "Kids Cut", price: 20 }
]

services_text = service_list.map { |s| "#{s[:name]} - $#{s[:price]}" }.join("\n")

# -----------------------------------------
# STYLIST USERS WITH SPECIALIZED PROFILES
# -----------------------------------------
stylists = [
  {
    name: "Chico",
    username: "chico_styles",
    location: "Montreal",
    about: "15 years of experience in luxury transformations, advanced coloring, and precision cutting. Known for dramatic before-and-after looks and editorial styling.",
    email: "chico@example.com"
  },
  {
    name: "Lana",
    username: "lana_braids",
    location: "Laval",
    about: "Specialist in protective styles with 10+ years focusing on knotless braids, twist variations, natural hair care, and gentle tension techniques.",
    email: "lana@example.com"
  },
  {
    name: "Marco",
    username: "marco_fades",
    location: "Montreal",
    about: "Professional barber with 12 years of experience in fades, barber designs, beard sculpting, and precision clipper work.",
    email: "marco@example.com"
  }
]

stylist_users = stylists.map do |s|
  User.create!(
    email: s[:email],
    password: "password",
    name: s[:name],
    username: s[:username],
    location: s[:location],
    about: s[:about]
  )
end

# -----------------------------------------
# CUSTOMERS (NO ABOUT FIELD)
# -----------------------------------------
customer_users = 10.times.map do |i|
  User.create!(
    email: "customer#{i + 1}@example.com",
    password: "password",
    name: "Customer #{i + 1}",
    username: "customer#{i + 1}",
    location: ["Montreal", "Laval", "Longueuil"].sample
  )
end

# -----------------------------------------
# SALON ADDRESSES
# -----------------------------------------
salon_locations = {
  "Brows and Locks Salon" => "1450 St-Catherine St W, Montreal",
  "Chic Studio"           => "210 Boulevard des Laurentides, Laval",
  "Glow Lounge"           => "980 Sherbrooke St W, Montreal",
  "Downtown Cuts"         => "75 Rue Saint-Paul O, Montreal"
}

# -----------------------------------------
# 30 APPOINTMENTS — USING salon + location
# -----------------------------------------
salon_names = salon_descriptions.keys

30.times do
  salon = salon_names.sample

  Appointment.create!(
    time: Time.current + rand(1..24).hours,
    salon: salon,                                 # SALON NAME
    location: salon_locations[salon],             # ADDRESS
    booked: false,
    content: salon_descriptions[salon],           # Salon-specific description
    services: services_text,                      # List of services + prices
    customer: customer_users.sample,
    stylist: stylist_users.sample
  )
end

puts "Seed complete: #{stylist_users.count} stylists, #{customer_users.count} customers, and 30 diverse appointments created."
