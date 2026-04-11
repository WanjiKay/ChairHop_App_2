# ChairHop

A booking platform connecting customers with independent hair stylists. Stylists manage their services, availability, and payments. Customers discover stylists, book appointments, and communicate directly through the app.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Rails 7.1 (Hotwire/Turbo/Stimulus) |
| Database | PostgreSQL + pgvector (semantic search) |
| Auth | Devise |
| Authorization | Pundit |
| Payments | Square |
| File uploads | Active Storage + Cloudinary |
| AI | RubyLLM (chat assistant + appointment embeddings) |
| Background jobs | Solid Queue |
| Real-time | Solid Cable (Action Cable over DB) |
| Frontend | Bootstrap 5.3, Importmap |
| Deployment | Heroku |

---

## Getting Started

### Prerequisites

- Ruby 3.3.5
- PostgreSQL (with pgvector extension)

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
| `SQUARE_ACCESS_TOKEN` | Square sandbox access token |
| `SQUARE_LOCATION_ID` | Square sandbox location |
| `SQUARE_WEBHOOK_SIGNATURE_KEY` | Webhook verification |
| `CLOUDINARY_CLOUD_NAME` | Image hosting |
| `CLOUDINARY_API_KEY` | Image hosting |
| `CLOUDINARY_API_SECRET` | Image hosting |
| `ANTHROPIC_API_KEY` | RubyLLM (AI chat + embeddings) |

---

## Seed Accounts

After `rails db:seed`, all accounts use password `password123`.

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

## Features

### Stylist
- Onboarding flow (about, services, location, Square connect)
- Service management with add-ons and duration
- Location management
- Availability block scheduling
- Appointment management (accept, complete, cancel)
- Booking page via unique slug (`/book/:slug`)
- Portfolio photo uploads
- Review responses
- Analytics dashboard (earnings, bookings, rating)

### Customer
- Stylist discovery (browse, search, filter by service)
- Appointment booking with add-on selection
- Square payment at booking
- In-app messaging with stylist (real-time via Action Cable)
- AI chat assistant (RubyLLM — helps find stylists, answers questions)
- Review and rating submission

### Payments (Square)
- Hosted checkout flow at booking
- Webhook handler for payment confirmation
- Sandbox test card: `4111 1111 1111 1111`, any CVV/expiry

---

## Project Structure

```
app/
├── controllers/
│   ├── stylist/          # Stylist-namespaced actions
│   ├── webhooks/         # Square webhook handler
│   └── ...               # Bookings, reviews, chat, messaging
├── models/               # User, Appointment, Service, AvailabilityBlock, Review, ...
├── jobs/                 # Solid Queue background jobs
└── views/

db/
├── schema.rb
└── seeds.rb
```

---

## Key Models

| Model | Notes |
|---|---|
| `User` | Roles: customer / stylist / admin. Stylists have `booking_slug`, onboarding state, Square credentials. |
| `Service` | Belongs to stylist. Stores `price_cents`. Supports add-ons (`is_add_on`). |
| `AvailabilityBlock` | Open time window for a stylist. Can restrict to specific services. |
| `Appointment` | Links customer + stylist + location + block. Statuses: pending → booked → completed / cancelled. |
| `AppointmentAddOn` | Add-on services attached to an appointment. |
| `Review` | One per completed appointment. Supports stylist response. |
| `Conversation` / `ConversationMessage` | Direct messaging per appointment. |
| `Chat` / `Message` | AI chat sessions (RubyLLM). |
