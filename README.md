# ChairHop

ChairHop is a two-sided booking marketplace connecting clients with independent hair stylists. Stylists set up their services, locations, and availability; clients discover stylists, book appointments, and pay a 50% deposit at booking with the balance collected at completion. The platform includes HOPPS — an AI assistant that helps clients find stylists and answers hair questions, and helps stylists navigate the platform and communicate with clients.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Rails 7.1 (Hotwire / Turbo / Stimulus) |
| Database | PostgreSQL + pgvector (appointment embeddings) |
| Auth | Devise (with email confirmation) |
| Authorization | Pundit |
| Payments | Square (card vaulting, checkout links, webhooks) |
| File uploads | Active Storage + Cloudinary |
| AI | OpenAI GPT-4o / GPT-4.1-nano via RubyLLM |
| Background jobs | Solid Queue |
| Real-time | Solid Cable (Action Cable over DB) |
| Frontend | Bootstrap 5.3, Stimulus, Flatpickr, Importmap |
| Deployment | Heroku |

---

## Getting Started

### Prerequisites

- Ruby 3.3.5
- PostgreSQL with pgvector extension enabled

### Setup

```bash
git clone <repo-url>
cd ChairHop_App_2
bundle install
cp .env.example .env   # fill in credentials (ask team lead)
rails db:create db:migrate db:seed
rails s
```

Visit `http://localhost:3000`

---

## Environment Variables

All credentials live in `.env` (not committed). Ask the team lead for values.

| Variable | Purpose |
|---|---|
| `OPENAI_API_KEY` | OpenAI API key for HOPPS AI assistant |
| `SQUARE_ACCESS_TOKEN` | Square sandbox access token |
| `SQUARE_APPLICATION_ID` | Square OAuth application ID |
| `SQUARE_APPLICATION_SECRET` | Square OAuth application secret |
| `SQUARE_ENVIRONMENT` | `sandbox` or `production` |
| `SQUARE_OAUTH_REDIRECT_URI` | Square OAuth callback URL |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary image hosting cloud name |
| `CLOUDINARY_API_KEY` | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret |
| `APP_HOST` | Production host (e.g. `chairhop.com`) — used for mailer links and Square redirects |

---

## Seed Accounts

After `rails db:seed`, all accounts use password `password123`.

All 8 seed stylists are pre-configured as **founding stylists** (0% platform fee).

**Stylists**

| Name | Email | Specialty |
|---|---|---|
| Maya Johnson | maya@example.com | Natural hair / silk press |
| Derek Kim | derek@example.com | Barber / fades |
| Sofia Rivera | sofia@example.com | Color / balayage |
| Jordan Hayes | jordan@example.com | Curls / DevaCut |
| Aaliyah Brooks | aaliyah@example.com | Bridal / occasion |
| Marcus Dupont | marcus@example.com | Barber / high-top fades |
| Priya Menon | priya@example.com | Extensions |
| Claire Osei | claire@example.com | Locs |

**Customers:** emma, james, olivia, tyler, zoe, aisha, leo, nina, caleb, simone — all `@example.com`

---

## User Roles

| Role | Description |
|---|---|
| `customer` | Discovers stylists, books appointments, pays via Square, reviews, messages |
| `stylist` | Manages services, locations, availability; accepts bookings; processes payments |
| `admin` | Views all users, toggles founding stylist flag |

---

## Features

### Legal
- Privacy Policy, Terms of Service, and Payment Terms pages publicly accessible at `/privacy`, `/terms`, `/payment-terms`
- Footer on every page links to all three policy pages
- All users must agree to Terms of Service + Privacy Policy at signup; stylists must additionally agree to Payment Terms

### Stylist
- Guided 4-step onboarding: avatar & bio → services → locations → Square OAuth connect
- Service management: name, description, price, duration, photo, add-on flag, active/inactive toggle
- Multi-location management (address, city, state, zip)
- Availability block scheduling: date/time window per location, optionally restricted to specific services
- Appointment lifecycle: accept or decline pending requests, mark complete, cancel with optional refund
- Unique shareable booking link (`/book/:slug`)
- Portfolio photo uploads (up to 12 photos)
- Public review responses
- Analytics dashboard: total earnings, monthly earnings, booking counts, top services
- Real-time direct messaging with clients (per appointment, via Action Cable)
- HOPPS AI assistant: platform guidance, client communication coaching

