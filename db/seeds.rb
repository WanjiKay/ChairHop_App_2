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

# Clean up seed data but preserve customer bookings and their users
puts "Cleaning up old seed data while preserving customer appointments..."

# Find appointments that belong to customers (booked or have a customer assigned)
customer_appointments = Appointment.where.not(customer_id: nil)
customer_appointment_ids = customer_appointments.pluck(:id)

# Find users who are customers (have made appointments)
customer_user_ids = customer_appointments.pluck(:customer_id).uniq

# Find stylists who have customer appointments (preserve them too)
stylist_user_ids = customer_appointments.pluck(:stylist_id).uniq

# Preserve these users
preserved_user_ids = (customer_user_ids + stylist_user_ids).uniq

puts "Preserving #{customer_appointments.count} customer appointments and #{preserved_user_ids.count} users..."

# Only destroy conversations/messages for appointments we're deleting
ConversationMessage.joins(:conversation).where.not(conversations: { appointment_id: customer_appointment_ids }).destroy_all
Conversation.where.not(appointment_id: customer_appointment_ids).destroy_all

# Only destroy chats and messages that don't belong to preserved customers
Message.joins(:chat).where.not(chats: { customer_id: customer_user_ids }).destroy_all
Chat.where.not(customer_id: customer_user_ids).destroy_all

# Only destroy reviews for appointments we're deleting
Review.where.not(appointment_id: customer_appointment_ids).destroy_all

# Only destroy appointments without customers (unbooked seed appointments)
Appointment.where(customer_id: nil).destroy_all

# Only destroy users who are not preserved (not customers or stylists with customer appointments)
User.where.not(id: preserved_user_ids).destroy_all
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
service_list = {
  braids:                { name: "Protective Braids", price: 80 },
  silk_press:            { name: "Silk Press", price: 60 },
  wash_and_go:            { name: "Wash & Go", price: 80 },
  loc_maintenance:       { name: "Loc Maintenance", price: 75 },
  womens_cut:            { name: "Women's Cut", price: 45 },
  mens_fade:             { name: "Men's Cut / Fade", price: 30 },
  wash_blow:             { name: "Wash & Blowout", price: 35 },
  kids_cut:              { name: "Kids Cut", price: 20 },
  color:                 { name: "Color Treatment", price: 90 },
  highlights:            { name: "Highlights", price: 120 }
}
salon_services = {
  "Glow Lounge" => [
    service_list[:braids],
    service_list[:wash_and_go],
    service_list[:silk_press],
    service_list[:loc_maintenance],
    service_list[:womens_cut]
  ],

  "Brows and Locks Salon" => [
    service_list[:wash_blow],
    service_list[:color],
    service_list[:highlights],
    service_list[:womens_cut]
  ],

  "Chic Studio" => [
    service_list[:color],
    service_list[:highlights],
    service_list[:womens_cut],
    service_list[:wash_blow]
  ],

  "Downtown Cuts" => [
    service_list[:mens_fade],
    service_list[:kids_cut],
    service_list[:wash_blow]
  ]
}

def service_text(list)
  list.map { |s| "#{s[:name]} - $#{s[:price]}" }.join("\n")
end
# -----------------------------------------
# STYLIST USERS WITH SPECIALIZED PROFILES
# -----------------------------------------
stylists = [
  {
    name: "Tilly",
    username: "tilly_browslocks",
    location: "Montreal",
    about: "Cut, color, brows, and glossy blowout specialist.",
    email: "tilly@example.com",
    salon: "Brows and Locks Salon"
  },
  {
    name: "Chico",
    username: "chico_styles",
    location: "Montreal",
    about: "Luxury coloring + precision cutting expert.",
    email: "chico@example.com",
    salon: "Chic Studio"
  },
  {
    name: "Lana",
    username: "lana_braids",
    location: "Laval",
    about: "Specialist in protective styles with 10+ years focusing on knotless braids, twist variations, natural hair care, and gentle tension techniques.",
    email: "lana@example.com",
     salon: "Glow Lounge"
  },
  {
    name: "Marco",
    username: "marco_fades",
    location: "Montreal",
    about: "Professional barber with 12 years of experience in fades, barber designs, beard sculpting, and precision clipper work.",
    email: "marco@example.com",
    salon: "Downtown Cuts"
  }
]

