puts "Seeding ChairHop database..."

ActiveRecord::Base.transaction do

  # ============================================================
  # CLEANUP (FK-safe order — children before parents)
  # ============================================================
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
  puts "  Done."

  # ============================================================
  # STYLISTS (10)
  # ============================================================
  puts "Creating stylists..."

  maya = User.create!(
    email:                   "maya.johnson@example.com",
    password:                "password123",
    name:                    "Maya Johnson",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Natural hair specialist with 9 years of experience in silk presses, protective styles, and scalp health. I celebrate the beauty and versatility of textured hair and help every client leave feeling confident and cared for."
  )

  derek = User.create!(
    email:                   "derek.kim@example.com",
    password:                "password123",
    name:                    "Derek Kim",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Precision barber with 11 years of experience in fades, tapers, beard sculpting, and classic barbering. Known for clean lines, consistent results, and a relaxed chair-side manner that keeps clients coming back."
  )

  sofia = User.create!(
    email:                   "sofia.rivera@example.com",
    password:                "password123",
    name:                    "Sofia Rivera",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Color specialist with 7 years of experience in balayage, highlights, and full-color transformations. I use premium, low-damage products to create stunning, long-lasting results tailored to each client's vision."
  )

  jordan = User.create!(
    email:                   "jordan.hayes@example.com",
    password:                "password123",
    name:                    "Jordan Hayes",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Curl specialist and DevaCurl-certified stylist with 6 years helping clients embrace their natural texture. I specialize in curly cuts, co-wash routines, and building personalized care plans for every curl pattern."
  )

  aaliyah = User.create!(
    email:                   "aaliyah.brooks@example.com",
    password:                "password123",
    name:                    "Aaliyah Brooks",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Licensed cosmetologist specializing in bridal and special-occasion styling. With 8 years of experience in updos, blowouts, and editorial looks, I make sure every client feels camera-ready for their biggest moments."
  )

  marcus_s = User.create!(
    email:                   "marcus.dupont@example.com",
    password:                "password123",
    name:                    "Marcus Dupont",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Master barber with 14 years of craft behind the chair, specializing in high-top fades, lineups, and hot towel shaves. My shop is a community space where every client gets top-tier service and genuine conversation."
  )

  priya_s = User.create!(
    email:                   "priya.menon@example.com",
    password:                "password123",
    name:                    "Priya Menon",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Hair extension specialist and texture artist with 5 years of experience in tape-ins, sew-ins, and fusion bonds. I help clients achieve length, volume, and seamless blends that look and feel completely natural."
  )

  claire = User.create!(
    email:                   "claire.osei@example.com",
    password:                "password123",
    name:                    "Claire Osei",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Loctician and natural hair artist with 10 years of experience in starter locs, retwists, and loc maintenance. I take a holistic approach to hair care and guide clients through every stage of their loc journey with patience and expertise."
  )

  ben = User.create!(
    email:                   "ben.nakamura@example.com",
    password:                "password123",
    name:                    "Ben Nakamura",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Freelance stylist and texture specialist with 6 years in both salon and editorial settings. I focus on precision cuts, Japanese straightening, and lived-in color that works with your natural hair rather than against it."
  )

  taylor = User.create!(
    email:                   "taylor.west@example.com",
    password:                "password123",
    name:                    "Taylor West",
    role:                    :stylist,
    onboarding_completed_at: Time.current,
    about:                   "Scalp health advocate and trichology-trained stylist with 8 years helping clients restore hair density and shine. I combine science-backed treatments with personalized consultation to get your hair and scalp thriving again."
  )

  stylists = [maya, derek, sofia, jordan, aaliyah, marcus_s, priya_s, claire, ben, taylor]
  puts "  Created #{User.stylist.count} stylists."

  # ============================================================
  # CUSTOMERS (20)
  # ============================================================
  puts "Creating customers..."

  emma      = User.create!(email: "emma.wilson@example.com",    password: "password123", name: "Emma Wilson",      role: :customer)
  james     = User.create!(email: "james.carter@example.com",   password: "password123", name: "James Carter",     role: :customer)
  olivia    = User.create!(email: "olivia.chen@example.com",    password: "password123", name: "Olivia Chen",      role: :customer)
  tyler     = User.create!(email: "tyler.brooks@example.com",   password: "password123", name: "Tyler Brooks",     role: :customer)
  zoe       = User.create!(email: "zoe.williams@example.com",   password: "password123", name: "Zoe Williams",     role: :customer)
  marcus_c  = User.create!(email: "marcus.lee@example.com",     password: "password123", name: "Marcus Lee",       role: :customer)
  priya_c   = User.create!(email: "priya.patel@example.com",    password: "password123", name: "Priya Patel",      role: :customer)
  daniel    = User.create!(email: "daniel.nguyen@example.com",  password: "password123", name: "Daniel Nguyen",    role: :customer)
  aisha     = User.create!(email: "aisha.grant@example.com",    password: "password123", name: "Aisha Grant",      role: :customer)
  leo       = User.create!(email: "leo.santos@example.com",     password: "password123", name: "Leo Santos",       role: :customer)
  nina      = User.create!(email: "nina.park@example.com",      password: "password123", name: "Nina Park",        role: :customer)
  caleb     = User.create!(email: "caleb.moore@example.com",    password: "password123", name: "Caleb Moore",      role: :customer)
  simone    = User.create!(email: "simone.baker@example.com",   password: "password123", name: "Simone Baker",     role: :customer)
  ryan      = User.create!(email: "ryan.thomas@example.com",    password: "password123", name: "Ryan Thomas",      role: :customer)
  jasmine   = User.create!(email: "jasmine.ford@example.com",   password: "password123", name: "Jasmine Ford",     role: :customer)
  evan      = User.create!(email: "evan.clark@example.com",     password: "password123", name: "Evan Clark",       role: :customer)
  destiny   = User.create!(email: "destiny.hall@example.com",   password: "password123", name: "Destiny Hall",     role: :customer)
  miguel    = User.create!(email: "miguel.reyes@example.com",   password: "password123", name: "Miguel Reyes",     role: :customer)
  hannah    = User.create!(email: "hannah.scott@example.com",   password: "password123", name: "Hannah Scott",     role: :customer)
  andre     = User.create!(email: "andre.white@example.com",    password: "password123", name: "Andre White",      role: :customer)

  customers = [emma, james, olivia, tyler, zoe, marcus_c, priya_c, daniel, aisha, leo,
               nina, caleb, simone, ryan, jasmine, evan, destiny, miguel, hannah, andre]
  puts "  Created #{User.customer.count} customers."

  # ============================================================
  # LOCATIONS (1-2 per stylist)
  # ============================================================
  puts "Creating locations..."

  # Maya Johnson — San Francisco, CA — home studio + rented chair
  maya_loc1 = Location.create!(
    user:           maya,
    name:           "Glow Studio",
    street_address: "1842 Fillmore St",
    city:           "San Francisco",
    state:          "CA",
    zip_code:       "94115"
  )
  maya_loc2 = Location.create!(
    user:           maya,
    name:           "The Chair at Salon Muse",
    street_address: "3390 18th St",
    city:           "San Francisco",
    state:          "CA",
    zip_code:       "94110"
  )

  # Derek Kim — Brooklyn, NY — salon suite
  derek_loc = Location.create!(
    user:           derek,
    name:           "Sharp Cuts Suite",
    street_address: "456 Bedford Ave",
    city:           "Brooklyn",
    state:          "NY",
    zip_code:       "11211"
  )

  # Sofia Rivera — Austin, TX — color bar (salon suite)
  sofia_loc = Location.create!(
    user:           sofia,
    name:           "Chic Color Bar",
    street_address: "2104 S Lamar Blvd",
    city:           "Austin",
    state:          "TX",
    zip_code:       "78704"
  )

  # Jordan Hayes — Atlanta, GA — home studio + mobile
  jordan_loc1 = Location.create!(
    user:           jordan,
    name:           "Curl Haus Studio",
    street_address: "741 Ralph McGill Blvd NE",
    city:           "Atlanta",
    state:          "GA",
    zip_code:       "30312"
  )
  jordan_loc2 = Location.create!(
    user:           jordan,
    name:           "Mobile — Atlanta Metro",
    street_address: "600 Peachtree St NE",
    city:           "Atlanta",
    state:          "GA",
    zip_code:       "30308"
  )

  # Aaliyah Brooks — Chicago, IL — rented chair in bridal salon
  aaliyah_loc = Location.create!(
    user:           aaliyah,
    name:           "Blanc Bridal Salon",
    street_address: "875 N Michigan Ave",
    city:           "Chicago",
    state:          "IL",
    zip_code:       "60611"
  )

  # Marcus Dupont — New Orleans, LA — barbershop (owns)
  marcus_s_loc = Location.create!(
    user:           marcus_s,
    name:           "Uptown Fade Barbershop",
    street_address: "4523 Magazine St",
    city:           "New Orleans",
    state:          "LA",
    zip_code:       "70115"
  )

  # Priya Menon — Los Angeles, CA — salon suite + mobile
  priya_s_loc1 = Location.create!(
    user:           priya_s,
    name:           "Luxe Extensions Studio",
    street_address: "8310 W 3rd St",
    city:           "Los Angeles",
    state:          "CA",
    zip_code:       "90048"
  )
  priya_s_loc2 = Location.create!(
    user:           priya_s,
    name:           "Mobile — Greater LA",
    street_address: "6801 Hollywood Blvd",
    city:           "Los Angeles",
    state:          "CA",
    zip_code:       "90028"
  )

  # Claire Osei — Washington, DC — home studio
  claire_loc = Location.create!(
    user:           claire,
    name:           "Roots & Coils Home Studio",
    street_address: "1247 U St NW",
    city:           "Washington",
    state:          "DC",
    zip_code:       "20009"
  )

  # Ben Nakamura — Seattle, WA — rented chair in indie salon
  ben_loc = Location.create!(
    user:           ben,
    name:           "Chair at Kinfolk Salon",
    street_address: "314 E Pike St",
    city:           "Seattle",
    state:          "WA",
    zip_code:       "98122"
  )

  # Taylor West — Miami, FL — wellness salon suite + second location
  taylor_loc1 = Location.create!(
    user:           taylor,
    name:           "Scalp & Strand Studio",
    street_address: "1111 Lincoln Rd",
    city:           "Miami Beach",
    state:          "FL",
    zip_code:       "33139"
  )
  taylor_loc2 = Location.create!(
    user:           taylor,
    name:           "Wynwood Wellness Suite",
    street_address: "2750 NW 3rd Ave",
    city:           "Miami",
    state:          "FL",
    zip_code:       "33127"
  )

  puts "  Created #{Location.count} locations."

  # ============================================================
  # SERVICES (5-8 per stylist, price in dollars via price= setter)
  # ============================================================
  puts "Creating services..."

  # --- Maya Johnson — natural hair (San Francisco) ---
  maya_silk_press    = Service.create!(stylist: maya, name: "Silk Press",                  price: 65,  duration_minutes: 75,  is_add_on: false, description: "Silky straight finish for natural hair using low-heat pressing technique.")
  maya_braids        = Service.create!(stylist: maya, name: "Protective Braids",           price: 120, duration_minutes: 180, is_add_on: false, description: "Knotless box braids or twist variations in any length.")
  maya_wash_go       = Service.create!(stylist: maya, name: "Wash & Go",                   price: 70,  duration_minutes: 90,  is_add_on: false, description: "Clarifying wash, deep condition, and curl definition for natural hair.")
  maya_consultation  = Service.create!(stylist: maya, name: "Hair Health Consultation",    price: 40,  duration_minutes: 45,  is_add_on: false, description: "One-on-one session for hair routine, scalp health, and product guidance.")
  maya_big_chop      = Service.create!(stylist: maya, name: "Big Chop",                    price: 55,  duration_minutes: 60,  is_add_on: false, description: "Transitioning cut to fully natural hair with a customized shape.")
                       Service.create!(stylist: maya, name: "Deep Conditioning Treatment", price: 20,  duration_minutes: 20,  is_add_on: true,  description: "Intensive moisture treatment added to any service.")
                       Service.create!(stylist: maya, name: "Scalp Massage",               price: 15,  duration_minutes: 15,  is_add_on: true,  description: "Relaxing scalp massage with essential oils.")
                       Service.create!(stylist: maya, name: "Protein Treatment",           price: 25,  duration_minutes: 20,  is_add_on: true,  description: "Strengthening protein treatment to reduce breakage.")

  # --- Derek Kim — precision barber (Brooklyn) ---
  derek_fade     = Service.create!(stylist: derek, name: "Men's Fade",      price: 35, duration_minutes: 40, is_add_on: false, description: "Precision skin or low fade with a sharp line-up.")
  derek_cut      = Service.create!(stylist: derek, name: "Classic Cut",     price: 28, duration_minutes: 35, is_add_on: false, description: "Scissors and clipper cut for any length.")
  derek_kids     = Service.create!(stylist: derek, name: "Kids Cut",        price: 20, duration_minutes: 30, is_add_on: false, description: "Patient, thorough cuts for children 12 and under.")
  derek_beard    = Service.create!(stylist: derek, name: "Beard Shape-Up",  price: 25, duration_minutes: 25, is_add_on: false, description: "Full beard sculpt, oil, and precision line detailing.")
  derek_shampoo  = Service.create!(stylist: derek, name: "Shampoo & Style", price: 40, duration_minutes: 45, is_add_on: false, description: "Shampoo, condition, and finished style.")
                   Service.create!(stylist: derek, name: "Hot Towel Treatment", price: 8,  duration_minutes: 10, is_add_on: true, description: "Classic hot towel treatment for face and neck.")
                   Service.create!(stylist: derek, name: "Razor Line-Up",       price: 10, duration_minutes: 10, is_add_on: true, description: "Straight-razor edge-up on hairline and sideburns.")
                   Service.create!(stylist: derek, name: "Beard Conditioning",  price: 12, duration_minutes: 10, is_add_on: true, description: "Softening conditioning and oil treatment for beard.")

  # --- Sofia Rivera — color specialist (Austin) ---
  sofia_balayage   = Service.create!(stylist: sofia, name: "Balayage",            price: 180, duration_minutes: 180, is_add_on: false, description: "Hand-painted highlights for natural-looking dimension and depth.")
  sofia_full_color = Service.create!(stylist: sofia, name: "Full Color",          price: 110, duration_minutes: 120, is_add_on: false, description: "Root-to-tip single process color, all shades.")
  sofia_cut        = Service.create!(stylist: sofia, name: "Women's Cut & Style", price: 65,  duration_minutes: 60,  is_add_on: false, description: "Precision cut and blowout finish.")
  sofia_highlights = Service.create!(stylist: sofia, name: "Highlights",          price: 130, duration_minutes: 150, is_add_on: false, description: "Foil highlights, partial or full coverage.")
  sofia_keratin    = Service.create!(stylist: sofia, name: "Keratin Treatment",   price: 200, duration_minutes: 180, is_add_on: false, description: "Professional smoothing treatment for frizz control and shine.")
                     Service.create!(stylist: sofia, name: "Olaplex Treatment", price: 35, duration_minutes: 20, is_add_on: true, description: "Bond-repairing Olaplex add-on for color services.")
                     Service.create!(stylist: sofia, name: "Toning Gloss",      price: 25, duration_minutes: 20, is_add_on: true, description: "Gloss toner for shine and color refresh between appointments.")
                     Service.create!(stylist: sofia, name: "Deep Conditioning", price: 20, duration_minutes: 20, is_add_on: true, description: "Intensive deep conditioning treatment add-on.")

  # --- Jordan Hayes — curl specialist (Atlanta) ---
  jordan_curly_cut   = Service.create!(stylist: jordan, name: "Curly Cut",             price: 75, duration_minutes: 75, is_add_on: false, description: "Dry or wet cut shaped specifically for your curl pattern.")
  jordan_deva        = Service.create!(stylist: jordan, name: "DevaCut",               price: 85, duration_minutes: 90, is_add_on: false, description: "DevaCurl-certified curl-by-curl cutting technique for defined shape.")
  jordan_cowash      = Service.create!(stylist: jordan, name: "Co-Wash & Style",       price: 65, duration_minutes: 75, is_add_on: false, description: "Gentle co-wash, detangle, and curl definition styling.")
  jordan_consult     = Service.create!(stylist: jordan, name: "Curl Consultation",     price: 40, duration_minutes: 45, is_add_on: false, description: "Personalized curl analysis and hair care routine plan.")
  jordan_big_chop    = Service.create!(stylist: jordan, name: "Big Chop",              price: 60, duration_minutes: 60, is_add_on: false, description: "Transitioning cut to fully natural curls with a fresh shape.")
                       Service.create!(stylist: jordan, name: "Diffuser Dry",              price: 15, duration_minutes: 20, is_add_on: true, description: "Professional diffuser dry for defined, frizz-free curls.")
                       Service.create!(stylist: jordan, name: "Curl Defining Treatment",   price: 25, duration_minutes: 20, is_add_on: true, description: "Deep curl-enhancing treatment added to any wash service.")

  # --- Aaliyah Brooks — bridal & event stylist (Chicago) ---
  aaliyah_updo    = Service.create!(stylist: aaliyah, name: "Bridal Updo",          price: 150, duration_minutes: 90, is_add_on: false, description: "Custom updo for weddings — timeless and tailored to your vision.")
  aaliyah_blowout = Service.create!(stylist: aaliyah, name: "Event Blowout & Style", price: 80, duration_minutes: 60, is_add_on: false, description: "Blowout and finished style for any special occasion.")
  aaliyah_trial   = Service.create!(stylist: aaliyah, name: "Trial Run Style",      price: 100, duration_minutes: 75, is_add_on: false, description: "Pre-wedding trial to perfect your bridal look.")
  aaliyah_halfup  = Service.create!(stylist: aaliyah, name: "Half-Up Style",         price: 65, duration_minutes: 45, is_add_on: false, description: "Elegant half-up, half-down style for events and portraits.")
  aaliyah_braid   = Service.create!(stylist: aaliyah, name: "Braid & Pin",           price: 70, duration_minutes: 60, is_add_on: false, description: "Braided and pinned updo styles for formal occasions.")
                    Service.create!(stylist: aaliyah, name: "Hair Accessory Placement", price: 20, duration_minutes: 15, is_add_on: true, description: "Placement and securing of veils, pins, florals, or clips.")
                    Service.create!(stylist: aaliyah, name: "Veil Attachment",          price: 15, duration_minutes: 10, is_add_on: true, description: "Secure veil attachment with hidden combs and pins.")

  # --- Marcus Dupont — master barber (New Orleans) ---
  marcus_s_hightop = Service.create!(stylist: marcus_s, name: "High-Top Fade",        price: 45, duration_minutes: 50, is_add_on: false, description: "Classic high-top fade with sculpted top and crisp line-up.")
  marcus_s_taper   = Service.create!(stylist: marcus_s, name: "Classic Taper",         price: 35, duration_minutes: 40, is_add_on: false, description: "Clean taper cut with a natural or low fade finish.")
  marcus_s_shave   = Service.create!(stylist: marcus_s, name: "Hot Towel Shave",       price: 40, duration_minutes: 35, is_add_on: false, description: "Traditional straight-razor shave with hot towel prep and aftershave.")
  marcus_s_lineup  = Service.create!(stylist: marcus_s, name: "Shape-Up Only",         price: 20, duration_minutes: 20, is_add_on: false, description: "Precision edge-up on hairline, temples, and sideburns.")
  marcus_s_groom   = Service.create!(stylist: marcus_s, name: "Full Groom Package",    price: 70, duration_minutes: 75, is_add_on: false, description: "Fade, beard shape-up, hot towel, and aftercare — all in one.")
                     Service.create!(stylist: marcus_s, name: "Beard Line-Up",  price: 10, duration_minutes: 10, is_add_on: true, description: "Precision beard line detailing added to any cut.")
                     Service.create!(stylist: marcus_s, name: "Edge Touch-Up",  price: 8,  duration_minutes: 10, is_add_on: true, description: "Quick hairline and temple touch-up between appointments.")

  # --- Priya Menon — extension specialist (Los Angeles) ---
  priya_s_tapein    = Service.create!(stylist: priya_s, name: "Tape-In Extensions",       price: 300, duration_minutes: 180, is_add_on: false, description: "Seamless tape-in extension application for length and volume.")
  priya_s_sewin     = Service.create!(stylist: priya_s, name: "Sew-In Weave",             price: 250, duration_minutes: 150, is_add_on: false, description: "Cornrow base sew-in weave for full coverage and versatility.")
  priya_s_fusion    = Service.create!(stylist: priya_s, name: "Fusion Bond Extensions",   price: 400, duration_minutes: 240, is_add_on: false, description: "Keratin bond fusion extensions for the most natural movement.")
  priya_s_removal   = Service.create!(stylist: priya_s, name: "Extension Removal",        price: 80,  duration_minutes: 60,  is_add_on: false, description: "Safe, gentle removal of any extension type without damage.")
  priya_s_consult   = Service.create!(stylist: priya_s, name: "Extension Consultation",   price: 45,  duration_minutes: 45,  is_add_on: false, description: "Hair assessment and extension recommendation session.")
                      Service.create!(stylist: priya_s, name: "Toner",          price: 30, duration_minutes: 20, is_add_on: true, description: "Custom toner to blend extensions seamlessly with natural hair.")
                      Service.create!(stylist: priya_s, name: "Blowout & Style", price: 40, duration_minutes: 30, is_add_on: true, description: "Blowout and finish added after extension application.")

  # --- Claire Osei — loctician (Washington, DC) ---
  claire_starter    = Service.create!(stylist: claire, name: "Starter Locs",       price: 150, duration_minutes: 180, is_add_on: false, description: "New loc installation using two-strand twist, comb coil, or braid method.")
  claire_retwist    = Service.create!(stylist: claire, name: "Loc Retwist",        price: 80,  duration_minutes: 90,  is_add_on: false, description: "Palm-roll or interlocking retwist to maintain neat, defined locs.")
  claire_repair     = Service.create!(stylist: claire, name: "Loc Repair",         price: 60,  duration_minutes: 60,  is_add_on: false, description: "Targeted repair for thinning, broken, or unraveling locs.")
  claire_detox      = Service.create!(stylist: claire, name: "Loc Detox & Wash",   price: 70,  duration_minutes: 75,  is_add_on: false, description: "Deep cleansing detox wash to remove buildup from locs.")
  claire_interlock  = Service.create!(stylist: claire, name: "Interlocking",       price: 90,  duration_minutes: 90,  is_add_on: false, description: "Interlocking technique for lasting roots and reduced frizz.")
                      Service.create!(stylist: claire, name: "Beeswax Treatment",   price: 15, duration_minutes: 10, is_add_on: true, description: "Natural beeswax application for frizz control and shine.")
                      Service.create!(stylist: claire, name: "Scalp Oil Treatment", price: 20, duration_minutes: 15, is_add_on: true, description: "Nourishing scalp oil application to soothe dryness and promote growth.")

  # --- Ben Nakamura — texture specialist (Seattle) ---
  ben_precision  = Service.create!(stylist: ben, name: "Precision Cut",              price: 60,  duration_minutes: 60,  is_add_on: false, description: "Clean, deliberate cut tailored to your texture and face shape.")
  ben_japanese   = Service.create!(stylist: ben, name: "Japanese Straightening",     price: 250, duration_minutes: 180, is_add_on: false, description: "Permanent thermal straightening for smooth, long-lasting results.")
  ben_lived_in   = Service.create!(stylist: ben, name: "Lived-In Color",             price: 120, duration_minutes: 120, is_add_on: false, description: "Soft, low-maintenance color that grows out naturally.")
  ben_mens       = Service.create!(stylist: ben, name: "Men's Cut & Style",          price: 50,  duration_minutes: 50,  is_add_on: false, description: "Cut and finish styled for texture — not against it.")
  ben_consult    = Service.create!(stylist: ben, name: "Texture Consultation",       price: 40,  duration_minutes: 45,  is_add_on: false, description: "Hair health and texture assessment with a personalized care plan.")
                   Service.create!(stylist: ben, name: "Gloss Treatment",        price: 25, duration_minutes: 20, is_add_on: true, description: "Clear or tinted gloss for shine and color longevity.")
                   Service.create!(stylist: ben, name: "Bond Repair Treatment",  price: 35, duration_minutes: 20, is_add_on: true, description: "Bond-building treatment to protect hair during chemical services.")

  # --- Taylor West — scalp health specialist (Miami) ---
  taylor_analysis  = Service.create!(stylist: taylor, name: "Scalp Analysis & Treatment",   price: 90, duration_minutes: 75, is_add_on: false, description: "In-depth scalp assessment followed by a targeted treatment plan.")
  taylor_detox     = Service.create!(stylist: taylor, name: "Clarifying Detox",              price: 75, duration_minutes: 60, is_add_on: false, description: "Enzyme and acid clarifying treatment to remove buildup and reset scalp health.")
  taylor_growth    = Service.create!(stylist: taylor, name: "Growth Stimulation Treatment",  price: 80, duration_minutes: 60, is_add_on: false, description: "Targeted scalp treatment to stimulate follicles and support hair growth.")
  taylor_trichology = Service.create!(stylist: taylor, name: "Trichology Consultation",     price: 50, duration_minutes: 45, is_add_on: false, description: "Science-backed consultation for hair loss, breakage, and scalp concerns.")
  taylor_dht       = Service.create!(stylist: taylor, name: "DHT-Blocking Treatment",        price: 95, duration_minutes: 75, is_add_on: false, description: "Topical DHT-blocking serum treatment for clients experiencing thinning.")
                     Service.create!(stylist: taylor, name: "Scalp Oil Infusion", price: 20, duration_minutes: 15, is_add_on: true, description: "Warm oil infusion to nourish and hydrate the scalp between treatments.")
                     Service.create!(stylist: taylor, name: "Biotin Scalp Mask",  price: 25, duration_minutes: 20, is_add_on: true, description: "Biotin-enriched mask to strengthen hair at the root and reduce shedding.")

  puts "  Created #{Service.where(is_add_on: false).count} main services, #{Service.where(is_add_on: true).count} add-ons."

  # ============================================================
  # AVAILABILITY BLOCKS (4-8 per stylist, next 4 weeks)
  # service_ids stored as array of id strings per schema
  # ============================================================
  puts "Creating availability blocks..."

  today = Date.today

  # Helper so each block reads as: base date + hour offset
  # All times land within 8am-6pm. Each stylist uses non-overlapping days.

  # --- Maya Johnson — 6 blocks, alternates between 2 locations ---
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc1,
    start_time: (today + 2).beginning_of_day + 9.hours,
    end_time:   (today + 2).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc2,
    start_time: (today + 5).beginning_of_day + 10.hours,
    end_time:   (today + 5).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [maya_silk_press.id.to_s, maya_braids.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc1,
    start_time: (today + 9).beginning_of_day + 9.hours,
    end_time:   (today + 9).beginning_of_day + 15.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc2,
    start_time: (today + 13).beginning_of_day + 11.hours,
    end_time:   (today + 13).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [maya_wash_go.id.to_s, maya_consultation.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc1,
    start_time: (today + 18).beginning_of_day + 9.hours,
    end_time:   (today + 18).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: maya, location: maya_loc1,
    start_time: (today + 24).beginning_of_day + 10.hours,
    end_time:   (today + 24).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [maya_silk_press.id.to_s, maya_big_chop.id.to_s]
  )

  # --- Derek Kim — 5 blocks, single location ---
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 1).beginning_of_day + 9.hours,
    end_time:   (today + 1).beginning_of_day + 15.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 4).beginning_of_day + 10.hours,
    end_time:   (today + 4).beginning_of_day + 18.hours,
    available_for_all_services: false,
    service_ids: [derek_fade.id.to_s, derek_beard.id.to_s, derek_shampoo.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 8).beginning_of_day + 9.hours,
    end_time:   (today + 8).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 14).beginning_of_day + 8.hours,
    end_time:   (today + 14).beginning_of_day + 14.hours,
    available_for_all_services: false,
    service_ids: [derek_fade.id.to_s, derek_cut.id.to_s, derek_kids.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: derek, location: derek_loc,
    start_time: (today + 21).beginning_of_day + 9.hours,
    end_time:   (today + 21).beginning_of_day + 17.hours,
    available_for_all_services: true
  )

  # --- Sofia Rivera — 4 blocks (long color sessions), single location ---
  AvailabilityBlock.create!(
    stylist: sofia, location: sofia_loc,
    start_time: (today + 3).beginning_of_day + 10.hours,
    end_time:   (today + 3).beginning_of_day + 18.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: sofia, location: sofia_loc,
    start_time: (today + 7).beginning_of_day + 9.hours,
    end_time:   (today + 7).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [sofia_balayage.id.to_s, sofia_highlights.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: sofia, location: sofia_loc,
    start_time: (today + 15).beginning_of_day + 10.hours,
    end_time:   (today + 15).beginning_of_day + 18.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: sofia, location: sofia_loc,
    start_time: (today + 22).beginning_of_day + 9.hours,
    end_time:   (today + 22).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [sofia_full_color.id.to_s, sofia_keratin.id.to_s, sofia_cut.id.to_s]
  )

  # --- Jordan Hayes — 6 blocks, alternates between 2 locations ---
  AvailabilityBlock.create!(
    stylist: jordan, location: jordan_loc1,
    start_time: (today + 2).beginning_of_day + 9.hours,
    end_time:   (today + 2).beginning_of_day + 15.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: jordan, location: jordan_loc2,
    start_time: (today + 5).beginning_of_day + 10.hours,
    end_time:   (today + 5).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [jordan_curly_cut.id.to_s, jordan_deva.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: jordan, location: jordan_loc1,
    start_time: (today + 9).beginning_of_day + 9.hours,
    end_time:   (today + 9).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: jordan, location: jordan_loc2,
    start_time: (today + 12).beginning_of_day + 10.hours,
    end_time:   (today + 12).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [jordan_cowash.id.to_s, jordan_consult.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: jordan, location: jordan_loc1,
    start_time: (today + 17).beginning_of_day + 9.hours,
    end_time:   (today + 17).beginning_of_day + 15.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: jordan, location: jordan_loc1,
    start_time: (today + 25).beginning_of_day + 10.hours,
    end_time:   (today + 25).beginning_of_day + 17.hours,
    available_for_all_services: true
  )

  # --- Aaliyah Brooks — 5 blocks, single location ---
  AvailabilityBlock.create!(
    stylist: aaliyah, location: aaliyah_loc,
    start_time: (today + 3).beginning_of_day + 10.hours,
    end_time:   (today + 3).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [aaliyah_updo.id.to_s, aaliyah_trial.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: aaliyah, location: aaliyah_loc,
    start_time: (today + 6).beginning_of_day + 9.hours,
    end_time:   (today + 6).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: aaliyah, location: aaliyah_loc,
    start_time: (today + 10).beginning_of_day + 9.hours,
    end_time:   (today + 10).beginning_of_day + 15.hours,
    available_for_all_services: false,
    service_ids: [aaliyah_blowout.id.to_s, aaliyah_halfup.id.to_s, aaliyah_braid.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: aaliyah, location: aaliyah_loc,
    start_time: (today + 16).beginning_of_day + 10.hours,
    end_time:   (today + 16).beginning_of_day + 18.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: aaliyah, location: aaliyah_loc,
    start_time: (today + 23).beginning_of_day + 10.hours,
    end_time:   (today + 23).beginning_of_day + 16.hours,
    available_for_all_services: true
  )

  # --- Marcus Dupont — 6 blocks, single location ---
  AvailabilityBlock.create!(
    stylist: marcus_s, location: marcus_s_loc,
    start_time: (today + 1).beginning_of_day + 8.hours,
    end_time:   (today + 1).beginning_of_day + 14.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: marcus_s, location: marcus_s_loc,
    start_time: (today + 4).beginning_of_day + 9.hours,
    end_time:   (today + 4).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [marcus_s_hightop.id.to_s, marcus_s_taper.id.to_s, marcus_s_lineup.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: marcus_s, location: marcus_s_loc,
    start_time: (today + 8).beginning_of_day + 8.hours,
    end_time:   (today + 8).beginning_of_day + 16.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: marcus_s, location: marcus_s_loc,
    start_time: (today + 11).beginning_of_day + 9.hours,
    end_time:   (today + 11).beginning_of_day + 15.hours,
    available_for_all_services: false,
    service_ids: [marcus_s_shave.id.to_s, marcus_s_groom.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: marcus_s, location: marcus_s_loc,
    start_time: (today + 18).beginning_of_day + 8.hours,
    end_time:   (today + 18).beginning_of_day + 14.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: marcus_s, location: marcus_s_loc,
    start_time: (today + 25).beginning_of_day + 9.hours,
    end_time:   (today + 25).beginning_of_day + 17.hours,
    available_for_all_services: true
  )

  # --- Priya Menon — 5 blocks (long extension sessions), alternates 2 locations ---
  AvailabilityBlock.create!(
    stylist: priya_s, location: priya_s_loc1,
    start_time: (today + 3).beginning_of_day + 9.hours,
    end_time:   (today + 3).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: priya_s, location: priya_s_loc2,
    start_time: (today + 7).beginning_of_day + 10.hours,
    end_time:   (today + 7).beginning_of_day + 18.hours,
    available_for_all_services: false,
    service_ids: [priya_s_tapein.id.to_s, priya_s_fusion.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: priya_s, location: priya_s_loc1,
    start_time: (today + 12).beginning_of_day + 9.hours,
    end_time:   (today + 12).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: priya_s, location: priya_s_loc2,
    start_time: (today + 19).beginning_of_day + 10.hours,
    end_time:   (today + 19).beginning_of_day + 18.hours,
    available_for_all_services: false,
    service_ids: [priya_s_sewin.id.to_s, priya_s_removal.id.to_s, priya_s_consult.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: priya_s, location: priya_s_loc1,
    start_time: (today + 26).beginning_of_day + 9.hours,
    end_time:   (today + 26).beginning_of_day + 17.hours,
    available_for_all_services: true
  )

  # --- Claire Osei — 5 blocks, single location ---
  AvailabilityBlock.create!(
    stylist: claire, location: claire_loc,
    start_time: (today + 2).beginning_of_day + 9.hours,
    end_time:   (today + 2).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: claire, location: claire_loc,
    start_time: (today + 6).beginning_of_day + 10.hours,
    end_time:   (today + 6).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [claire_starter.id.to_s, claire_retwist.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: claire, location: claire_loc,
    start_time: (today + 11).beginning_of_day + 9.hours,
    end_time:   (today + 11).beginning_of_day + 15.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: claire, location: claire_loc,
    start_time: (today + 16).beginning_of_day + 10.hours,
    end_time:   (today + 16).beginning_of_day + 18.hours,
    available_for_all_services: false,
    service_ids: [claire_retwist.id.to_s, claire_interlock.id.to_s, claire_detox.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: claire, location: claire_loc,
    start_time: (today + 23).beginning_of_day + 9.hours,
    end_time:   (today + 23).beginning_of_day + 17.hours,
    available_for_all_services: true
  )

  # --- Ben Nakamura — 5 blocks, single location ---
  AvailabilityBlock.create!(
    stylist: ben, location: ben_loc,
    start_time: (today + 4).beginning_of_day + 10.hours,
    end_time:   (today + 4).beginning_of_day + 17.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: ben, location: ben_loc,
    start_time: (today + 8).beginning_of_day + 9.hours,
    end_time:   (today + 8).beginning_of_day + 15.hours,
    available_for_all_services: false,
    service_ids: [ben_precision.id.to_s, ben_mens.id.to_s, ben_consult.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: ben, location: ben_loc,
    start_time: (today + 13).beginning_of_day + 10.hours,
    end_time:   (today + 13).beginning_of_day + 18.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: ben, location: ben_loc,
    start_time: (today + 20).beginning_of_day + 9.hours,
    end_time:   (today + 20).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [ben_lived_in.id.to_s, ben_japanese.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: ben, location: ben_loc,
    start_time: (today + 27).beginning_of_day + 10.hours,
    end_time:   (today + 27).beginning_of_day + 16.hours,
    available_for_all_services: true
  )

  # --- Taylor West — 6 blocks, alternates between 2 locations ---
  AvailabilityBlock.create!(
    stylist: taylor, location: taylor_loc1,
    start_time: (today + 2).beginning_of_day + 9.hours,
    end_time:   (today + 2).beginning_of_day + 15.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: taylor, location: taylor_loc2,
    start_time: (today + 5).beginning_of_day + 10.hours,
    end_time:   (today + 5).beginning_of_day + 16.hours,
    available_for_all_services: false,
    service_ids: [taylor_analysis.id.to_s, taylor_detox.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: taylor, location: taylor_loc1,
    start_time: (today + 9).beginning_of_day + 8.hours,
    end_time:   (today + 9).beginning_of_day + 14.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: taylor, location: taylor_loc2,
    start_time: (today + 13).beginning_of_day + 9.hours,
    end_time:   (today + 13).beginning_of_day + 17.hours,
    available_for_all_services: false,
    service_ids: [taylor_growth.id.to_s, taylor_trichology.id.to_s, taylor_dht.id.to_s]
  )
  AvailabilityBlock.create!(
    stylist: taylor, location: taylor_loc1,
    start_time: (today + 17).beginning_of_day + 9.hours,
    end_time:   (today + 17).beginning_of_day + 15.hours,
    available_for_all_services: true
  )
  AvailabilityBlock.create!(
    stylist: taylor, location: taylor_loc2,
    start_time: (today + 24).beginning_of_day + 10.hours,
    end_time:   (today + 24).beginning_of_day + 18.hours,
    available_for_all_services: true
  )

  puts "  Created #{AvailabilityBlock.count} availability blocks."

  # ============================================================
  # APPOINTMENTS
  # Note: before_save :set_end_time recalculates end_time from
  # selected_service, so explicit end_time matches what the
  # callback will write — no divergence.
  # Overlap check (no_overlapping_appointments) is per stylist,
  # so same customer can appear across different stylists.
  # ============================================================
  puts "Creating appointments..."

  # ----------------------------------------------------------
  # PENDING (10) — future, no payment collected yet
  # ----------------------------------------------------------

  # Maya — silk press, day+6 10am (ends 11:15am)
  Appointment.create!(
    stylist:          maya,
    customer:         emma,
    location_id:      maya_loc1.id,
    salon:            maya.name,
    time:             (today + 6).beginning_of_day + 10.hours,
    end_time:         (today + 6).beginning_of_day + 10.hours + maya_silk_press.duration_minutes.minutes,
    selected_service: "#{maya_silk_press.name} - $#{sprintf('%.2f', maya_silk_press.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   maya_silk_press.price,
    content:          "Emma is getting ready for a family reunion and wants a sleek, heat-protected silk press with a light oil finish. Prefers medium heat."
  )

  # Maya — consultation, day+10 9am (ends 9:45am) — no overlap
  Appointment.create!(
    stylist:          maya,
    customer:         daniel,
    location_id:      maya_loc2.id,
    salon:            maya.name,
    time:             (today + 10).beginning_of_day + 9.hours,
    end_time:         (today + 10).beginning_of_day + 9.hours + maya_consultation.duration_minutes.minutes,
    selected_service: "#{maya_consultation.name} - $#{sprintf('%.2f', maya_consultation.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   maya_consultation.price,
    content:          "Daniel is transitioning from relaxed to natural and wants guidance on building a routine for his texture and scalp type."
  )

  # Derek — men's fade, day+5 9am (ends 9:40am)
  Appointment.create!(
    stylist:          derek,
    customer:         james,
    location_id:      derek_loc.id,
    salon:            derek.name,
    time:             (today + 5).beginning_of_day + 9.hours,
    end_time:         (today + 5).beginning_of_day + 9.hours + derek_fade.duration_minutes.minutes,
    selected_service: "#{derek_fade.name} - $#{sprintf('%.2f', derek_fade.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   derek_fade.price,
    content:          "James wants a low skin fade with a sharp hairline and temple taper. Keeps the top long with a textured finish."
  )

  # Derek — classic cut, day+11 9am (ends 9:35am) — no overlap
  Appointment.create!(
    stylist:          derek,
    customer:         ryan,
    location_id:      derek_loc.id,
    salon:            derek.name,
    time:             (today + 11).beginning_of_day + 9.hours,
    end_time:         (today + 11).beginning_of_day + 9.hours + derek_cut.duration_minutes.minutes,
    selected_service: "#{derek_cut.name} - $#{sprintf('%.2f', derek_cut.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   derek_cut.price,
    content:          "Ryan wants a clean scissor cut, taking about an inch off the top and cleaning up the sides. No fade — prefers a natural taper."
  )

  # Sofia — balayage, day+8 10am (ends 1pm)
  Appointment.create!(
    stylist:          sofia,
    customer:         olivia,
    location_id:      sofia_loc.id,
    salon:            sofia.name,
    time:             (today + 8).beginning_of_day + 10.hours,
    end_time:         (today + 8).beginning_of_day + 10.hours + sofia_balayage.duration_minutes.minutes,
    selected_service: "#{sofia_balayage.name} - $#{sprintf('%.2f', sofia_balayage.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   sofia_balayage.price,
    content:          "Olivia wants warm honey-brown balayage on a dark brown base. First time coloring — wants a subtle, sun-kissed effect that grows out naturally."
  )

  # Jordan — curly cut, day+6 9am (ends 10:15am)
  Appointment.create!(
    stylist:          jordan,
    customer:         tyler,
    location_id:      jordan_loc1.id,
    salon:            jordan.name,
    time:             (today + 6).beginning_of_day + 9.hours,
    end_time:         (today + 6).beginning_of_day + 9.hours + jordan_curly_cut.duration_minutes.minutes,
    selected_service: "#{jordan_curly_cut.name} - $#{sprintf('%.2f', jordan_curly_cut.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   jordan_curly_cut.price,
    content:          "Tyler has 3C curls and wants a shape-up dry cut to remove split ends and add definition. Wants to keep length — no more than half an inch off."
  )

  # Aaliyah — bridal updo, day+7 10am (ends 11:30am)
  Appointment.create!(
    stylist:          aaliyah,
    customer:         priya_c,
    location_id:      aaliyah_loc.id,
    salon:            aaliyah.name,
    time:             (today + 7).beginning_of_day + 10.hours,
    end_time:         (today + 7).beginning_of_day + 10.hours + aaliyah_updo.duration_minutes.minutes,
    selected_service: "#{aaliyah_updo.name} - $#{sprintf('%.2f', aaliyah_updo.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   aaliyah_updo.price,
    content:          "Priya is getting married in two weeks and wants a romantic, loose updo with face-framing tendrils. Hair is shoulder-length and naturally wavy."
  )

  # Marcus S — high-top fade, day+5 8am (ends 8:50am)
  Appointment.create!(
    stylist:          marcus_s,
    customer:         marcus_c,
    location_id:      marcus_s_loc.id,
    salon:            marcus_s.name,
    time:             (today + 5).beginning_of_day + 8.hours,
    end_time:         (today + 5).beginning_of_day + 8.hours + marcus_s_hightop.duration_minutes.minutes,
    selected_service: "#{marcus_s_hightop.name} - $#{sprintf('%.2f', marcus_s_hightop.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   marcus_s_hightop.price,
    content:          "Marcus wants a fresh high-top fade ahead of a birthday celebration. Likes a hard part on the left and a very crisp line-up."
  )

  # Claire — loc retwist, day+7 9am (ends 10:30am)
  Appointment.create!(
    stylist:          claire,
    customer:         leo,
    location_id:      claire_loc.id,
    salon:            claire.name,
    time:             (today + 7).beginning_of_day + 9.hours,
    end_time:         (today + 7).beginning_of_day + 9.hours + claire_retwist.duration_minutes.minutes,
    selected_service: "#{claire_retwist.name} - $#{sprintf('%.2f', claire_retwist.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   claire_retwist.price,
    content:          "Leo's locs are about 8 months old and due for a retwist. He prefers a palm-roll method and wants the parts kept neat and even."
  )

  # Taylor — scalp analysis, day+3 9am (ends 10:15am)
  Appointment.create!(
    stylist:          taylor,
    customer:         nina,
    location_id:      taylor_loc1.id,
    salon:            taylor.name,
    time:             (today + 3).beginning_of_day + 9.hours,
    end_time:         (today + 3).beginning_of_day + 9.hours + taylor_analysis.duration_minutes.minutes,
    selected_service: "#{taylor_analysis.name} - $#{sprintf('%.2f', taylor_analysis.price)}",
    status:           :pending,
    payment_status:   "pending",
    payment_amount:   taylor_analysis.price,
    content:          "Nina has been experiencing increased shedding for three months and wants a thorough scalp analysis before starting any treatment plan."
  )

  # ----------------------------------------------------------
  # BOOKED (10) — future, deposit paid
  # ----------------------------------------------------------

  # Maya — wash & go, day+6 12pm (ends 1:30pm) — no overlap with Emma 10-11:15am
  Appointment.create!(
    stylist:          maya,
    customer:         aisha,
    location_id:      maya_loc1.id,
    salon:            maya.name,
    time:             (today + 6).beginning_of_day + 12.hours,
    end_time:         (today + 6).beginning_of_day + 12.hours + maya_wash_go.duration_minutes.minutes,
    selected_service: "#{maya_wash_go.name} - $#{sprintf('%.2f', maya_wash_go.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   maya_wash_go.price,
    content:          "Aisha has 4A coils and wants a full wash day with curl definition. Prefers Shea Moisture-compatible products and no silicones."
  )

  # Maya — protective braids, day+14 10am (ends 1pm) — no overlap, different day
  Appointment.create!(
    stylist:          maya,
    customer:         simone,
    location_id:      maya_loc2.id,
    salon:            maya.name,
    time:             (today + 14).beginning_of_day + 10.hours,
    end_time:         (today + 14).beginning_of_day + 10.hours + maya_braids.duration_minutes.minutes,
    selected_service: "#{maya_braids.name} - $#{sprintf('%.2f', maya_braids.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   maya_braids.price,
    content:          "Simone wants medium knotless box braids, waist-length, with a side part. Hair is pre-washed and lightly stretched."
  )

  # Derek — beard shape-up, day+5 10am (ends 10:25am) — no overlap with James 9-9:40am
  Appointment.create!(
    stylist:          derek,
    customer:         evan,
    location_id:      derek_loc.id,
    salon:            derek.name,
    time:             (today + 5).beginning_of_day + 10.hours,
    end_time:         (today + 5).beginning_of_day + 10.hours + derek_beard.duration_minutes.minutes,
    selected_service: "#{derek_beard.name} - $#{sprintf('%.2f', derek_beard.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   derek_beard.price,
    content:          "Evan wants his full beard sculpted down and shaped — angled at the cheeks, square at the chin. Prefers a clean finish with beard oil."
  )

  # Sofia — women's cut & style, day+8 2pm (ends 3pm) — no overlap with Olivia 10am-1pm
  Appointment.create!(
    stylist:          sofia,
    customer:         hannah,
    location_id:      sofia_loc.id,
    salon:            sofia.name,
    time:             (today + 8).beginning_of_day + 14.hours,
    end_time:         (today + 8).beginning_of_day + 14.hours + sofia_cut.duration_minutes.minutes,
    selected_service: "#{sofia_cut.name} - $#{sprintf('%.2f', sofia_cut.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   sofia_cut.price,
    content:          "Hannah wants a long-layer cut with a blowout. She's growing her hair out but wants shape and movement put back into it."
  )

  # Jordan — co-wash & style, day+6 11am (ends 12:15pm) — no overlap with Tyler 9-10:15am
  Appointment.create!(
    stylist:          jordan,
    customer:         zoe,
    location_id:      jordan_loc1.id,
    salon:            jordan.name,
    time:             (today + 6).beginning_of_day + 11.hours,
    end_time:         (today + 6).beginning_of_day + 11.hours + jordan_cowash.duration_minutes.minutes,
    selected_service: "#{jordan_cowash.name} - $#{sprintf('%.2f', jordan_cowash.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   jordan_cowash.price,
    content:          "Zoe wants a co-wash refresh and a defined twist-out set. Her curls are 3B/3C and she's been dealing with frizz in the humidity."
  )

  # Aaliyah — half-up style, day+7 12pm (ends 12:45pm) — no overlap with Priya 10-11:30am
  Appointment.create!(
    stylist:          aaliyah,
    customer:         jasmine,
    location_id:      aaliyah_loc.id,
    salon:            aaliyah.name,
    time:             (today + 7).beginning_of_day + 12.hours,
    end_time:         (today + 7).beginning_of_day + 12.hours + aaliyah_halfup.duration_minutes.minutes,
    selected_service: "#{aaliyah_halfup.name} - $#{sprintf('%.2f', aaliyah_halfup.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   aaliyah_halfup.price,
    content:          "Jasmine is a bridesmaid and needs a polished half-up style with soft waves. The wedding colors are blush and cream."
  )

  # Marcus S — classic taper, day+5 9am (ends 9:40am) — no overlap with Marcus_c 8-8:50am
  Appointment.create!(
    stylist:          marcus_s,
    customer:         andre,
    location_id:      marcus_s_loc.id,
    salon:            marcus_s.name,
    time:             (today + 5).beginning_of_day + 9.hours,
    end_time:         (today + 5).beginning_of_day + 9.hours + marcus_s_taper.duration_minutes.minutes,
    selected_service: "#{marcus_s_taper.name} - $#{sprintf('%.2f', marcus_s_taper.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   marcus_s_taper.price,
    content:          "Andre wants a classic low taper with a clean natural finish — no skin fade. He likes a slightly rounded top and neat sideburns."
  )

  # Priya S — tape-in extensions, day+4 9am (ends 12pm)
  Appointment.create!(
    stylist:          priya_s,
    customer:         caleb,
    location_id:      priya_s_loc1.id,
    salon:            priya_s.name,
    time:             (today + 4).beginning_of_day + 9.hours,
    end_time:         (today + 4).beginning_of_day + 9.hours + priya_s_tapein.duration_minutes.minutes,
    selected_service: "#{priya_s_tapein.name} - $#{sprintf('%.2f', priya_s_tapein.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   priya_s_tapein.price,
    content:          "Caleb's partner is getting tape-ins for added length — booking is in Caleb's name. Natural hair is fine and blonde, wants extensions to blend seamlessly."
  )

  # Ben — men's cut & style, day+5 10am (ends 10:50am)
  Appointment.create!(
    stylist:          ben,
    customer:         miguel,
    location_id:      ben_loc.id,
    salon:            ben.name,
    time:             (today + 5).beginning_of_day + 10.hours,
    end_time:         (today + 5).beginning_of_day + 10.hours + ben_mens.duration_minutes.minutes,
    selected_service: "#{ben_mens.name} - $#{sprintf('%.2f', ben_mens.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   ben_mens.price,
    content:          "Miguel has thick, wavy 2B hair and wants a cut that works with the texture — not against it. Interested in a slightly longer top with clean sides."
  )

  # Taylor — clarifying detox, day+9 10am (ends 11am) — no overlap with Nina day+3
  Appointment.create!(
    stylist:          taylor,
    customer:         destiny,
    location_id:      taylor_loc1.id,
    salon:            taylor.name,
    time:             (today + 9).beginning_of_day + 10.hours,
    end_time:         (today + 9).beginning_of_day + 10.hours + taylor_detox.duration_minutes.minutes,
    selected_service: "#{taylor_detox.name} - $#{sprintf('%.2f', taylor_detox.price)}",
    status:           :booked,
    payment_status:   "paid",
    payment_id:       "DEV_DEPOSIT_#{SecureRandom.hex(8)}",
    payment_amount:   taylor_detox.price,
    content:          "Destiny has been using a lot of dry shampoo and product and feels her scalp is congested. Wants a full clarifying detox to reset before summer."
  )

  puts "  Pending:  #{Appointment.pending.count}"
  puts "  Booked:   #{Appointment.booked.count}"

  # ----------------------------------------------------------
  # COMPLETED (12) — past appointments, 1-8 weeks ago
  #
  # payment_status note: 'collected_in_person' is not a valid
  # enum value (model allows: pending deposit_paid balance_due
  # paid refunded deposit_kept failed). Using 'paid' throughout.
  # Appointments where the balance was collected in person are
  # marked with balance_collected = service.price * 0.5 and
  # balance_payment_id set; fully-Square-paid ones leave those nil.
  # ----------------------------------------------------------

  # Maya — silk press — emma — 2 weeks ago (paid + in-person balance)
  t = 2.weeks.ago.beginning_of_day + 10.hours
  Appointment.create!(
    stylist:            maya,
    customer:           emma,
    location_id:        maya_loc1.id,
    salon:              maya.name,
    time:               t,
    end_time:           t + maya_silk_press.duration_minutes.minutes,
    completed_at:       t + maya_silk_press.duration_minutes.minutes,
    selected_service:   "#{maya_silk_press.name} - $#{sprintf('%.2f', maya_silk_press.price)}",
    status:             :completed,
    payment_status:     "paid",
    payment_amount:     maya_silk_press.price,
    payment_id:         "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    balance_payment_id: "DEV_BALANCE_#{SecureRandom.hex(8)}",
    balance_collected:  (maya_silk_press.price * 0.5).round(2),
    payment_method:     "square",
    content:            "Emma wanted a sleek silk press for a work event. Medium heat, finished with a shine serum. Left very happy."
  )

  # Maya — big chop — caleb — 5 weeks ago (paid + in-person balance)
  t = 5.weeks.ago.beginning_of_day + 9.hours
  Appointment.create!(
    stylist:            maya,
    customer:           caleb,
    location_id:        maya_loc1.id,
    salon:              maya.name,
    time:               t,
    end_time:           t + maya_big_chop.duration_minutes.minutes,
    completed_at:       t + maya_big_chop.duration_minutes.minutes,
    selected_service:   "#{maya_big_chop.name} - $#{sprintf('%.2f', maya_big_chop.price)}",
    status:             :completed,
    payment_status:     "paid",
    payment_amount:     maya_big_chop.price,
    payment_id:         "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    balance_payment_id: "DEV_BALANCE_#{SecureRandom.hex(8)}",
    balance_collected:  (maya_big_chop.price * 0.5).round(2),
    payment_method:     "square",
    content:            "Caleb was transitioning from a texturizer and ready to go fully natural. Emotional appointment — cut went great and he loved the result."
  )

  # Derek — men's fade — james — 3 weeks ago (paid + in-person balance)
  t = 3.weeks.ago.beginning_of_day + 9.hours
  Appointment.create!(
    stylist:            derek,
    customer:           james,
    location_id:        derek_loc.id,
    salon:              derek.name,
    time:               t,
    end_time:           t + derek_fade.duration_minutes.minutes,
    completed_at:       t + derek_fade.duration_minutes.minutes,
    selected_service:   "#{derek_fade.name} - $#{sprintf('%.2f', derek_fade.price)}",
    status:             :completed,
    payment_status:     "paid",
    payment_amount:     derek_fade.price,
    payment_id:         "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    balance_payment_id: "DEV_BALANCE_#{SecureRandom.hex(8)}",
    balance_collected:  (derek_fade.price * 0.5).round(2),
    payment_method:     "square",
    content:            "James wanted a fresh low skin fade before a job interview. Sharp line-up and temple taper. Walked out confident."
  )

  # Derek — beard shape-up — ryan — 6 weeks ago (fully paid via Square)
  t = 6.weeks.ago.beginning_of_day + 10.hours
  Appointment.create!(
    stylist:          derek,
    customer:         ryan,
    location_id:      derek_loc.id,
    salon:            derek.name,
    time:             t,
    end_time:         t + derek_beard.duration_minutes.minutes,
    completed_at:     t + derek_beard.duration_minutes.minutes,
    selected_service: "#{derek_beard.name} - $#{sprintf('%.2f', derek_beard.price)}",
    status:           :completed,
    payment_status:   "paid",
    payment_amount:   derek_beard.price,
    payment_id:       "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:   "square",
    content:          "Ryan came in for a beard clean-up — angled cheeks, square chin, finished with beard balm. Quick and precise."
  )

  # Sofia — full color — olivia — 4 weeks ago (paid + in-person balance)
  t = 4.weeks.ago.beginning_of_day + 10.hours
  Appointment.create!(
    stylist:            sofia,
    customer:           olivia,
    location_id:        sofia_loc.id,
    salon:              sofia.name,
    time:               t,
    end_time:           t + sofia_full_color.duration_minutes.minutes,
    completed_at:       t + sofia_full_color.duration_minutes.minutes,
    selected_service:   "#{sofia_full_color.name} - $#{sprintf('%.2f', sofia_full_color.price)}",
    status:             :completed,
    payment_status:     "paid",
    payment_amount:     sofia_full_color.price,
    payment_id:         "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    balance_payment_id: "DEV_BALANCE_#{SecureRandom.hex(8)}",
    balance_collected:  (sofia_full_color.price * 0.5).round(2),
    payment_method:     "square",
    content:            "Olivia wanted to go from medium brown to a rich espresso. Full single-process color with a blowout finish. Came out beautifully dimensional."
  )

  # Jordan — DevaCut — zoe — 2 weeks ago (fully paid via Square)
  t = 2.weeks.ago.beginning_of_day + 11.hours
  Appointment.create!(
    stylist:          jordan,
    customer:         zoe,
    location_id:      jordan_loc1.id,
    salon:            jordan.name,
    time:             t,
    end_time:         t + jordan_deva.duration_minutes.minutes,
    completed_at:     t + jordan_deva.duration_minutes.minutes,
    selected_service: "#{jordan_deva.name} - $#{sprintf('%.2f', jordan_deva.price)}",
    status:           :completed,
    payment_status:   "paid",
    payment_amount:   jordan_deva.price,
    payment_id:       "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:   "square",
    content:          "Zoe's first DevaCut — she's been wanting to embrace her 3B curls. Curl-by-curl cut, finished with a diffuse. She couldn't believe the definition."
  )

  # Aaliyah — event blowout — destiny — 3 weeks ago (fully paid via Square)
  t = 3.weeks.ago.beginning_of_day + 14.hours
  Appointment.create!(
    stylist:          aaliyah,
    customer:         destiny,
    location_id:      aaliyah_loc.id,
    salon:            aaliyah.name,
    time:             t,
    end_time:         t + aaliyah_blowout.duration_minutes.minutes,
    completed_at:     t + aaliyah_blowout.duration_minutes.minutes,
    selected_service: "#{aaliyah_blowout.name} - $#{sprintf('%.2f', aaliyah_blowout.price)}",
    status:           :completed,
    payment_status:   "paid",
    payment_amount:   aaliyah_blowout.price,
    payment_id:       "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:   "square",
    content:          "Destiny needed a sleek blowout for her company's gala. Big, bouncy volume with a round-brush finish. She looked stunning."
  )

  # Marcus S — full groom package — marcus_c — 5 weeks ago (paid + in-person balance)
  t = 5.weeks.ago.beginning_of_day + 9.hours
  Appointment.create!(
    stylist:            marcus_s,
    customer:           marcus_c,
    location_id:        marcus_s_loc.id,
    salon:              marcus_s.name,
    time:               t,
    end_time:           t + marcus_s_groom.duration_minutes.minutes,
    completed_at:       t + marcus_s_groom.duration_minutes.minutes,
    selected_service:   "#{marcus_s_groom.name} - $#{sprintf('%.2f', marcus_s_groom.price)}",
    status:             :completed,
    payment_status:     "paid",
    payment_amount:     marcus_s_groom.price,
    payment_id:         "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    balance_payment_id: "DEV_BALANCE_#{SecureRandom.hex(8)}",
    balance_collected:  (marcus_s_groom.price * 0.5).round(2),
    payment_method:     "square",
    content:            "Marcus came in for the full package before a friend's wedding — high-top, beard shape, hot towel. Said it was his best appointment yet."
  )

  # Priya S — extension removal — aisha — 7 weeks ago (fully paid via Square)
  t = 7.weeks.ago.beginning_of_day + 10.hours
  Appointment.create!(
    stylist:          priya_s,
    customer:         aisha,
    location_id:      priya_s_loc1.id,
    salon:            priya_s.name,
    time:             t,
    end_time:         t + priya_s_removal.duration_minutes.minutes,
    completed_at:     t + priya_s_removal.duration_minutes.minutes,
    selected_service: "#{priya_s_removal.name} - $#{sprintf('%.2f', priya_s_removal.price)}",
    status:           :completed,
    payment_status:   "paid",
    payment_amount:   priya_s_removal.price,
    payment_id:       "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:   "square",
    content:          "Aisha had tape-in extensions from another stylist and needed them carefully removed before installing a fresh set. Natural hair was in good condition underneath."
  )

  # Claire — loc retwist — leo — 4 weeks ago (paid + in-person balance)
  t = 4.weeks.ago.beginning_of_day + 9.hours
  Appointment.create!(
    stylist:            claire,
    customer:           leo,
    location_id:        claire_loc.id,
    salon:              claire.name,
    time:               t,
    end_time:           t + claire_retwist.duration_minutes.minutes,
    completed_at:       t + claire_retwist.duration_minutes.minutes,
    selected_service:   "#{claire_retwist.name} - $#{sprintf('%.2f', claire_retwist.price)}",
    status:             :completed,
    payment_status:     "paid",
    payment_amount:     claire_retwist.price,
    payment_id:         "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    balance_payment_id: "DEV_BALANCE_#{SecureRandom.hex(8)}",
    balance_collected:  (claire_retwist.price * 0.5).round(2),
    payment_method:     "square",
    content:            "Leo's locs were 6 months in and needed their first real retwist. Palm-roll method, parting was clean and even. He left with healthy, defined roots."
  )

  # Ben — precision cut — miguel — 6 weeks ago (fully paid via Square)
  t = 6.weeks.ago.beginning_of_day + 11.hours
  Appointment.create!(
    stylist:          ben,
    customer:         miguel,
    location_id:      ben_loc.id,
    salon:            ben.name,
    time:             t,
    end_time:         t + ben_precision.duration_minutes.minutes,
    completed_at:     t + ben_precision.duration_minutes.minutes,
    selected_service: "#{ben_precision.name} - $#{sprintf('%.2f', ben_precision.price)}",
    status:           :completed,
    payment_status:   "paid",
    payment_amount:   ben_precision.price,
    payment_id:       "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:   "square",
    content:          "Miguel wanted his wavy hair cut to work with his texture. Removed bulk from the sides, left length on top. He's been wearing it natural since."
  )

  # Taylor — scalp analysis — hannah — 3 weeks ago (fully paid via Square)
  t = 3.weeks.ago.beginning_of_day + 9.hours
  Appointment.create!(
    stylist:          taylor,
    customer:         hannah,
    location_id:      taylor_loc1.id,
    salon:            taylor.name,
    time:             t,
    end_time:         t + taylor_analysis.duration_minutes.minutes,
    completed_at:     t + taylor_analysis.duration_minutes.minutes,
    selected_service: "#{taylor_analysis.name} - $#{sprintf('%.2f', taylor_analysis.price)}",
    status:           :completed,
    payment_status:   "paid",
    payment_amount:   taylor_analysis.price,
    payment_id:       "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:   "square",
    content:          "Hannah was concerned about thinning at her temples. Taylor did a full scalp analysis under magnification and prescribed a treatment protocol to start immediately."
  )

  puts "  Completed: #{Appointment.completed.count}"

  # ----------------------------------------------------------
  # CANCELLED (5) — past appointments
  # cancelled_at is always before appointment time.
  # Overlap validator only checks pending/booked, so past
  # cancelled records are exempt regardless of time proximity
  # to completed ones.
  # payment_amount = deposit (half of service price).
  # ----------------------------------------------------------

  # 1. Customer cancels in advance — sofia / priya_c / Highlights
  #    Appointment: 3 weeks ago 10am. Cancelled 2 days before → full refund.
  t = 3.weeks.ago.beginning_of_day + 10.hours
  Appointment.create!(
    stylist:             sofia,
    customer:            priya_c,
    location_id:         sofia_loc.id,
    salon:               sofia.name,
    time:                t,
    end_time:            t + sofia_highlights.duration_minutes.minutes,
    selected_service:    "#{sofia_highlights.name} - $#{sprintf('%.2f', sofia_highlights.price)}",
    status:              :cancelled,
    payment_status:      "refunded",
    payment_amount:      (sofia_highlights.price * 0.5).round(2),
    payment_id:          "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:      "square",
    cancelled_by:        "customer",
    cancelled_by_id:     priya_c.id,
    cancelled_at:        (3.weeks.ago - 2.days).beginning_of_day + 9.hours,
    cancellation_reason: "I have a destination bachelorette trip that weekend and completely forgot I had this booked. So sorry for the inconvenience!",
    content:             "Priya wanted partial foil highlights — warm caramel tones through the mid-lengths and ends on her dark brown base."
  )

  # 2. Customer cancels last-minute — jordan / james / Co-Wash & Style
  #    Appointment: 2 weeks ago 9am. Cancelled 2 hours before → deposit kept (within 24h window).
  t = 2.weeks.ago.beginning_of_day + 9.hours
  Appointment.create!(
    stylist:             jordan,
    customer:            james,
    location_id:         jordan_loc1.id,
    salon:               jordan.name,
    time:                t,
    end_time:            t + jordan_cowash.duration_minutes.minutes,
    selected_service:    "#{jordan_cowash.name} - $#{sprintf('%.2f', jordan_cowash.price)}",
    status:              :cancelled,
    payment_status:      "deposit_kept",
    payment_amount:      (jordan_cowash.price * 0.5).round(2),
    payment_id:          "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:      "square",
    cancelled_by:        "customer",
    cancelled_by_id:     james.id,
    cancelled_at:        2.weeks.ago.beginning_of_day + 7.hours,
    cancellation_reason: "Car trouble this morning — I can't make it in. Really sorry, I know it's last minute.",
    content:             "James wanted a full co-wash refresh and a defined wash-and-go set. First appointment with Jordan."
  )

  # 3. Stylist cancels — aaliyah / simone / Trial Run Style
  #    Appointment: 6 weeks ago 11am. Cancelled the evening before → full refund (stylist initiated).
  t = 6.weeks.ago.beginning_of_day + 11.hours
  Appointment.create!(
    stylist:             aaliyah,
    customer:            simone,
    location_id:         aaliyah_loc.id,
    salon:               aaliyah.name,
    time:                t,
    end_time:            t + aaliyah_trial.duration_minutes.minutes,
    selected_service:    "#{aaliyah_trial.name} - $#{sprintf('%.2f', aaliyah_trial.price)}",
    status:              :cancelled,
    payment_status:      "refunded",
    payment_amount:      (aaliyah_trial.price * 0.5).round(2),
    payment_id:          "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:      "square",
    cancelled_by:        "stylist",
    cancelled_by_id:     aaliyah.id,
    cancelled_at:        (6.weeks.ago - 1.day).beginning_of_day + 20.hours,
    cancellation_reason: "I have a family emergency and need to cancel tomorrow's appointments. I'm so sorry, Simone — your deposit has been fully refunded and I'd love to reschedule.",
    content:             "Simone's bridal trial — wants a low bun with baby hair laid and a few cascading curls framing her face."
  )

  # 4. Customer cancels well in advance — ben / daniel / Japanese Straightening
  #    Appointment: 4 weeks ago 10am. Cancelled 8 days before → full refund.
  t = 4.weeks.ago.beginning_of_day + 10.hours
  Appointment.create!(
    stylist:             ben,
    customer:            daniel,
    location_id:         ben_loc.id,
    salon:               ben.name,
    time:                t,
    end_time:            t + ben_japanese.duration_minutes.minutes,
    selected_service:    "#{ben_japanese.name} - $#{sprintf('%.2f', ben_japanese.price)}",
    status:              :cancelled,
    payment_status:      "refunded",
    payment_amount:      (ben_japanese.price * 0.5).round(2),
    payment_id:          "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:      "square",
    cancelled_by:        "customer",
    cancelled_by_id:     daniel.id,
    cancelled_at:        5.weeks.ago.beginning_of_day + 14.hours,
    cancellation_reason: "After thinking it over I've decided to stick with my natural texture for now and hold off on the straightening treatment.",
    content:             "Daniel wanted a Japanese straightening treatment to eliminate frizz — his hair is coarse and high-density 2C."
  )

  # 5. Stylist cancels same-day — taylor / evan / Growth Stimulation Treatment
  #    Appointment: 5 weeks ago 9am. Cancelled 2 hours before → full refund (stylist initiated).
  t = 5.weeks.ago.beginning_of_day + 9.hours
  Appointment.create!(
    stylist:             taylor,
    customer:            evan,
    location_id:         taylor_loc1.id,
    salon:               taylor.name,
    time:                t,
    end_time:            t + taylor_growth.duration_minutes.minutes,
    selected_service:    "#{taylor_growth.name} - $#{sprintf('%.2f', taylor_growth.price)}",
    status:              :cancelled,
    payment_status:      "refunded",
    payment_amount:      (taylor_growth.price * 0.5).round(2),
    payment_id:          "DEV_PAYMENT_#{SecureRandom.hex(8)}",
    payment_method:      "square",
    cancelled_by:        "stylist",
    cancelled_by_id:     taylor.id,
    cancelled_at:        5.weeks.ago.beginning_of_day + 7.hours,
    cancellation_reason: "I woke up with a fever this morning and need to cancel today's appointments. Your deposit has been fully refunded — I'll reach out to reschedule as soon as I'm well.",
    content:             "Evan has been experiencing diffuse thinning at the crown for about 6 months. Looking for a science-backed treatment protocol."
  )

  puts "  Cancelled: #{Appointment.cancelled.count}"

  # ----------------------------------------------------------
  # APPOINTMENT ADD-ONS (~35% of all appointments)
  # Appointments were not stored in variables, so we look them
  # up by stylist + customer + status — each combo is unique.
  # price: service.price returns price_cents / 100.0 (dollars),
  # which maps correctly to the decimal(8,2) price column.
  # ----------------------------------------------------------
  puts "Creating appointment add-ons..."

  # Helper to fetch an add-on service by name for a given stylist
  addon = ->(stylist_user, name) { stylist_user.services.find_by!(name: name, is_add_on: true) }
  appt  = ->(stylist_user, customer_user, appt_status) {
    Appointment.find_by!(stylist: stylist_user, customer: customer_user, status: appt_status)
  }

  # ---- PENDING appointments with add-ons (4) ----

  # Maya / Emma — Silk Press → Deep Conditioning Treatment
  svc = addon.(maya, "Deep Conditioning Treatment")
  AppointmentAddOn.create!(appointment: appt.(maya, emma, :pending), service: svc,
                            service_name: svc.name, price: svc.price)

  # Derek / James — Men's Fade → Razor Line-Up
  svc = addon.(derek, "Razor Line-Up")
  AppointmentAddOn.create!(appointment: appt.(derek, james, :pending), service: svc,
                            service_name: svc.name, price: svc.price)

  # Sofia / Olivia — Balayage → Olaplex Treatment + Toning Gloss
  svc = addon.(sofia, "Olaplex Treatment")
  AppointmentAddOn.create!(appointment: appt.(sofia, olivia, :pending), service: svc,
                            service_name: svc.name, price: svc.price)
  svc = addon.(sofia, "Toning Gloss")
  AppointmentAddOn.create!(appointment: appt.(sofia, olivia, :pending), service: svc,
                            service_name: svc.name, price: svc.price)

  # Jordan / Tyler — Curly Cut → Curl Defining Treatment
  svc = addon.(jordan, "Curl Defining Treatment")
  AppointmentAddOn.create!(appointment: appt.(jordan, tyler, :pending), service: svc,
                            service_name: svc.name, price: svc.price)

  # ---- BOOKED appointments with add-ons (4) ----

  # Maya / Aisha — Wash & Go → Scalp Massage + Protein Treatment
  svc = addon.(maya, "Scalp Massage")
  AppointmentAddOn.create!(appointment: appt.(maya, aisha, :booked), service: svc,
                            service_name: svc.name, price: svc.price)
  svc = addon.(maya, "Protein Treatment")
  AppointmentAddOn.create!(appointment: appt.(maya, aisha, :booked), service: svc,
                            service_name: svc.name, price: svc.price)

  # Derek / Evan — Beard Shape-Up → Hot Towel Treatment + Beard Conditioning
  svc = addon.(derek, "Hot Towel Treatment")
  AppointmentAddOn.create!(appointment: appt.(derek, evan, :booked), service: svc,
                            service_name: svc.name, price: svc.price)
  svc = addon.(derek, "Beard Conditioning")
  AppointmentAddOn.create!(appointment: appt.(derek, evan, :booked), service: svc,
                            service_name: svc.name, price: svc.price)

  # Sofia / Hannah — Cut & Style → Deep Conditioning
  svc = addon.(sofia, "Deep Conditioning")
  AppointmentAddOn.create!(appointment: appt.(sofia, hannah, :booked), service: svc,
                            service_name: svc.name, price: svc.price)

  # Aaliyah / Jasmine — Half-Up Style → Hair Accessory Placement
  svc = addon.(aaliyah, "Hair Accessory Placement")
  AppointmentAddOn.create!(appointment: appt.(aaliyah, jasmine, :booked), service: svc,
                            service_name: svc.name, price: svc.price)

  # ---- COMPLETED appointments with add-ons (5) ----

  # Maya / Emma — Silk Press (completed) → Deep Conditioning Treatment
  svc = addon.(maya, "Deep Conditioning Treatment")
  AppointmentAddOn.create!(appointment: appt.(maya, emma, :completed), service: svc,
                            service_name: svc.name, price: svc.price)

  # Derek / James — Men's Fade (completed) → Hot Towel Treatment
  svc = addon.(derek, "Hot Towel Treatment")
  AppointmentAddOn.create!(appointment: appt.(derek, james, :completed), service: svc,
                            service_name: svc.name, price: svc.price)

  # Sofia / Olivia — Full Color (completed) → Olaplex Treatment
  svc = addon.(sofia, "Olaplex Treatment")
  AppointmentAddOn.create!(appointment: appt.(sofia, olivia, :completed), service: svc,
                            service_name: svc.name, price: svc.price)

  # Ben / Miguel — Precision Cut (completed) → Gloss Treatment
  svc = addon.(ben, "Gloss Treatment")
  AppointmentAddOn.create!(appointment: appt.(ben, miguel, :completed), service: svc,
                            service_name: svc.name, price: svc.price)

  # Taylor / Hannah — Scalp Analysis (completed) → Scalp Oil Infusion + Biotin Scalp Mask
  svc = addon.(taylor, "Scalp Oil Infusion")
  AppointmentAddOn.create!(appointment: appt.(taylor, hannah, :completed), service: svc,
                            service_name: svc.name, price: svc.price)
  svc = addon.(taylor, "Biotin Scalp Mask")
  AppointmentAddOn.create!(appointment: appt.(taylor, hannah, :completed), service: svc,
                            service_name: svc.name, price: svc.price)

  puts "  Created #{AppointmentAddOn.count} add-ons across #{Appointment.joins(:appointment_add_ons).distinct.count} appointments."

  # ----------------------------------------------------------
  # REVIEWS (~75% of completed appointments = 9 of 12)
  # Skipped: Derek/Ryan, Priya S/Aisha, Ben/Miguel
  #
  # Uses save!(validate: false) to bypass within_review_window
  # (which would reject all seed reviews since completed_at is
  # weeks ago). The DB unique index on appointment_id still
  # enforces one-review-per-appointment at the database level.
  # stylist_responded_at is set alongside stylist_response.
  # ----------------------------------------------------------
  puts "Creating reviews..."

  # Helper: look up completed appointment, build and save review
  make_review = ->(attrs) {
    r = Review.new(attrs)
    r.save!(validate: false)
    r
  }

  # 1. Maya / Emma — Silk Press — 5★
  a = Appointment.find_by!(stylist: maya, customer: emma, status: :completed)
  make_review.(
    appointment: a, customer: emma, stylist: maya,
    rating:      5,
    content:     "Maya's silk press was absolutely flawless — my hair had so much shine and movement without a trace of heat damage. She took her time on every section and made sure I was happy before I left. I'll be booking with her every month.",
    created_at:  a.completed_at + 1.day
  )

  # 2. Maya / Caleb — Big Chop — 5★
  a = Appointment.find_by!(stylist: maya, customer: caleb, status: :completed)
  make_review.(
    appointment: a, customer: caleb, stylist: maya,
    rating:      5,
    content:     "I was honestly terrified about the big chop, but Maya made me feel completely at ease from the moment I sat down. She shaped my natural coils beautifully and gave me a whole new appreciation for my texture. Best hair decision I've ever made.",
    created_at:  a.completed_at + 2.days
  )

  # 3. Derek / James — Men's Fade — 5★
  a = Appointment.find_by!(stylist: derek, customer: james, status: :completed)
  make_review.(
    appointment: a, customer: james, stylist: derek,
    rating:      5,
    content:     "Derek's fades are surgical — the skin blend was seamless and the line-up was razor sharp. Quick, efficient, and the result speaks for itself. He's the only barber I'll trust with my hair in this city.",
    created_at:  a.completed_at + 1.day
  )

  # 4. Sofia / Olivia — Full Color — 4★
  a = Appointment.find_by!(stylist: sofia, customer: olivia, status: :completed)
  make_review.(
    appointment: a, customer: olivia, stylist: sofia,
    rating:      4,
    content:     "Sofia did a gorgeous job transforming my hair — the rich espresso color has incredible shine and depth, exactly what I envisioned. The appointment ran about 30 minutes longer than quoted, but the quality of the result made it worth the wait.",
    created_at:  a.completed_at + 1.day
  )

  # 5. Jordan / Zoe — DevaCut — 5★
  a = Appointment.find_by!(stylist: jordan, customer: zoe, status: :completed)
  make_review.(
    appointment: a, customer: zoe, stylist: jordan,
    rating:      5,
    content:     "I've been trying to embrace my curls for years and Jordan's DevaCut completely changed everything. She cut curl-by-curl and the shape she gave my 3B hair is something I've never been able to achieve before. Already booked my next appointment.",
    created_at:  a.completed_at + 2.days
  )

  # 6. Aaliyah / Destiny — Event Blowout — 4★
  a = Appointment.find_by!(stylist: aaliyah, customer: destiny, status: :completed)
  make_review.(
    appointment: a, customer: destiny, stylist: aaliyah,
    rating:      4,
    content:     "Aaliyah gave me a stunning blowout that held all night at the gala — big, bouncy volume that I got compliments on all evening. She was warm and professional throughout. Would definitely book her again for my next event.",
    created_at:  a.completed_at + 1.day
  )

  # 7. Marcus S / Marcus C — Full Groom — 5★  + stylist response
  a = Appointment.find_by!(stylist: marcus_s, customer: marcus_c, status: :completed)
  make_review.(
    appointment:        a, customer: marcus_c, stylist: marcus_s,
    rating:             5,
    content:            "Marcus is a true master of his craft. The high-top was perfectly sculpted, the beard shape-up was impossibly clean, and the hot towel finish was the touch that tied it all together. Walked out feeling like a completely different person.",
    stylist_response:   "Really appreciate that, brother — that's what we're here for. Come back anytime and we'll keep you looking right.",
    stylist_responded_at: a.completed_at + 4.days,
    created_at:         a.completed_at + 3.days
  )

  # 8. Claire / Leo — Loc Retwist — 3★
  a = Appointment.find_by!(stylist: claire, customer: leo, status: :completed)
  make_review.(
    appointment: a, customer: leo, stylist: claire,
    rating:      3,
    content:     "Claire's retwist work is solid — the parting is even and my roots are looking clean. I did have to wait about 20 minutes past my start time with no heads-up, which threw off my afternoon. The quality is there, I just wish the scheduling communication was tighter.",
    created_at:  a.completed_at + 2.days
  )

  # 9. Taylor / Hannah — Scalp Analysis — 4★  + stylist response
  a = Appointment.find_by!(stylist: taylor, customer: hannah, status: :completed)
  make_review.(
    appointment:         a, customer: hannah, stylist: taylor,
    rating:              4,
    content:             "Taylor's scalp analysis was the most thorough hair appointment I've ever had — she identified issues I didn't even know I had and gave me a clear, science-backed protocol to follow at home. I felt genuinely heard. Excited to see the results over the next few months.",
    stylist_response:    "Thank you so much, Hannah! Consistency with the protocol will make all the difference — I can't wait to see your progress at our next session.",
    stylist_responded_at: a.completed_at + 3.days,
    created_at:          a.completed_at + 1.day
  )

  puts "  Created #{Review.count} reviews (#{Review.where.not(stylist_response: nil).count} with stylist responses)."

end

puts "Done."
