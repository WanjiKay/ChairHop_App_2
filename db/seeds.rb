# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "open-uri"

Chat.destroy_all
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
images = ["https://images.unsplash.com/photo-1633681926035-ec1ac984418a?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://images.unsplash.com/photo-1634449571010-02389ed0f9b0?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://images.unsplash.com/photo-1560869713-7d0a29430803?q=80&w=926&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
"https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://images.unsplash.com/photo-1595475884562-073c30d45670?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://images.unsplash.com/photo-1637777269327-c4d5c7944d7b?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
"https://images.unsplash.com/photo-1600948836101-f9ffda59d250?q=80&w=1736&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://plus.unsplash.com/premium_photo-1664544673201-9f1809938ddd?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://images.unsplash.com/photo-1626379501846-0df4067b8bb9?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
"https://plus.unsplash.com/premium_photo-1669675935927-0ed8935e6600?q=80&w=988&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&w=988&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", "https://images.unsplash.com/photo-1614438865362-9137f7e3036e?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
"https://images.unsplash.com/photo-1581404788767-726320400cea?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"]
i = 0
12.times do
  salon = salon_names.sample
  appointment = Appointment.new(
    time: Time.current + rand(1..24).hours,
    salon: salon,                                 # SALON NAME
    location: salon_locations[salon],             # ADDRESS
    booked: false,
    content: salon_descriptions[salon],           # Salon-specific description
    services: services_text,                      # List of services + prices
    customer: customer_users.sample,
    stylist: stylist_users.sample,
    )
  file = URI.parse(images[i]).open
  appointment.image.attach(io: file, filename: "nes.png", content_type: "image/png")
  appointment.save
  i = i + 1
  end
puts "Seed complete: #{stylist_users.count} stylists, #{customer_users.count} customers, and 30 diverse appointments created."