stylist_avatar = ["https://images.unsplash.com/photo-1676340619040-8688de9fd331?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D","https://images.unsplash.com/photo-1639747280804-dd2d6b3d88ac?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D","https://images.unsplash.com/photo-1650050594038-55b4c4a86cc2?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D","https://images.unsplash.com/photo-1654110455429-cf322b40a906?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"]

i=0
stylist_salon_map = {}
stylist_users = stylists.map do |s|
    stylist = User.new(
    email: s[:email],
    password: "password",
    name: s[:name],
    username: s[:username],
    location: s[:location],
    about: s[:about],
  )
 file = URI.parse(stylist_avatar[i]).open
  stylist.avatar.attach(io: file, filename: "nes.png", content_type: "image/png")
  stylist.save!
 stylist_salon_map[stylist.id] = s[:salon]

  i = i + 1
  stylist
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
# 12 APPOINTMENTS — USING salon + location
# -----------------------------------------

# -----------------------------------------
# SALON-SPECIFIC IMAGE MAPPING
# -----------------------------------------
salon_specific_images = {
  "Brows and Locks Salon" => [
    "https://images.unsplash.com/photo-1634449571010-02389ed0f9b0?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",  # Hair washing service
    "https://images.unsplash.com/photo-1560869713-7d0a29430803?q=80&w=926&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",   # Curling iron styling
    "https://plus.unsplash.com/premium_photo-1669675935927-0ed8935e6600?q=80&w=988&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"  # Precision cutting
  ],
  "Chic Studio" => [
    "https://images.unsplash.com/photo-1633681926035-ec1ac984418a?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",  # Luxury modern salon
    "https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",  # Chic salon interior
    "https://images.unsplash.com/photo-1600948836101-f9ffda59d250?q=80&w=1736&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"   # High-end dark salon
  ],
  "Glow Lounge" => [
    "https://images.unsplash.com/photo-1595475884562-073c30d45670?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",  # Styling tools array
    "https://images.unsplash.com/photo-1637777269327-c4d5c7944d7b?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",   # Salon wash stations
    "https://plus.unsplash.com/premium_photo-1664544673201-9f1809938ddd?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"   # Wooden combs
  ],
  "Downtown Cuts" => [
    "https://images.unsplash.com/photo-1626379501846-0df4067b8bb9?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",  # Modern salon interior
    "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&w=988&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",   # Barber fade cut
    "https://images.unsplash.com/photo-1614438865362-9137f7e3036e?q=80&w=2069&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"   # Minimalist barbershop
  ]
}

salon_names = salon_descriptions.keys

# Create 3 appointments per salon with salon-specific images
# Track appointments created to avoid rate limiting (15 per 60s)
appointments_created = 0

salon_names.each do |salon|
  salon_images = salon_specific_images[salon]

  # Create 3 appointments: 1 morning, 2 afternoon
  appointment_times = []

  # 1 morning appointment (7 AM - 12 PM)
  appointment_times << { period: 'morning', hour_range: (7..11) }

  # 2 afternoon appointments (1 PM - 9 PM)
  2.times { appointment_times << { period: 'afternoon', hour_range: (13..20) } }

  appointment_times.each_with_index do |time_slot, idx|
    # 50/50 chance of today or tomorrow
    day_offset = [0, 1].sample
    base_date = Time.zone.today + day_offset

    loop do
      appointment_time = Time.zone.local(
        base_date.year,
        base_date.month,
        base_date.day,
        rand(time_slot[:hour_range]),         # Use specific hour range
        [0, 15, 30, 45].sample                # quarter hours
      )

      # Make sure appointment is in the future
      if appointment_time > Time.current
        @appointment_time = appointment_time
        break
      end
    end

    appointment = Appointment.new(
      time: @appointment_time,
      salon: salon,
      location: salon_locations[salon],
      booked: false,
      content: salon_descriptions[salon],
      services: service_text(salon_services[salon]),
      customer: nil,
      stylist: stylist_users.select { |u| stylist_salon_map[u.id] == salon }.sample
    )

    file = URI.parse(salon_images[idx % salon_images.length]).open
    appointment.image.attach(io: file, filename: "nes.png", content_type: "image/png")
    appointment.save!

    appointments_created += 1
  end
end
puts "Seed complete: #{stylist_users.count} stylists, #{customer_users.count} customers, and #{appointments_created} diverse appointments created."
