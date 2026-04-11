puts "Seeding ChairHop database..."

# ============================================================
# HELPERS
# ============================================================

def fmt_svc(service)
  "#{service.name} - $#{'%.2f' % service.price}"
end

ActiveRecord::Base.transaction do
  # ============================================================
  # CLEANUP (FK-safe order — children before parents)
  # ============================================================
  puts "  Clearing existing data..."
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
  puts "  Done."

  # ============================================================
  # STYLISTS (8)
  # ============================================================
  puts "  Creating stylists..."

  maya = User.create!(
    email:                   "maya@example.com",
    password:                "password123",
    name:                    "Maya Johnson",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Natural hair specialist with 9 years of experience in silk presses, protective styles, and scalp care. I celebrate the versatility of textured hair and help every client leave feeling confident and cared for."
  )

  derek = User.create!(
    email:                   "derek@example.com",
    password:                "password123",
    name:                    "Derek Kim",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Precision barber with 11 years of experience in fades, tapers, and beard sculpting. Known for clean lines, consistent results, and a relaxed chair-side manner that keeps clients coming back."
  )

  sofia = User.create!(
    email:                   "sofia@example.com",
    password:                "password123",
    name:                    "Sofia Rivera",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Color specialist with 7 years of experience in balayage, highlights, and full-color transformations. I use premium, low-damage products to create stunning results tailored to each client's vision."
  )

  jordan = User.create!(
    email:                   "jordan@example.com",
    password:                "password123",
    name:                    "Jordan Hayes",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Curl specialist and DevaCurl-certified stylist with 6 years helping clients embrace their natural texture. I specialize in curly cuts and building personalized care plans for every curl pattern."
  )

  aaliyah = User.create!(
    email:                   "aaliyah@example.com",
    password:                "password123",
    name:                    "Aaliyah Brooks",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Licensed cosmetologist specializing in bridal and special-occasion styling. With 8 years of experience in updos, blowouts, and editorial looks, I make sure every client feels camera-ready for their biggest moments."
  )

  marcus = User.create!(
    email:                   "marcus@example.com",
    password:                "password123",
    name:                    "Marcus Dupont",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Master barber with 14 years of craft behind the chair, specializing in high-top fades, lineups, and hot towel shaves. My shop is a community space where every client gets top-tier service and genuine conversation."
  )

  priya = User.create!(
    email:                   "priya@example.com",
    password:                "password123",
    name:                    "Priya Menon",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Hair extension specialist and texture artist with 5 years of experience in tape-ins, sew-ins, and fusion bonds. I help clients achieve length, volume, and seamless blends that look and feel completely natural."
  )

  claire = User.create!(
    email:                   "claire@example.com",
    password:                "password123",
    name:                    "Claire Osei",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Loctician and natural hair artist with 10 years of experience in starter locs, retwists, and loc maintenance. I take a holistic approach to hair care and guide clients through every stage of their loc journey."
  )

  puts "  Done."

  # ============================================================
  # CUSTOMERS (10)
  # ============================================================
  puts "  Creating customers..."

  emma   = User.create!(email: "emma@example.com",   password: "password123", name: "Emma Wilson",  role: :customer)
  james  = User.create!(email: "james@example.com",  password: "password123", name: "James Carter", role: :customer)
  olivia = User.create!(email: "olivia@example.com", password: "password123", name: "Olivia Chen",  role: :customer)
  tyler  = User.create!(email: "tyler@example.com",  password: "password123", name: "Tyler Brooks", role: :customer)
  zoe    = User.create!(email: "zoe@example.com",    password: "password123", name: "Zoe Williams", role: :customer)
  aisha  = User.create!(email: "aisha@example.com",  password: "password123", name: "Aisha Grant",  role: :customer)
  leo    = User.create!(email: "leo@example.com",    password: "password123", name: "Leo Santos",   role: :customer)
  nina   = User.create!(email: "nina@example.com",   password: "password123", name: "Nina Park",    role: :customer)
  caleb  = User.create!(email: "caleb@example.com",  password: "password123", name: "Caleb Moore",  role: :customer)
  simone = User.create!(email: "simone@example.com", password: "password123", name: "Simone Baker", role: :customer)

  puts "  Done."

  # ============================================================
  # LOCATIONS (1 per stylist)
  # ============================================================
  puts "  Creating locations..."

  maya_loc    = maya.locations.create!(    name: "Maya's Studio",            street_address: "1214 Fillmore St",       city: "San Francisco", state: "CA", zip_code: "94115")
  derek_loc   = derek.locations.create!(   name: "Derek's Barbershop",       street_address: "456 Atlantic Ave",       city: "Brooklyn",      state: "NY", zip_code: "11217")
  sofia_loc   = sofia.locations.create!(   name: "Sofia Color Studio",       street_address: "789 South Congress Ave", city: "Austin",        state: "TX", zip_code: "78704")
  jordan_loc  = jordan.locations.create!(  name: "Curl Lab ATL",             street_address: "321 Auburn Ave NE",      city: "Atlanta",       state: "GA", zip_code: "30312")
  aaliyah_loc = aaliyah.locations.create!( name: "Aaliyah's Salon Suite",    street_address: "55 W Wacker Dr",         city: "Chicago",       state: "IL", zip_code: "60601")
  marcus_loc  = marcus.locations.create!(  name: "Dupont's Barbershop",      street_address: "900 Magazine St",        city: "New Orleans",   state: "LA", zip_code: "70130")
  priya_loc   = priya.locations.create!(   name: "Priya's Extension Bar",    street_address: "6420 Wilshire Blvd",     city: "Los Angeles",   state: "CA", zip_code: "90048")
  claire_loc  = claire.locations.create!(  name: "Claire's Loc Studio",      street_address: "1400 U Street NW",       city: "Washington",    state: "DC", zip_code: "20009")

  puts "  Done."

  # ============================================================
  # SERVICES
  # Main services + 2 add-ons per stylist.
  # price= setter accepts dollars, stored as price_cents (integer cents).
  # ============================================================
  puts "  Creating services..."

  # ---- Maya — natural hair ----
  maya_silk_press  = maya.services.create!(name: "Silk Press",                    price: 75,  duration_minutes: 90,  active: true, description: "Full straightening treatment with heat protectant and shine serum.")
  maya_braid_out   = maya.services.create!(name: "Braid Out & Style",             price: 55,  duration_minutes: 60,  active: true, description: "Defined braid-out set with moisturizing products.")
  maya_protective  = maya.services.create!(name: "Protective Style Consult",      price: 45,  duration_minutes: 45,  active: true, description: "Consultation on protective styles best suited for your hair.")
  maya_deep_cond   = maya.services.create!(name: "Deep Conditioning Treatment",   price: 40,  duration_minutes: 45,  active: true, description: "Intensive moisture treatment with steam and Olaplex.")
  maya_scalp_treat = maya.services.create!(name: "Scalp Treatment",               price: 35,  duration_minutes: 30,  active: true, is_add_on: true, description: "Detoxifying scalp mask and massage.")
  maya_trim        = maya.services.create!(name: "Trim & Shape",                  price: 25,  duration_minutes: 20,  active: true, is_add_on: true, description: "Light dusting and shape-up for healthy ends.")

  # ---- Derek — barber ----
  derek_fade       = derek.services.create!(name: "Men's Fade",                   price: 40,  duration_minutes: 45,  active: true, description: "Classic fade with sharp taper and lineup.")
  derek_beard      = derek.services.create!(name: "Beard Sculpt",                 price: 30,  duration_minutes: 30,  active: true, description: "Full beard shaping and sculpting with hot towel finish.")
  derek_hot_towel  = derek.services.create!(name: "Hot Towel Shave",              price: 35,  duration_minutes: 30,  active: true, description: "Traditional straight razor shave with hot towel treatment.")
  derek_kid        = derek.services.create!(name: "Kids Cut (under 12)",          price: 25,  duration_minutes: 30,  active: true, description: "Quick, clean haircut for children under 12.")
  derek_lineup     = derek.services.create!(name: "Lineup & Edge Up",             price: 15,  duration_minutes: 15,  active: true, is_add_on: true, description: "Crisp edge lineup on hairline and beard.")
  derek_shampoo    = derek.services.create!(name: "Shampoo & Condition",          price: 10,  duration_minutes: 15,  active: true, is_add_on: true, description: "Cleansing shampoo and lightweight condition.")

  # ---- Sofia — color ----
  sofia_balayage   = sofia.services.create!(name: "Balayage",                     price: 195, duration_minutes: 180, active: true, description: "Hand-painted highlights for a natural, sun-kissed look.")
  sofia_highlights = sofia.services.create!(name: "Full Highlights",              price: 150, duration_minutes: 150, active: true, description: "Full head of foil highlights, customized to your base.")
  sofia_color_melt = sofia.services.create!(name: "Color Melt",                   price: 165, duration_minutes: 165, active: true, description: "Seamless blending of two to three complementary tones.")
  sofia_toner      = sofia.services.create!(name: "Toner & Gloss",                price: 55,  duration_minutes: 30,  active: true, description: "Refreshes tone and adds luminous shine.")
  sofia_root_touch = sofia.services.create!(name: "Root Touch-Up",                price: 70,  duration_minutes: 45,  active: true, is_add_on: true, description: "Single-process color applied at the root.")
  sofia_olaplex    = sofia.services.create!(name: "Olaplex Treatment",            price: 30,  duration_minutes: 20,  active: true, is_add_on: true, description: "Bond-building in-salon treatment added to any service.")

  # ---- Jordan — curls ----
  jordan_deva_cut  = jordan.services.create!(name: "DevaCut",                     price: 90,  duration_minutes: 90,  active: true, description: "Dry curl-by-curl cut for defined, bouncy curls.")
  jordan_co_wash   = jordan.services.create!(name: "Curl Co-Wash & Style",        price: 65,  duration_minutes: 75,  active: true, description: "Gentle co-wash followed by curl-defining styling.")
  jordan_diffuse   = jordan.services.create!(name: "Diffuse & Define",            price: 50,  duration_minutes: 60,  active: true, description: "Full diffuse dry with curl-enhancing products.")
  jordan_consult   = jordan.services.create!(name: "Curl Consultation",           price: 35,  duration_minutes: 30,  active: true, description: "Personalized curl type analysis and product recommendations.")
  jordan_gloss     = jordan.services.create!(name: "Curl Gloss",                  price: 25,  duration_minutes: 20,  active: true, is_add_on: true, description: "Shine-enhancing gloss treatment for curls.")
  jordan_protein   = jordan.services.create!(name: "Protein Treatment",           price: 30,  duration_minutes: 20,  active: true, is_add_on: true, description: "Strengthening protein mask for damaged or fragile curls.")

  # ---- Aaliyah — bridal / occasion ----
  aaliyah_updo     = aaliyah.services.create!(name: "Bridal Updo",                price: 165, duration_minutes: 120, active: true, description: "Custom bridal updo designed to complement your wedding style.")
  aaliyah_blowout  = aaliyah.services.create!(name: "Blowout & Style",            price: 70,  duration_minutes: 60,  active: true, description: "Full blowout and finish for sleek, voluminous results.")
  aaliyah_trial    = aaliyah.services.create!(name: "Bridal Trial",               price: 95,  duration_minutes: 90,  active: true, description: "Preview your wedding day hair before the big day.")
  aaliyah_event    = aaliyah.services.create!(name: "Event Style",                price: 85,  duration_minutes: 75,  active: true, description: "Red-carpet-ready styling for galas, parties, and special occasions.")
  aaliyah_veil     = aaliyah.services.create!(name: "Veil & Accessory Pinning",   price: 20,  duration_minutes: 15,  active: true, is_add_on: true, description: "Secure attachment of veils, combs, or hair accessories.")
  aaliyah_curling  = aaliyah.services.create!(name: "Curling Iron Add-On",        price: 15,  duration_minutes: 15,  active: true, is_add_on: true, description: "Wand curls or waves added to any style.")

  # ---- Marcus — barber ----
  marcus_fade      = marcus.services.create!(name: "High-Top Fade",               price: 50,  duration_minutes: 60,  active: true, description: "Signature high-top fade with crisp taper and lineup.")
  marcus_taper     = marcus.services.create!(name: "Classic Taper",               price: 35,  duration_minutes: 45,  active: true, description: "Clean, timeless taper cut for any hair type.")
  marcus_full_svc  = marcus.services.create!(name: "Full Service Cut & Shave",    price: 65,  duration_minutes: 75,  active: true, description: "Haircut plus full hot-towel straight razor shave.")
  marcus_lining    = marcus.services.create!(name: "Shape-Up & Lining",           price: 20,  duration_minutes: 20,  active: true, is_add_on: true, description: "Precision edge-up on hairline and beard.")
  marcus_steam     = marcus.services.create!(name: "Steam & Condition",           price: 12,  duration_minutes: 10,  active: true, is_add_on: true, description: "Deep-steam condition to soften texture pre-cut.")

  # ---- Priya — extensions ----
  priya_tape_in    = priya.services.create!(name: "Tape-In Extensions",           price: 250, duration_minutes: 180, active: true, description: "Seamless tape-in extensions blended with your natural hair.")
  priya_sew_in     = priya.services.create!(name: "Sew-In Weave",                 price: 200, duration_minutes: 180, active: true, description: "Full sew-in with protective braided base.")
  priya_removal    = priya.services.create!(name: "Extension Removal",            price: 75,  duration_minutes: 60,  active: true, description: "Safe, damage-free removal of existing extensions.")
  priya_consult    = priya.services.create!(name: "Extension Consultation",       price: 30,  duration_minutes: 30,  active: true, description: "Hair analysis and extension type recommendation.")
  priya_toning     = priya.services.create!(name: "Toning Gloss",                 price: 40,  duration_minutes: 30,  active: true, is_add_on: true, description: "Color gloss to match extensions to natural hair tone.")
  priya_trim_ext   = priya.services.create!(name: "Blended Trim",                 price: 25,  duration_minutes: 20,  active: true, is_add_on: true, description: "Trim to blend extensions with natural hair length.")

  # ---- Claire — locs ----
  claire_starter   = claire.services.create!(name: "Starter Locs",               price: 180, duration_minutes: 240, active: true, description: "Beginning your loc journey with properly sectioned starter locs.")
  claire_retwist   = claire.services.create!(name: "Retwist & Style",             price: 80,  duration_minutes: 90,  active: true, description: "Full retwist to maintain loc definition and growth.")
  claire_repair    = claire.services.create!(name: "Loc Repair",                  price: 60,  duration_minutes: 60,  active: true, description: "Repair of thin, breaking, or unraveling locs.")
  claire_consult   = claire.services.create!(name: "Loc Consultation",            price: 25,  duration_minutes: 20,  active: true, description: "Assessment of loc health and maintenance planning.")
  claire_oil_treat = claire.services.create!(name: "Scalp Oil Treatment",         price: 20,  duration_minutes: 15,  active: true, is_add_on: true, description: "Nourishing oil applied to scalp and loc roots.")
  claire_crochet   = claire.services.create!(name: "Crochet Locs",                price: 150, duration_minutes: 180, active: true, description: "Faux loc installation using crochet method.")

  puts "  Done."

  # ============================================================
  # AVAILABILITY BLOCKS
  #
  # PAST blocks (for completed/cancelled appointments):
  #   ~3 weeks ago: 2026-03-21, 2026-03-22, 2026-03-28
  #   ~1 week ago:  2026-04-04
  #
  # FUTURE blocks (for pending/booked appointments):
  #   Next week:    2026-04-17, 2026-04-18, 2026-04-19
  #   2 weeks out:  2026-04-25, 2026-05-02, 2026-05-03
  #
  # Every appointment created below must fall within its block's
  # [start_time, end_time] window and reference availability_block_id.
  # ============================================================
  puts "  Creating availability blocks..."

  # ---- Maya (SF) ----
  maya_past_1   = AvailabilityBlock.create!(stylist: maya, location: maya_loc, start_time: Time.zone.parse("2026-03-21 09:00"), end_time: Time.zone.parse("2026-03-21 17:00"), available_for_all_services: true)
  maya_past_2   = AvailabilityBlock.create!(stylist: maya, location: maya_loc, start_time: Time.zone.parse("2026-03-28 09:00"), end_time: Time.zone.parse("2026-03-28 17:00"), available_for_all_services: true)
  maya_future_1 = AvailabilityBlock.create!(stylist: maya, location: maya_loc, start_time: Time.zone.parse("2026-04-17 09:00"), end_time: Time.zone.parse("2026-04-17 17:00"), available_for_all_services: true)
  maya_future_2 = AvailabilityBlock.create!(stylist: maya, location: maya_loc, start_time: Time.zone.parse("2026-04-25 10:00"), end_time: Time.zone.parse("2026-04-25 16:00"), available_for_all_services: true)

  # ---- Derek (Brooklyn) ----
  derek_past_1   = AvailabilityBlock.create!(stylist: derek, location: derek_loc, start_time: Time.zone.parse("2026-03-20 10:00"), end_time: Time.zone.parse("2026-03-20 18:00"), available_for_all_services: true)
  derek_past_2   = AvailabilityBlock.create!(stylist: derek, location: derek_loc, start_time: Time.zone.parse("2026-04-04 10:00"), end_time: Time.zone.parse("2026-04-04 18:00"), available_for_all_services: true)
  derek_future_1 = AvailabilityBlock.create!(stylist: derek, location: derek_loc, start_time: Time.zone.parse("2026-04-18 10:00"), end_time: Time.zone.parse("2026-04-18 18:00"), available_for_all_services: true)
  derek_future_2 = AvailabilityBlock.create!(stylist: derek, location: derek_loc, start_time: Time.zone.parse("2026-04-25 10:00"), end_time: Time.zone.parse("2026-04-25 18:00"), available_for_all_services: true)

  # ---- Sofia (Austin) ----
  sofia_past_1   = AvailabilityBlock.create!(stylist: sofia, location: sofia_loc, start_time: Time.zone.parse("2026-03-21 08:00"), end_time: Time.zone.parse("2026-03-21 18:00"), available_for_all_services: true)
  sofia_future_1 = AvailabilityBlock.create!(stylist: sofia, location: sofia_loc, start_time: Time.zone.parse("2026-04-18 08:00"), end_time: Time.zone.parse("2026-04-18 18:00"), available_for_all_services: true)
  sofia_future_2 = AvailabilityBlock.create!(stylist: sofia, location: sofia_loc, start_time: Time.zone.parse("2026-05-02 08:00"), end_time: Time.zone.parse("2026-05-02 18:00"), available_for_all_services: true)

  # ---- Jordan (Atlanta) ----
  jordan_past_1   = AvailabilityBlock.create!(stylist: jordan, location: jordan_loc, start_time: Time.zone.parse("2026-03-28 09:00"), end_time: Time.zone.parse("2026-03-28 17:00"), available_for_all_services: true)
  jordan_future_1 = AvailabilityBlock.create!(stylist: jordan, location: jordan_loc, start_time: Time.zone.parse("2026-04-19 09:00"), end_time: Time.zone.parse("2026-04-19 17:00"), available_for_all_services: true)
  jordan_future_2 = AvailabilityBlock.create!(stylist: jordan, location: jordan_loc, start_time: Time.zone.parse("2026-05-03 09:00"), end_time: Time.zone.parse("2026-05-03 17:00"), available_for_all_services: true)

  # ---- Aaliyah (Chicago) ----
  aaliyah_past_1   = AvailabilityBlock.create!(stylist: aaliyah, location: aaliyah_loc, start_time: Time.zone.parse("2026-03-22 10:00"), end_time: Time.zone.parse("2026-03-22 18:00"), available_for_all_services: true)
  aaliyah_future_1 = AvailabilityBlock.create!(stylist: aaliyah, location: aaliyah_loc, start_time: Time.zone.parse("2026-04-19 10:00"), end_time: Time.zone.parse("2026-04-19 18:00"), available_for_all_services: true)
  aaliyah_future_2 = AvailabilityBlock.create!(stylist: aaliyah, location: aaliyah_loc, start_time: Time.zone.parse("2026-05-03 10:00"), end_time: Time.zone.parse("2026-05-03 18:00"), available_for_all_services: true)

  # ---- Marcus (New Orleans) ----
  marcus_past_1   = AvailabilityBlock.create!(stylist: marcus, location: marcus_loc, start_time: Time.zone.parse("2026-03-21 09:00"), end_time: Time.zone.parse("2026-03-21 17:00"), available_for_all_services: true)
  marcus_past_2   = AvailabilityBlock.create!(stylist: marcus, location: marcus_loc, start_time: Time.zone.parse("2026-04-04 09:00"), end_time: Time.zone.parse("2026-04-04 17:00"), available_for_all_services: true)
  marcus_future_1 = AvailabilityBlock.create!(stylist: marcus, location: marcus_loc, start_time: Time.zone.parse("2026-04-18 09:00"), end_time: Time.zone.parse("2026-04-18 17:00"), available_for_all_services: true)

  # ---- Priya (LA) ----
  priya_past_1   = AvailabilityBlock.create!(stylist: priya, location: priya_loc, start_time: Time.zone.parse("2026-03-28 09:00"), end_time: Time.zone.parse("2026-03-28 18:00"), available_for_all_services: true)
  priya_future_1 = AvailabilityBlock.create!(stylist: priya, location: priya_loc, start_time: Time.zone.parse("2026-04-18 09:00"), end_time: Time.zone.parse("2026-04-18 18:00"), available_for_all_services: true)
  priya_future_2 = AvailabilityBlock.create!(stylist: priya, location: priya_loc, start_time: Time.zone.parse("2026-05-02 09:00"), end_time: Time.zone.parse("2026-05-02 18:00"), available_for_all_services: true)

  # ---- Claire (DC) ----
  claire_past_1   = AvailabilityBlock.create!(stylist: claire, location: claire_loc, start_time: Time.zone.parse("2026-03-21 08:00"), end_time: Time.zone.parse("2026-03-21 18:00"), available_for_all_services: true)
  claire_future_1 = AvailabilityBlock.create!(stylist: claire, location: claire_loc, start_time: Time.zone.parse("2026-04-19 08:00"), end_time: Time.zone.parse("2026-04-19 18:00"), available_for_all_services: true)
  claire_future_2 = AvailabilityBlock.create!(stylist: claire, location: claire_loc, start_time: Time.zone.parse("2026-05-03 08:00"), end_time: Time.zone.parse("2026-05-03 18:00"), available_for_all_services: true)

  puts "  Done."

  # ============================================================
  # APPOINTMENTS
  #
  # Rules enforced here:
  #   - Every appointment references availability_block_id
  #   - appointment.time falls within block's [start_time, end_time)
  #   - No two pending/booked appointments for the same stylist overlap
  #   - selected_service uses fmt_svc() so model parsing works correctly
  #   - location_id is always set (required on create)
  #   - payment_status uses valid inclusion values:
  #       pending | deposit_paid | balance_due | paid | refunded | deposit_kept | failed
  #
  # The overlap validation only checks status: [:pending, :booked],
  # so completed/cancelled appointments created here won't conflict.
  # ============================================================
  puts "  Creating appointments..."

  # ------------------------------------------------------------------
  # COMPLETED — past blocks
  # ------------------------------------------------------------------

  # Maya — 2026-03-21 (maya_past_1: 09:00–17:00)
  #   09:00  Silk Press (90 min → ends 10:30)  +scalp add-on
  #   11:00  Braid Out  (60 min → ends 12:00)
  #   13:00  Protective Consult (45 min → ends 13:45) [CANCELLED]

  appt_maya_c1 = Appointment.create!(
    stylist: maya, customer: emma,
    location: maya_loc, availability_block: maya_past_1,
    time: Time.zone.parse("2026-03-21 09:00"),
    selected_service: fmt_svc(maya_silk_press),
    payment_amount: maya_silk_press.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-21 10:30"),
    content: "Emma wanted a full silk press before a work event."
  )

  appt_maya_c2 = Appointment.create!(
    stylist: maya, customer: nina,
    location: maya_loc, availability_block: maya_past_1,
    time: Time.zone.parse("2026-03-21 11:00"),
    selected_service: fmt_svc(maya_braid_out),
    payment_amount: maya_braid_out.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-21 12:00"),
    content: "Nina is transitioning to natural hair and wanted a defined style."
  )

  appt_maya_x1 = Appointment.create!(
    stylist: maya, customer: simone,
    location: maya_loc, availability_block: maya_past_1,
    time: Time.zone.parse("2026-03-21 13:00"),
    selected_service: fmt_svc(maya_protective),
    payment_amount: maya_protective.price,
    payment_status: "refunded",
    status: :cancelled,
    cancelled_at: Time.zone.parse("2026-03-20 18:00"),
    cancelled_by: "customer",
    cancelled_by_id: simone.id,
    cancellation_reason: "Schedule conflict came up last minute."
  )

  # Maya — 2026-03-28 (maya_past_2: 09:00–17:00)
  #   09:30  Deep Conditioning (45 min → ends 10:15)

  appt_maya_c3 = Appointment.create!(
    stylist: maya, customer: aisha,
    location: maya_loc, availability_block: maya_past_2,
    time: Time.zone.parse("2026-03-28 09:30"),
    selected_service: fmt_svc(maya_deep_cond),
    payment_amount: maya_deep_cond.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-28 10:15"),
    content: "Aisha had heat damage from a previous appointment elsewhere."
  )

  # Derek — 2026-03-20 (derek_past_1: 10:00–18:00)
  #   10:00  Men's Fade (45 min → ends 10:45)
  #   11:00  Beard Sculpt (30 min → ends 11:30)

  appt_derek_c1 = Appointment.create!(
    stylist: derek, customer: caleb,
    location: derek_loc, availability_block: derek_past_1,
    time: Time.zone.parse("2026-03-20 10:00"),
    selected_service: fmt_svc(derek_fade),
    payment_amount: derek_fade.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-20 10:45"),
    content: "Caleb wanted a clean fade before a job interview."
  )

  appt_derek_c2 = Appointment.create!(
    stylist: derek, customer: james,
    location: derek_loc, availability_block: derek_past_1,
    time: Time.zone.parse("2026-03-20 11:00"),
    selected_service: fmt_svc(derek_beard),
    payment_amount: derek_beard.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-20 11:30"),
    content: "James comes in monthly for beard maintenance."
  )

  # Derek — 2026-04-04 (derek_past_2: 10:00–18:00)
  #   10:00  Hot Towel Shave (30 min) [CANCELLED — late cancellation]

  appt_derek_x1 = Appointment.create!(
    stylist: derek, customer: tyler,
    location: derek_loc, availability_block: derek_past_2,
    time: Time.zone.parse("2026-04-04 10:00"),
    selected_service: fmt_svc(derek_hot_towel),
    payment_amount: derek_hot_towel.price,
    payment_status: "deposit_kept",
    status: :cancelled,
    cancelled_at: Time.zone.parse("2026-04-03 22:00"),
    cancelled_by: "customer",
    cancelled_by_id: tyler.id,
    cancellation_reason: "Cancelled less than 24 hours before appointment — deposit kept per policy."
  )

  # Sofia — 2026-03-21 (sofia_past_1: 08:00–18:00)
  #   09:00  Balayage (180 min → ends 12:00)
  #   13:00  Toner & Gloss (30 min → ends 13:30)

  appt_sofia_c1 = Appointment.create!(
    stylist: sofia, customer: olivia,
    location: sofia_loc, availability_block: sofia_past_1,
    time: Time.zone.parse("2026-03-21 09:00"),
    selected_service: fmt_svc(sofia_balayage),
    payment_amount: sofia_balayage.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-21 12:00"),
    content: "Olivia wanted subtle, natural-looking highlights for spring."
  )

  appt_sofia_c2 = Appointment.create!(
    stylist: sofia, customer: zoe,
    location: sofia_loc, availability_block: sofia_past_1,
    time: Time.zone.parse("2026-03-21 13:00"),
    selected_service: fmt_svc(sofia_toner),
    payment_amount: sofia_toner.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-21 13:30"),
    content: "Zoe had existing highlights and needed tone refreshed."
  )

  # Jordan — 2026-03-28 (jordan_past_1: 09:00–17:00)
  #   09:00  DevaCut (90 min → ends 10:30)
  #   11:00  Curl Co-Wash & Style (75 min → ends 12:15)

  appt_jordan_c1 = Appointment.create!(
    stylist: jordan, customer: simone,
    location: jordan_loc, availability_block: jordan_past_1,
    time: Time.zone.parse("2026-03-28 09:00"),
    selected_service: fmt_svc(jordan_deva_cut),
    payment_amount: jordan_deva_cut.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-28 10:30"),
    content: "Simone wanted her curls shaped for summer."
  )

  appt_jordan_c2 = Appointment.create!(
    stylist: jordan, customer: emma,
    location: jordan_loc, availability_block: jordan_past_1,
    time: Time.zone.parse("2026-03-28 11:00"),
    selected_service: fmt_svc(jordan_co_wash),
    payment_amount: jordan_co_wash.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-28 12:15"),
    content: "First appointment with Jordan — Emma is working on a curl care routine."
  )

  # Aaliyah — 2026-03-22 (aaliyah_past_1: 10:00–18:00)
  #   10:00  Bridal Updo (120 min → ends 12:00)

  appt_aaliyah_c1 = Appointment.create!(
    stylist: aaliyah, customer: nina,
    location: aaliyah_loc, availability_block: aaliyah_past_1,
    time: Time.zone.parse("2026-03-22 10:00"),
    selected_service: fmt_svc(aaliyah_updo),
    payment_amount: aaliyah_updo.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-22 12:00"),
    content: "Nina's bridal trial for her April wedding."
  )

  # Marcus — 2026-03-21 (marcus_past_1: 09:00–17:00)
  #   09:00  High-Top Fade (60 min → ends 10:00)

  appt_marcus_c1 = Appointment.create!(
    stylist: marcus, customer: leo,
    location: marcus_loc, availability_block: marcus_past_1,
    time: Time.zone.parse("2026-03-21 09:00"),
    selected_service: fmt_svc(marcus_fade),
    payment_amount: marcus_fade.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-21 10:00"),
    content: "Leo is a regular — comes in every three weeks."
  )

  # Marcus — 2026-04-04 (marcus_past_2: 09:00–17:00)
  #   09:00  Full Service Cut & Shave (75 min → ends 10:15)  +lining add-on

  appt_marcus_c2 = Appointment.create!(
    stylist: marcus, customer: james,
    location: marcus_loc, availability_block: marcus_past_2,
    time: Time.zone.parse("2026-04-04 09:00"),
    selected_service: fmt_svc(marcus_full_svc),
    payment_amount: marcus_full_svc.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-04-04 10:15"),
    content: "James wanted a full treatment ahead of his anniversary dinner."
  )

  # Priya — 2026-03-28 (priya_past_1: 09:00–18:00)
  #   09:00  Tape-In Extensions (180 min → ends 12:00)  +toning gloss add-on

  appt_priya_c1 = Appointment.create!(
    stylist: priya, customer: zoe,
    location: priya_loc, availability_block: priya_past_1,
    time: Time.zone.parse("2026-03-28 09:00"),
    selected_service: fmt_svc(priya_tape_in),
    payment_amount: priya_tape_in.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-28 12:00"),
    content: "Zoe wanted length and volume for an upcoming photoshoot."
  )

  # Claire — 2026-03-21 (claire_past_1: 08:00–18:00)
  #   08:00  Retwist & Style (90 min → ends 09:30)  +oil treatment add-on
  #   10:00  Loc Repair (60 min → ends 11:00)        [CANCELLED — stylist emergency]

  appt_claire_c1 = Appointment.create!(
    stylist: claire, customer: aisha,
    location: claire_loc, availability_block: claire_past_1,
    time: Time.zone.parse("2026-03-21 08:00"),
    selected_service: fmt_svc(claire_retwist),
    payment_amount: claire_retwist.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :completed,
    completed_at: Time.zone.parse("2026-03-21 09:30"),
    content: "Aisha's regular retwist appointment every six weeks."
  )

  appt_claire_x1 = Appointment.create!(
    stylist: claire, customer: caleb,
    location: claire_loc, availability_block: claire_past_1,
    time: Time.zone.parse("2026-03-21 10:00"),
    selected_service: fmt_svc(claire_repair),
    payment_amount: claire_repair.price,
    payment_status: "refunded",
    status: :cancelled,
    cancelled_at: Time.zone.parse("2026-03-21 07:00"),
    cancelled_by: "stylist",
    cancelled_by_id: claire.id,
    cancellation_reason: "Claire had a family emergency and cancelled day-of."
  )

  # ------------------------------------------------------------------
  # PENDING — future blocks
  # overlap validation only checks status: [:pending, :booked],
  # so these must not overlap with each other per stylist.
  # ------------------------------------------------------------------

  # Maya — 2026-04-17 (maya_future_1: 09:00–17:00)
  #   09:00  Silk Press (90 min → ends 10:30)
  #   11:00  Deep Conditioning (45 min → ends 11:45)

  appt_maya_p1 = Appointment.create!(
    stylist: maya, customer: olivia,
    location: maya_loc, availability_block: maya_future_1,
    time: Time.zone.parse("2026-04-17 09:00"),
    selected_service: fmt_svc(maya_silk_press),
    payment_amount: maya_silk_press.price,
    payment_status: "pending",
    status: :pending,
    content: "Olivia is trying Maya for the first time."
  )

  appt_maya_p2 = Appointment.create!(
    stylist: maya, customer: caleb,
    location: maya_loc, availability_block: maya_future_1,
    time: Time.zone.parse("2026-04-17 11:00"),
    selected_service: fmt_svc(maya_deep_cond),
    payment_amount: maya_deep_cond.price,
    payment_status: "pending",
    status: :pending,
    content: "Caleb booked a conditioning treatment to restore dry hair."
  )

  # Derek — 2026-04-18 (derek_future_1: 10:00–18:00)
  #   10:00  Men's Fade (45 min → ends 10:45)

  appt_derek_p1 = Appointment.create!(
    stylist: derek, customer: leo,
    location: derek_loc, availability_block: derek_future_1,
    time: Time.zone.parse("2026-04-18 10:00"),
    selected_service: fmt_svc(derek_fade),
    payment_amount: derek_fade.price,
    payment_status: "pending",
    status: :pending,
    content: "Leo's friend recommended Derek's shop."
  )

  # Sofia — 2026-04-18 (sofia_future_1: 08:00–18:00)
  #   09:00  Color Melt (165 min → ends 11:45)

  appt_sofia_p1 = Appointment.create!(
    stylist: sofia, customer: nina,
    location: sofia_loc, availability_block: sofia_future_1,
    time: Time.zone.parse("2026-04-18 09:00"),
    selected_service: fmt_svc(sofia_color_melt),
    payment_amount: sofia_color_melt.price,
    payment_status: "pending",
    status: :pending,
    content: "Nina wants a brown-to-copper color melt for spring."
  )

  # Jordan — 2026-04-19 (jordan_future_1: 09:00–17:00)
  #   09:00  DevaCut (90 min → ends 10:30)

  appt_jordan_p1 = Appointment.create!(
    stylist: jordan, customer: tyler,
    location: jordan_loc, availability_block: jordan_future_1,
    time: Time.zone.parse("2026-04-19 09:00"),
    selected_service: fmt_svc(jordan_deva_cut),
    payment_amount: jordan_deva_cut.price,
    payment_status: "pending",
    status: :pending,
    content: "Tyler is trying a DevaCut for the first time after years of straight-cut methods."
  )

  # Aaliyah — 2026-04-19 (aaliyah_future_1: 10:00–18:00)
  #   10:00  Bridal Trial (90 min → ends 11:30)

  appt_aaliyah_p1 = Appointment.create!(
    stylist: aaliyah, customer: simone,
    location: aaliyah_loc, availability_block: aaliyah_future_1,
    time: Time.zone.parse("2026-04-19 10:00"),
    selected_service: fmt_svc(aaliyah_trial),
    payment_amount: aaliyah_trial.price,
    payment_status: "pending",
    status: :pending,
    content: "Simone is getting married in June and wants to preview her updo."
  )

  # Marcus — 2026-04-18 (marcus_future_1: 09:00–17:00)
  #   09:00  High-Top Fade (60 min → ends 10:00)

  appt_marcus_p1 = Appointment.create!(
    stylist: marcus, customer: james,
    location: marcus_loc, availability_block: marcus_future_1,
    time: Time.zone.parse("2026-04-18 09:00"),
    selected_service: fmt_svc(marcus_fade),
    payment_amount: marcus_fade.price,
    payment_status: "pending",
    status: :pending,
    content: "James's regular appointment with Marcus."
  )

  # Priya — 2026-04-18 (priya_future_1: 09:00–18:00)
  #   09:00  Sew-In Weave (180 min → ends 12:00)

  appt_priya_p1 = Appointment.create!(
    stylist: priya, customer: aisha,
    location: priya_loc, availability_block: priya_future_1,
    time: Time.zone.parse("2026-04-18 09:00"),
    selected_service: fmt_svc(priya_sew_in),
    payment_amount: priya_sew_in.price,
    payment_status: "pending",
    status: :pending,
    content: "Aisha wants a full sew-in for protective styling this spring."
  )

  # Claire — 2026-04-19 (claire_future_1: 08:00–18:00)
  #   08:00  Retwist & Style (90 min → ends 09:30)

  appt_claire_p1 = Appointment.create!(
    stylist: claire, customer: emma,
    location: claire_loc, availability_block: claire_future_1,
    time: Time.zone.parse("2026-04-19 08:00"),
    selected_service: fmt_svc(claire_retwist),
    payment_amount: claire_retwist.price,
    payment_status: "pending",
    status: :pending,
    content: "Emma is exploring loc maintenance after eight months in."
  )

  # ------------------------------------------------------------------
  # BOOKED — future blocks (deposit paid)
  # ------------------------------------------------------------------

  # Maya — 2026-04-25 (maya_future_2: 10:00–16:00)
  #   10:00  Braid Out & Style (60 min → ends 11:00)

  appt_maya_b1 = Appointment.create!(
    stylist: maya, customer: simone,
    location: maya_loc, availability_block: maya_future_2,
    time: Time.zone.parse("2026-04-25 10:00"),
    selected_service: fmt_svc(maya_braid_out),
    payment_amount: maya_braid_out.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :booked,
    content: "Simone wants a braid-out style for a weekend trip."
  )

  # Derek — 2026-04-25 (derek_future_2: 10:00–18:00)
  #   10:00  Beard Sculpt (30 min → ends 10:30)

  appt_derek_b1 = Appointment.create!(
    stylist: derek, customer: caleb,
    location: derek_loc, availability_block: derek_future_2,
    time: Time.zone.parse("2026-04-25 10:00"),
    selected_service: fmt_svc(derek_beard),
    payment_amount: derek_beard.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :booked,
    content: "Caleb getting his beard shaped for a date."
  )

  # Sofia — 2026-05-02 (sofia_future_2: 08:00–18:00)
  #   09:00  Full Highlights (150 min → ends 11:30)

  appt_sofia_b1 = Appointment.create!(
    stylist: sofia, customer: zoe,
    location: sofia_loc, availability_block: sofia_future_2,
    time: Time.zone.parse("2026-05-02 09:00"),
    selected_service: fmt_svc(sofia_highlights),
    payment_amount: sofia_highlights.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :booked,
    content: "Zoe booked a full highlight refresh for summer."
  )

  # Jordan — 2026-05-03 (jordan_future_2: 09:00–17:00)
  #   09:00  Curl Co-Wash & Style (75 min → ends 10:15)

  appt_jordan_b1 = Appointment.create!(
    stylist: jordan, customer: olivia,
    location: jordan_loc, availability_block: jordan_future_2,
    time: Time.zone.parse("2026-05-03 09:00"),
    selected_service: fmt_svc(jordan_co_wash),
    payment_amount: jordan_co_wash.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :booked,
    content: "Olivia booked a co-wash and style ahead of a beach trip."
  )

  # Aaliyah — 2026-05-03 (aaliyah_future_2: 10:00–18:00)
  #   10:00  Blowout & Style (60 min → ends 11:00)

  appt_aaliyah_b1 = Appointment.create!(
    stylist: aaliyah, customer: nina,
    location: aaliyah_loc, availability_block: aaliyah_future_2,
    time: Time.zone.parse("2026-05-03 10:00"),
    selected_service: fmt_svc(aaliyah_blowout),
    payment_amount: aaliyah_blowout.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :booked,
    content: "Nina wants a sleek blowout for an event the following day."
  )

  # Priya — 2026-05-02 (priya_future_2: 09:00–18:00)
  #   09:00  Extension Removal (60 min → ends 10:00)

  appt_priya_b1 = Appointment.create!(
    stylist: priya, customer: leo,
    location: priya_loc, availability_block: priya_future_2,
    time: Time.zone.parse("2026-05-02 09:00"),
    selected_service: fmt_svc(priya_removal),
    payment_amount: priya_removal.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :booked,
    content: "Leo getting tape-in extensions removed."
  )

  # Claire — 2026-05-03 (claire_future_2: 08:00–18:00)
  #   08:00  Starter Locs (240 min → ends 12:00)

  appt_claire_b1 = Appointment.create!(
    stylist: claire, customer: tyler,
    location: claire_loc, availability_block: claire_future_2,
    time: Time.zone.parse("2026-05-03 08:00"),
    selected_service: fmt_svc(claire_starter),
    payment_amount: claire_starter.price,
    payment_status: "paid",
    payment_id: "DEV_#{SecureRandom.hex(8)}",
    status: :booked,
    content: "Tyler is starting his loc journey — first appointment with Claire."
  )

  puts "  Done."

  # ============================================================
  # ADD-ONS (on select completed & booked appointments)
  # ============================================================
  puts "  Creating add-ons..."

  AppointmentAddOn.create!(appointment: appt_maya_c1,   service: maya_scalp_treat, service_name: maya_scalp_treat.name, price: maya_scalp_treat.price)
  AppointmentAddOn.create!(appointment: appt_marcus_c2, service: marcus_lining,    service_name: marcus_lining.name,    price: marcus_lining.price)
  AppointmentAddOn.create!(appointment: appt_priya_c1,  service: priya_toning,     service_name: priya_toning.name,     price: priya_toning.price)
  AppointmentAddOn.create!(appointment: appt_claire_c1, service: claire_oil_treat, service_name: claire_oil_treat.name, price: claire_oil_treat.price)
  AppointmentAddOn.create!(appointment: appt_sofia_b1,  service: sofia_olaplex,    service_name: sofia_olaplex.name,    price: sofia_olaplex.price)

  puts "  Done."

  # ============================================================
  # REVIEWS (for completed appointments)
  # Saved with validate: false to bypass the within_review_window
  # validation (3 days from completion).
  # ============================================================
  puts "  Creating reviews..."

  Review.new(
    appointment: appt_maya_c1, customer: emma, stylist: maya,
    rating: 5,
    content: "Maya is absolutely incredible. My silk press came out better than I've ever seen — so smooth and full of shine. She really listened to what I wanted and didn't use too much heat. The scalp treatment was the perfect addition. I left feeling genuinely pampered and have already booked my next appointment."
  ).save(validate: false)

  Review.new(
    appointment: appt_maya_c2, customer: nina, stylist: maya,
    rating: 5,
    content: "I've been nervous about going natural but Maya made the whole process feel exciting rather than daunting. My braid-out came out beautifully defined and she gave me so many tips for maintaining my hair at home. Her studio is calm and welcoming. I genuinely looked forward to coming back.",
    stylist_response: "Nina, thank you so much! It was such a pleasure working with your hair. The texture you have is stunning — so glad we got to celebrate it together. See you soon!",
    stylist_responded_at: Time.zone.parse("2026-03-22 10:00")
  ).save(validate: false)

  Review.new(
    appointment: appt_derek_c1, customer: caleb, stylist: derek,
    rating: 5,
    content: "I came in for a clean fade before a big interview and Derek delivered beyond my expectations. The lineup was razor-sharp and the taper was perfectly blended. He worked quickly without rushing and I felt comfortable the whole time. Got the job too — this is my new go-to in Brooklyn."
  ).save(validate: false)

  Review.new(
    appointment: appt_sofia_c1, customer: olivia, stylist: sofia,
    rating: 5,
    content: "Sofia gave me the most gorgeous balayage I've ever had. I've been to multiple colorists and none have nailed the look I described as well as she did. The tones are so natural-looking and the damage was minimal despite going lighter. She also walked me through the aftercare in detail. Worth every penny.",
    stylist_response: "Olivia, this review made my day! I loved working with your hair — the dimension we got was stunning. Make sure you're using that purple shampoo! Can't wait to see you again.",
    stylist_responded_at: Time.zone.parse("2026-03-22 16:00")
  ).save(validate: false)

  Review.new(
    appointment: appt_jordan_c1, customer: simone, stylist: jordan,
    rating: 5,
    content: "I have been getting my hair cut the wrong way for years. Jordan explained the DevaCut method while she worked and completely changed how I understand my curls. My hair bounced in a way it never has before. She recommended products that actually work for my curl type. Absolute game changer."
  ).save(validate: false)

  Review.new(
    appointment: appt_aaliyah_c1, customer: nina, stylist: aaliyah,
    rating: 4,
    content: "Aaliyah did a beautiful job on my bridal trial. The updo was elegant and held up all day. I had a couple of small tweaks I wanted for the actual wedding day and she was very open to the feedback. Communication before the appointment was prompt and professional. Really glad I went with her.",
    stylist_response: "Nina, thank you for this lovely review! I took all your notes and I'm so excited to create your final look for the big day. You are going to be stunning.",
    stylist_responded_at: Time.zone.parse("2026-03-23 09:00")
  ).save(validate: false)

  Review.new(
    appointment: appt_marcus_c1, customer: leo, stylist: marcus,
    rating: 5,
    content: "Marcus is a true craftsman. The high-top fade he gave me was clean, precise, and exactly what I had in mind. His shop has great energy and he's the kind of barber who remembers your name and your usual. I've been going to him for over a year and genuinely look forward to every visit."
  ).save(validate: false)

  Review.new(
    appointment: appt_priya_c1, customer: zoe, stylist: priya,
    rating: 4,
    content: "Priya did an amazing job with my tape-in extensions — the blend is seamless and nobody can tell they aren't my natural hair. She was thorough in the consultation and helped me pick the right shade and length. The appointment ran a little over time but the results were absolutely worth it."
  ).save(validate: false)

  Review.new(
    appointment: appt_claire_c1, customer: aisha, stylist: claire,
    rating: 5,
    content: "Claire is so knowledgeable about locs it's almost hard to believe. She spotted an issue with one of my locs I hadn't even noticed and addressed it during the retwist at no extra charge. My locs look healthier than ever and the scalp oil treatment felt incredible. Best in DC without question."
  ).save(validate: false)

  puts "  Done."

  # ============================================================
  # SUMMARY
  # ============================================================
  puts ""
  puts "Seeding complete!"
  puts ""
  puts "  Stylists:            #{User.stylist.count}"
  puts "  Customers:           #{User.customer.count}"
  puts "  Locations:           #{Location.count}"
  puts "  Services:            #{Service.main_services.count} main, #{Service.add_ons.count} add-ons"
  puts "  Availability blocks: #{AvailabilityBlock.count}"
  puts "  Appointments:        #{Appointment.count} total"
  puts "    Pending:           #{Appointment.pending.count}"
  puts "    Booked:            #{Appointment.booked.count}"
  puts "    Completed:         #{Appointment.completed.count}"
  puts "    Cancelled:         #{Appointment.cancelled.count}"
  puts "  Add-ons:             #{AppointmentAddOn.count}"
  puts "  Reviews:             #{Review.count}"
end