### Customer
- Stylist discovery: browse by name, service type, city, date; view profile, portfolio, reviews
- Browse available time slots grouped by date
- Full booking flow: select service + optional add-ons → review deposit cost → Square checkout
- 50% deposit charged at booking; 50% balance collected at completion
- Email confirmations at every stage (request sent, accepted, completed, receipts)
- Cancel with automatic deposit refund if cancelled 24+ hours before appointment
- Real-time direct messaging with stylist (per appointment, via Action Cable)
- HOPPS AI assistant: finds local stylists, answers hair questions, helps with platform navigation
- Star rating + photo reviews (up to 2 photos, 3-day edit window)

### Payments (Square)
- **Deposit model**: 50% charged at booking via vaulted card; 50% balance collected on completion
- Stylist can charge balance automatically (card on file) or send a Square checkout link to the client
- Full deposit refund if cancelled 24+ hours before appointment
- Founding stylists: 0% platform fee. All others: 4.5% fee applied via Square `app_fee_money` on each payment
- Sandbox test card: `4111 1111 1111 1111`, any CVV/expiry

---

## Email Notifications

Automated emails are sent via `AppointmentMailer` and `UserMailer`:

| Trigger | Recipient |
|---|---|
| New booking request | Stylist |
| Booking request sent confirmation | Customer |
| Stylist accepts booking | Customer |
| Stylist declines booking | Customer |
| Cancellation (by either party) | Opposing party |
| Deposit refunded | Customer |
| Appointment completed receipt | Customer |
| Review request after completion | Customer |
| Stylist responds to review | Customer |
| Balance payment link sent | Customer |
| Balance payment received | Stylist |
| Balance receipt | Customer |
| Balance payment failed | Customer |
| Balance collected in person | Stylist |
| Account welcome | Customer / Stylist |

---

## Project Structure

```
app/
├── controllers/
│   ├── stylist/           # Stylist-namespaced actions (dashboard, services, appointments, etc.)
│   ├── admin/             # Admin user management
│   ├── webhooks/          # Square webhook handler
│   └── ...                # Bookings, reviews, chats, conversations, profiles
├── models/                # User, Appointment, Service, AvailabilityBlock, Review, Conversation, Chat, ...
├── policies/              # Pundit authorization policies
├── services/              # PaymentService (Square), HoppsService (AI prompts)
├── mailers/               # AppointmentMailer (14 templates), UserMailer
├── jobs/                  # Solid Queue background jobs
└── views/
    ├── stylist/           # Stylist dashboard, appointments, services, onboarding, reviews, analytics
    ├── admin/             # Admin user list
    └── ...                # Public pages, booking flow, conversations, chats

app/javascript/controllers/
├── booking_form_controller.js      # Date picker, time slots, service/add-on selection, deposit calc
├── square_payment_controller.js    # Square nonce generation and form submission
├── chat_message_controller.js      # HOPPS chat input, quick suggestions, image preview
├── conversation_controller.js      # Real-time direct messaging
├── availability_calendar_controller.js
├── email_check_controller.js       # Real-time email availability on signup
└── ...

db/
├── schema.rb
└── seeds.rb
```

---

## Key Models

| Model | Notes |
|---|---|
| `User` | Roles: customer / stylist / admin. Stylists have `booking_slug`, onboarding state, Square credentials, `founding_stylist` flag. |
| `Service` | Belongs to stylist. Stores `price_cents` and `duration_minutes`. Supports add-ons (`is_add_on`). Active/inactive. |
| `AvailabilityBlock` | Open time window for a stylist at a location. Can be restricted to specific services. |
| `Appointment` | Links customer + stylist + location + block. Statuses: `pending` → `booked` → `completed` / `cancelled`. Tracks deposit, balance, Square payment IDs. |
| `AppointmentAddOn` | Additional services attached to an appointment with price snapshot. |
| `Review` | One per completed appointment. 1–5 stars, text, up to 2 photos. Editable for 3 days. Supports public stylist response. |
| `Conversation` / `ConversationMessage` | Direct messaging per appointment. Turbo-streamed. Supports photo attachments. |
| `Chat` / `Message` | AI (HOPPS) chat sessions. Optionally linked to an appointment. Supports image uploads. |
| `Location` | Stylist work address. Linked to availability blocks and appointments. |
| `UserSquareCustomer` | Junction table storing Square customer IDs per stylist–client pair, enabling card vaulting per merchant. |
