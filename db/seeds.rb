puts "Seeding ChairHop database..."

ActiveRecord::Base.transaction do
  # ============================================
  # CLEAR EXISTING DATA (FK-safe order)
  # ============================================
  puts "Clearing existing data..."
  ConversationMessage.destroy_all
  Conversation.destroy_all
  Message.destroy_all
  Chat.destroy_all
  Review.destroy_all
  AppointmentAddOn.destroy_all
  Appointment.destroy_all
  AvailabilityBlock.destroy_all
  Service.destroy_all
  Location.destroy_all
  User.destroy_all
  puts "   Done."

  # ============================================
  # STYLISTS
  # ============================================
  puts "Creating stylists..."

  maya = User.create!(
    email:                   "maya@example.com",
    password:                "password123",
    name:                    "Maya Johnson",
    username:                "maya_glow",
    about:                   "Natural hair specialist with 9 years of experience in silk presses, protective styles, and scalp health. I celebrate the beauty and versatility of textured hair and help every client leave feeling their best.",
    role:                    :stylist,
    onboarding_completed_at: Time.current
  )

  derek = User.create!(
    email:                   "derek@example.com",
    password:                "password123",
    name:                    "Derek Kim",
    username:                "derek_cuts",
    about:                   "Precision barber with 11 years of experience in fades, tapers, beard sculpting, and classic barbering. Known for clean lines, consistent results, and a relaxed chair-side manner every visit.",
    role:                    :stylist,
    onboarding_completed_at: Time.current
  )

  sofia = User.create!(
    email:                   "sofia@example.com",
    password:                "password123",
    name:                    "Sofia Rivera",
    username:                "sofia_color",
    about:                   "Color specialist with 7 years of experience in balayage, highlights, and full-color transformations. I use only premium, low-damage products for stunning, long-lasting results that clients love.",
    role:                    :stylist,
    onboarding_completed_at: Time.current
  )

  puts "   Created #{User.stylist.count} stylists."

  # ============================================
  # CUSTOMERS
  # ============================================
  puts "Creating customers..."

  emma   = User.create!(email: "emma@example.com",   password: "password123", name: "Emma Wilson",  username: "emma_w",    role: :customer)
  james  = User.create!(email: "james@example.com",  password: "password123", name: "James Carter", username: "james_c",   role: :customer)
  priya  = User.create!(email: "priya@example.com",  password: "password123", name: "Priya Patel",  username: "priya_p",   role: :customer)
  marcus = User.create!(email: "marcus@example.com", password: "password123", name: "Marcus Lee",   username: "marcus_l",  role: :customer)
  olivia = User.create!(email: "olivia@example.com", password: "password123", name: "Olivia Chen",  username: "olivia_c",  role: :customer)
  tyler  = User.create!(email: "tyler@example.com",  password: "password123", name: "Tyler Brooks", username: "tyler_b",   role: :customer)
  zoe    = User.create!(email: "zoe@example.com",    password: "password123", name: "Zoe Williams", username: "zoe_w",     role: :customer)

  puts "   Created #{User.customer.count} customers."

  # ============================================
  # LOCATIONS
  # ============================================
  puts "Creating locations..."

  maya_loc1 = Location.create!(
    user: maya, name: "Glow Studio",
    street_address: "1842 Fillmore St", city: "San Francisco", state: "CA", zip_code: "94115"
  )

  maya_loc2 = Location.create!(
    user: maya, name: "Glow Studio Mission",
    street_address: "3390 18th St", city: "San Francisco", state: "CA", zip_code: "94110"
  )

  derek_loc = Location.create!(
    user: derek, name: "Sharp Cuts Brooklyn",
    street_address: "456 Bedford Ave", city: "Brooklyn", state: "NY", zip_code: "11211"
  )

  sofia_loc = Location.create!(
    user: sofia, name: "Chic Color Bar",
    street_address: "2104 S Lamar Blvd", city: "Austin", state: "TX", zip_code: "78704"
  )

  puts "   Created #{Location.count} locations."

  # ============================================
  # SERVICES
  # ============================================
  puts "Creating services..."

  # Maya — Glow Studio (natural/textured hair)
  maya_silk_press   = Service.create!(stylist: maya, name: "Silk Press",                  price_cents: 6500,  duration_minutes: 75,  active: true, is_add_on: false, description: "Silky straight finish for natural hair using low-heat pressing technique")
  maya_braids       = Service.create!(stylist: maya, name: "Protective Braids",           price_cents: 8500,  duration_minutes: 120, active: true, is_add_on: false, description: "Knotless box braids or twist variations, all lengths")
  maya_wash_go      = Service.create!(stylist: maya, name: "Wash & Go",                   price_cents: 7000,  duration_minutes: 90,  active: true, is_add_on: false, description: "Clarifying wash, deep condition, and curl definition for natural hair")
  maya_consultation = Service.create!(stylist: maya, name: "Hair Health Consultation",    price_cents: 4000,  duration_minutes: 45,  active: true, is_add_on: false, description: "One-on-one session for hair routine, scalp health, and product guidance")
  Service.create!(stylist: maya, name: "Deep Conditioning Treatment", price_cents: 2000,  duration_minutes: 20, active: true, is_add_on: true, description: "Intensive moisture treatment added to any service")
  Service.create!(stylist: maya, name: "Scalp Massage",               price_cents: 1500,  duration_minutes: 15, active: true, is_add_on: true, description: "Relaxing scalp massage with essential oils")
  Service.create!(stylist: maya, name: "Hair Mask",                   price_cents: 2200,  duration_minutes: 15, active: true, is_add_on: true, description: "Protein or moisture-based restorative hair mask")

  # Derek — Sharp Cuts Brooklyn (barbershop)
  derek_fade    = Service.create!(stylist: derek, name: "Men's Fade",      price_cents: 3500,  duration_minutes: 40, active: true, is_add_on: false, description: "Precision skin or low fade with sharp line-up")
  derek_cut     = Service.create!(stylist: derek, name: "Classic Cut",     price_cents: 2800,  duration_minutes: 35, active: true, is_add_on: false, description: "Scissors and clipper cut for any length")
  derek_kids    = Service.create!(stylist: derek, name: "Kids Cut",        price_cents: 2000,  duration_minutes: 30, active: true, is_add_on: false, description: "Cuts for children 12 and under, patient and thorough")
  derek_beard   = Service.create!(stylist: derek, name: "Beard Shape-Up",  price_cents: 2500,  duration_minutes: 25, active: true, is_add_on: false, description: "Full beard sculpt, oil, and precision line detailing")
  derek_shampoo = Service.create!(stylist: derek, name: "Shampoo & Style", price_cents: 4000,  duration_minutes: 45, active: true, is_add_on: false, description: "Shampoo, condition, and finished style")
  Service.create!(stylist: derek, name: "Hot Towel Treatment", price_cents: 800,   duration_minutes: 10, active: true, is_add_on: true, description: "Classic hot towel treatment for face and neck")
  Service.create!(stylist: derek, name: "Beard Conditioning",  price_cents: 1200,  duration_minutes: 10, active: true, is_add_on: true, description: "Softening conditioning and oil treatment for beard")
  Service.create!(stylist: derek, name: "Razor Line-Up",       price_cents: 1000,  duration_minutes: 10, active: true, is_add_on: true, description: "Straight-razor edge-up on hairline and sideburns")

  # Sofia — Chic Color Bar (color specialist)
  sofia_balayage    = Service.create!(stylist: sofia, name: "Balayage",            price_cents: 18000, duration_minutes: 180, active: true, is_add_on: false, description: "Hand-painted highlights for natural-looking dimension and depth")
  sofia_full_color  = Service.create!(stylist: sofia, name: "Full Color",          price_cents: 11000, duration_minutes: 120, active: true, is_add_on: false, description: "Root-to-tip single process color, all shades")
  sofia_cut         = Service.create!(stylist: sofia, name: "Women's Cut & Style", price_cents: 6500,  duration_minutes: 60,  active: true, is_add_on: false, description: "Precision cut and blowout finish")
  sofia_highlights  = Service.create!(stylist: sofia, name: "Highlights",          price_cents: 13000, duration_minutes: 150, active: true, is_add_on: false, description: "Foil highlights, partial or full coverage")
  Service.create!(stylist: sofia, name: "Keratin Treatment", price_cents: 20000, duration_minutes: 180, active: true, is_add_on: false, description: "Professional smoothing keratin treatment for frizz control")
  Service.create!(stylist: sofia, name: "Olaplex Treatment", price_cents: 3500,  duration_minutes: 20,  active: true, is_add_on: true,  description: "Bond-repairing Olaplex add-on for color services")
  Service.create!(stylist: sofia, name: "Toning Gloss",      price_cents: 2500,  duration_minutes: 20,  active: true, is_add_on: true,  description: "Gloss toner for shine and color refresh between appointments")
  Service.create!(stylist: sofia, name: "Deep Conditioning",  price_cents: 2000,  duration_minutes: 20,  active: true, is_add_on: true,  description: "Intensive deep conditioning treatment add-on")

  puts "   Created #{Service.where(is_add_on: false).count} main services, #{Service.where(is_add_on: true).count} add-ons."

  # ============================================
  # AVAILABILITY BLOCKS
  # ============================================
  puts "Creating availability blocks..."

  today = Date.today

  # Maya — 5 blocks across 2 locations over 2-3 weeks
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc1,
    start_time: (today + 2.days).beginning_of_day + 9.hours,
    end_time:   (today + 2.days).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc2,
    start_time: (today + 5.days).beginning_of_day + 10.hours,
    end_time:   (today + 5.days).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [maya_silk_press.id.to_s, maya_braids.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc1,
    start_time: (today + 9.days).beginning_of_day + 9.hours,
    end_time:   (today + 9.days).beginning_of_day + 14.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc2,
    start_time: (today + 14.days).beginning_of_day + 11.hours,
    end_time:   (today + 14.days).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [maya_wash_go.id.to_s, maya_consultation.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc1,
    start_time: (today + 18.days).beginning_of_day + 9.hours,
    end_time:   (today + 18.days).beginning_of_day + 16.hours,
    available_for_all_services: true
  )

  # Derek — 4 blocks
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 1.day).beginning_of_day + 8.hours,
    end_time:   (today + 1.day).beginning_of_day + 14.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 3.days).beginning_of_day + 9.hours,
    end_time:   (today + 3.days).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [derek_fade.id.to_s, derek_beard.id.to_s, derek_shampoo.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 8.days).beginning_of_day + 10.hours,
    end_time:   (today + 8.days).beginning_of_day + 18.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 13.days).beginning_of_day + 9.hours,
    end_time:   (today + 13.days).beginning_of_day + 15.hours,
    available_for_all_services: true
  )

  # Sofia — 3 blocks (longer sessions for color work)
  AvailabilityBlock.create!(
    stylist: sofia, location: sofia_loc,
    start_time: (today + 2.days).beginning_of_day + 10.hours,
    end_time:   (today + 2.days).beginning_of_day + 18.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: sofia, location: sofia_loc,
    start_time: (today + 7.days).beginning_of_day + 9.hours,
    end_time:   (today + 7.days).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [sofia_balayage.id.to_s, sofia_highlights.id.to_s, sofia_full_color.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: sofia, location: sofia_loc,
    start_time: (today + 15.days).beginning_of_day + 10.hours,
    end_time:   (today + 15.days).beginning_of_day + 18.hours,
    available_for_all_services: true
  )

  puts "   Created #{AvailabilityBlock.count} availability blocks."

  # ============================================
  # APPOINTMENTS
  # ============================================
  puts "Creating appointments..."

  # --- PENDING: 3 open slots (no customer) ---

  Appointment.create!(
    stylist:        maya,
    location_id:    maya_loc1.id,
    time:           (today + 4.days).beginning_of_day + 11.hours,
    salon:          "Glow Studio",
    status:         :pending,
    payment_status: "pending",
    content:        "Open slot for natural hair services. Silk Press, Wash & Go, and Protective Braids available."
  )

  Appointment.create!(
    stylist:        derek,
    location_id:    derek_loc.id,
    time:           (today + 3.days).beginning_of_day + 14.hours,
    salon:          "Sharp Cuts Brooklyn",
    status:         :pending,
    payment_status: "pending",
    content:        "Available for fades, cuts, and beard work. Booking preferred but walk-ins welcome if available."
  )

  Appointment.create!(
    stylist:        sofia,
    location_id:    sofia_loc.id,
    time:           (today + 6.days).beginning_of_day + 13.hours,
    salon:          "Chic Color Bar",
    status:         :pending,
    payment_status: "pending",
    content:        "Color session slot open. Balayage, highlights, and full color appointments available."
  )

  # --- BOOKED: 4 upcoming accepted appointments ---

  Appointment.create!(
    stylist:          maya,
    customer:         emma,
    location_id:      maya_loc1.id,
    time:             (today + 5.days).beginning_of_day + 10.hours,
    salon:            "Glow Studio",
    status:           :booked,
    selected_service: "Silk Press - $65.00",
    content:          "Emma wants a silky straight look for an upcoming wedding. She prefers medium heat and a light oil finish.",
    payment_amount:   32.50,
    payment_status:   "deposit_paid",
    payment_id:       "sq_test_bk001",
    payment_method:   "square"
  )

  Appointment.create!(
    stylist:          derek,
    customer:         james,
    location_id:      derek_loc.id,
    time:             (today + 4.days).beginning_of_day + 11.hours,
    salon:            "Sharp Cuts Brooklyn",
    status:           :booked,
    selected_service: "Men's Fade - $35.00",
    content:          "James wants a low fade with a sharp skin line-up. He keeps the top long with a textured finish.",
    payment_amount:   17.50,
    payment_status:   "deposit_paid",
    payment_id:       "sq_test_bk002",
    payment_method:   "square"
  )

  Appointment.create!(
    stylist:          sofia,
    customer:         priya,
    location_id:      sofia_loc.id,
    time:             (today + 7.days).beginning_of_day + 10.hours,
    salon:            "Chic Color Bar",
    status:           :booked,
    selected_service: "Balayage - $180.00",
    content:          "Priya wants warm honey-brown balayage on dark brown base. First time coloring — wants a subtle, natural look.",
    payment_amount:   90.00,
    payment_status:   "deposit_paid",
    payment_id:       "sq_test_bk003",
    payment_method:   "square"
  )

  Appointment.create!(
    stylist:          maya,
    customer:         olivia,
    location_id:      maya_loc2.id,
    time:             (today + 9.days).beginning_of_day + 14.hours,
    salon:            "Glow Studio Mission",
    status:           :booked,
    selected_service: "Protective Braids - $85.00",
    content:          "Olivia would like medium-length knotless box braids. Hair is pre-washed and stretched.",
    payment_amount:   42.50,
    payment_status:   "deposit_paid",
    payment_id:       "sq_test_bk004",
    payment_method:   "square"
  )

  # --- COMPLETED: 4 past appointments ---

  comp1 = Appointment.create!(
    stylist:            maya,
    customer:           marcus,
    location_id:        maya_loc1.id,
    time:               8.days.ago + 10.hours,
    salon:              "Glow Studio",
    status:             :completed,
    selected_service:   "Silk Press - $65.00",
    content:            "Marcus came in for a silk press ahead of a family gathering. He wanted a sleek, natural finish.",
    payment_amount:     65.00,
    payment_status:     "paid",
    payment_id:         "sq_test_cp001",
    balance_payment_id: "sq_test_bal001",
    payment_method:     "square"
  )

  comp2 = Appointment.create!(
    stylist:            derek,
    customer:           tyler,
    location_id:        derek_loc.id,
    time:               12.days.ago + 11.hours,
    salon:              "Sharp Cuts Brooklyn",
    status:             :completed,
    selected_service:   "Men's Fade - $35.00",
    content:            "Tyler wanted a fresh skin fade before a job interview. Requested a crisp line-up and temple taper.",
    payment_amount:     35.00,
    payment_status:     "paid",
    payment_id:         "sq_test_cp002",
    balance_payment_id: "sq_test_bal002",
    payment_method:     "square"
  )

  comp3 = Appointment.create!(
    stylist:            sofia,
    customer:           zoe,
    location_id:        sofia_loc.id,
    time:               15.days.ago + 14.hours,
    salon:              "Chic Color Bar",
    status:             :completed,
    selected_service:   "Full Color - $110.00",
    content:            "Zoe wanted a rich auburn full color. Her base was medium brown and she wanted a bold change.",
    payment_amount:     110.00,
    payment_status:     "paid",
    payment_id:         "sq_test_cp003",
    balance_payment_id: "sq_test_bal003",
    payment_method:     "square"
  )

  comp4 = Appointment.create!(
    stylist:            derek,
    customer:           emma,
    location_id:        derek_loc.id,
    time:               21.days.ago + 9.hours,
    salon:              "Sharp Cuts Brooklyn",
    status:             :completed,
    selected_service:   "Classic Cut - $28.00",
    content:            "Emma stopped in for a trim and clean-up. Requested layers taken off the ends.",
    payment_amount:     28.00,
    payment_status:     "paid",
    payment_id:         "sq_test_cp004",
    balance_payment_id: "sq_test_bal004",
    payment_method:     "square"
  )

  completed_appointments = [comp1, comp2, comp3, comp4]

  # --- CANCELLED: 2 past appointments ---

  Appointment.create!(
    stylist:             sofia,
    customer:            marcus,
    location_id:         sofia_loc.id,
    time:                10.days.ago + 13.hours,
    salon:               "Chic Color Bar",
    status:              :cancelled,
    selected_service:    "Highlights - $130.00",
    content:             "Marcus booked highlights but cancelled due to a scheduling conflict.",
    payment_amount:      65.00,
    payment_status:      "refunded",
    payment_id:          "sq_test_cn001",
    payment_method:      "square",
    cancelled_by:        "customer",
    cancelled_at:        11.days.ago + 9.hours,
    cancelled_by_id:     marcus.id,
    cancellation_reason: "Unexpected work conflict — can't make the appointment."
  )

  Appointment.create!(
    stylist:             maya,
    customer:            james,
    location_id:         maya_loc1.id,
    time:                5.days.ago + 11.hours,
    salon:               "Glow Studio",
    status:              :cancelled,
    selected_service:    "Wash & Go - $70.00",
    content:             "James booked a wash and go but cancelled within the 24-hour window.",
    payment_amount:      35.00,
    payment_status:      "deposit_kept",
    payment_id:          "sq_test_cn002",
    payment_method:      "square",
    cancelled_by:        "customer",
    cancelled_at:        5.days.ago + 3.hours,
    cancelled_by_id:     james.id,
    cancellation_reason: "Plans changed at the last minute."
  )

  puts "   Pending:   #{Appointment.pending.count}"
  puts "   Booked:    #{Appointment.booked.count}"
  puts "   Completed: #{Appointment.completed.count}"
  puts "   Cancelled: #{Appointment.cancelled.count}"

  # ============================================
  # REVIEWS (completed appointments only)
  # ============================================
  puts "Creating reviews..."

  Review.create!(
    appointment: comp1,
    customer:    marcus,
    stylist:     maya,
    rating:      5,
    content:     "Maya is incredibly talented and my hair came out absolutely flawless. The silk press lasted all week without a hint of frizz. I've already booked my next appointment — she's the only stylist I trust with my hair."
  )

  Review.create!(
    appointment: comp2,
    customer:    tyler,
    stylist:     derek,
    rating:      5,
    content:     "Derek delivered exactly the clean fade I was looking for. The line-up was laser-sharp and the whole experience was quick and professional. Walked out feeling 100% ready for my interview and got the job!"
  )

  Review.create!(
    appointment: comp3,
    customer:    zoe,
    stylist:     sofia,
    rating:      4,
    content:     "Sofia did a gorgeous job on my auburn color — the depth and shine are exactly what I wanted. The session ran a bit longer than expected but she kept me comfortable throughout. Absolutely worth it."
  )

  Review.create!(
    appointment: comp4,
    customer:    emma,
    stylist:     derek,
    rating:      3,
    content:     "The cut was clean and Derek was friendly and easy to talk to. It felt a bit rushed near the end and I had to ask for a small adjustment, but overall I'm satisfied with how it looks."
  )

  puts "   Created #{Review.count} reviews."

  # ============================================
  # SUMMARY
  # ============================================
  puts ""
  puts "=" * 60
  puts " ChairHop Seed Complete"
  puts "=" * 60
  puts " Users:          #{User.count}"
  puts "   Stylists:     #{User.stylist.count}"
  puts "   Customers:    #{User.customer.count}"
  puts " Locations:      #{Location.count}"
  puts " Services:       #{Service.count} (#{Service.where(is_add_on: false).count} main, #{Service.where(is_add_on: true).count} add-ons)"
  puts " Avail. Blocks:  #{AvailabilityBlock.count}"
  puts " Appointments:   #{Appointment.count}"
  puts "   Pending:      #{Appointment.pending.count}"
  puts "   Booked:       #{Appointment.booked.count}"
  puts "   Completed:    #{Appointment.completed.count}"
  puts "   Cancelled:    #{Appointment.cancelled.count}"
  puts " Reviews:        #{Review.count}"
  puts "=" * 60
  puts ""
  puts " Test accounts  (password: password123)"
  puts ""
  puts " Stylists — Square NOT connected (connect via dashboard to book):"
  puts "   maya@example.com   — Glow Studio, San Francisco CA"
  puts "   derek@example.com  — Sharp Cuts, Brooklyn NY"
  puts "   sofia@example.com  — Chic Color Bar, Austin TX"
  puts ""
  puts " Customers:"
  puts "   emma@example.com    james@example.com   priya@example.com"
  puts "   marcus@example.com  olivia@example.com  tyler@example.com"
  puts "   zoe@example.com"
  puts "=" * 60

end
