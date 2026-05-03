# ChairHop — Feature Reference

A complete breakdown of all features available to each user type on the ChairHop platform.

---

## Client Features

### 1. Account & Profile

- **Sign up** with email and password. All users must agree to the Terms of Service and Privacy Policy at signup. Email confirmation is required before the account is active.
- **Sign in / sign out / password reset** via standard Devise flows.
- **Edit profile**: update first name, last name, city, state, zip code, street address, and profile avatar.
- Profile is linked to appointment and review history.

---

### 2. Stylist Discovery

#### Browse Stylists
- View all stylists on the `/stylists` page.
- Filter by:
  - Stylist name (text search)
  - Service type
  - City / location
  - Available date
- Each stylist card shows: avatar, name, city, specialty tags, and average star rating.

#### Browse Available Time Slots
- View all open availability blocks across all stylists on the `/appointments` page.
- Blocks are grouped by date.
- Each card shows: stylist name, location, date/time window, available services, and a "Book" button.
- Filter by: stylist name, service type, date, location city.

#### Stylist Profile Page
- Full profile with: bio, avatar, portfolio photos (up to 12), services list, and availability calendar.
- Services displayed with name, description, price, and duration.
- Reviews section showing star ratings, written content, review photos, and any public stylist response.
- Integrated booking form (see Booking Flow below).
- Shareable link: `/book/:slug` redirects to the stylist's profile.

---

### 3. Booking Flow

The booking flow is embedded directly on the stylist's profile page.

**Step 1 — Select a date**
- A calendar (Flatpickr) shows only dates with available time slots.
- Selecting a date fetches available start times via AJAX.

**Step 2 — Select a time**
- Time slots are shown in 15-minute increments within the stylist's availability window.
- Slots are filtered to exclude times already booked by other clients.

**Step 3 — Select a service**
- Primary services are listed with name, photo, price, and duration.
- Only services available in the selected time block are shown.

**Step 4 — Add optional add-ons**
- Add-on services (e.g. deep condition, scalp treatment) can be toggled on/off.
- Each add-on shows its name and price.
- The booking summary updates dynamically as add-ons are toggled.

**Step 5 — Review and submit**
- Summary shows: stylist name, date, time, service, add-ons, total price, and **50% deposit due now**.
- Clicking "Review Details" navigates to a confirmation page.
- Client enters card details via the Square payment form (card is vaulted, not charged yet at this step).
- Submitting creates a `pending` appointment and notifies the stylist by email.
- Client receives an email confirming the request was sent.

---

### 4. Appointment Management

#### My Appointments (`/my_appointments`)
- Lists all appointments grouped by status: pending, upcoming (booked), completed, cancelled.
- Each card shows: stylist name, date, time, service, location, and current status.

#### Appointment Detail Page
- Shows full appointment details: stylist info, service, add-ons, date/time, location.
- Payment breakdown: service total, deposit paid, balance remaining.
- Status badge (pending, confirmed, completed, cancelled).
- Available actions depend on status:

| Status | Available Client Actions |
|---|---|
| Pending | Cancel (no deposit charged yet) |
| Booked | Cancel appointment, message stylist |
| Completed | Leave a review, view receipt, view invoice |
| Cancelled | View cancellation details |

#### Cancel an Appointment
- Client can cancel a pending or booked appointment.
- **24+ hours before appointment**: deposit is refunded automatically (Square refund processed within 5–10 business days). Refund confirmation email is sent.
- **Less than 24 hours before appointment**: deposit is not refunded (per platform policy).
- The opposing party (stylist) receives a cancellation notice by email.

#### Mark as Complete
- Client can mark an appointment as complete after the scheduled appointment time has passed.
- This triggers the balance payment flow.

#### Receipts
- **Confirmation page** after booking is accepted.
- **Balance receipt** after the balance payment is collected.
- **Full invoice** showing service, add-ons, deposit, and balance.

---

### 5. Payments

- **Deposit**: 50% of the total (service + add-ons) is charged when the stylist accepts the booking. The card is vaulted at time of request.
- **Balance**: The remaining 50% is charged at appointment completion. The stylist triggers this automatically (via card on file) or sends a Square checkout link.
- **Payment link**: Client receives an email with a Square-hosted checkout link to pay the balance if the stylist chooses that method.
- **Refunds**: Full deposit refund if cancelled 24+ hours before the appointment. No refund within 24 hours.
- Payments are processed via Square. Sandbox test card: `4111 1111 1111 1111`, any CVV/expiry.

---

### 6. Messaging & AI Chat

#### Direct Messaging with Stylist
- Each confirmed appointment has a dedicated conversation thread.
- Messages are delivered in real-time via Action Cable / Turbo Streams.
- Clients and stylists can attach photos to messages.
- Conversations are accessible from the appointment detail page.
- Keyboard shortcut: Cmd/Ctrl + Enter to send a message.

#### HOPPS AI Assistant
- Available from the navigation bar (chat icon).
- Start a new chat session, optionally linked to a specific appointment.
- Optionally set your city to get location-filtered stylist suggestions.
- HOPPS can:
  - Recommend local stylists with links to their booking pages
  - Show stylists 3 at a time (up to 6 inline per chat, then directs to the browse page)
  - Answer general hair and beauty questions
  - Help navigate the platform (booking, cancellation, rescheduling)
  - Provide appointment-specific guidance if the chat is linked to a booking
- HOPPS cannot book, cancel, or reschedule appointments on the client's behalf.
- Image uploads are supported (GPT-4o is used when an image is attached).
- Up to 15 messages per chat session.
- Previous chat sessions are saved and accessible from the chat index.

---

### 7. Reviews

- Reviews can be submitted after an appointment is marked complete.
- A review request email is sent automatically after completion.
- **Rating**: 1–5 stars (required).
- **Written content**: 10–500 characters (required).
- **Photos**: up to 2 photos (JPG only).
- One review per appointment.
- Reviews are editable for 3 days after submission.
- Submitted reviews appear publicly on the stylist's profile page.
- If the stylist responds, the client receives an email notification.

---

---

## Stylist Features

### 1. Account & Signup

- **Sign up** with email and password. Stylists must agree to the Terms of Service, Privacy Policy, **and Payment Terms** at signup. Email confirmation is required before the account is active.
- **Sign in / sign out / password reset** via standard Devise flows.

---

### 2. Onboarding (4-Step Flow)

New stylist accounts are guided through a 4-step onboarding before they can accept bookings.

**Step 1 — Profile**
- Upload a profile avatar.
- Write a bio (minimum 50 characters, maximum 500 characters).
- Character counter with real-time feedback.

**Step 2 — Services** *(optional — can skip)*
- Add the first primary service: name, description, price, duration.
- Can be set as an add-on service.
- Additional services can be added later from the services management page.

**Step 3 — Location**
- Add the first work location: name, street address, city, state, zip code.
- Additional locations can be added later.

**Step 4 — Connect Square** *(required to accept bookings)*
- Initiates Square OAuth flow.
- Stylist links their Square merchant account to accept payments.
- Until Square is connected, the dashboard shows a prominent warning and bookings cannot be accepted.

Onboarding progress is tracked and a completion banner is shown on the dashboard until all required steps are done.

---

### 3. Profile & Portfolio

- Edit profile: name, avatar, bio, city, state, address.
- Upload portfolio photos (up to 12 photos via multi-file upload).
- Delete individual portfolio photos.
- Portfolio photos appear in order on the public profile page.
- Unique shareable booking link generated from name: `/book/:slug` (e.g. `/book/maya-johnson`). A QR code can be generated from the dashboard.
- Clients can reach the profile directly via the booking link.

---

### 4. Service Management

- Create, edit, and deactivate services.
- Each service has: name, description, price (in dollars), duration (in minutes), optional photo, active/inactive flag, and an add-on flag.
- **Add-on services** appear as optional extras clients can attach to their main booking. They are not bookable as standalone services.
- Inactive services are hidden from client-facing booking forms but preserved in appointment history.
- Services are linked to availability blocks — a block can be set to offer all active services or a specific subset.

---

### 5. Location Management

- Add multiple work locations (e.g. home studio, salon booth, mobile).
- Each location has: name, street address, city, state, zip code.
- Locations are linked to availability blocks and appear on appointment details.
- Clients see the location when viewing their appointment.

---

### 6. Availability Scheduling

- Create availability blocks: a date/time window at a specific location during which clients can book.
- Each block specifies:
  - Start and end date/time
  - Location
  - Services available (all active services, or a specific subset)
- The booking form automatically computes 15-minute bookable slots within the block, excluding already-booked times.
- Blocks can be edited or deleted from the calendar view (`/stylist/calendar`).
- Calendar view shows upcoming blocks with edit and delete actions.

---

### 7. Appointment Management

#### Dashboard
- Summary cards: pending requests count, upcoming appointments count, total earnings.
- Quick links: add availability, manage availability, view appointments, manage services, manage locations, edit profile.
- Recent appointments table with date, client name, location, and status.
- Recent reviews carousel with rating, content preview, and inline response form.
- Booking link card with copy button and QR code generator.
- Alerts if onboarding is incomplete or Square is not connected.

#### Appointment Inbox (`/stylist/appointments`)
- Filter appointments by status: requests (pending), upcoming (booked), completed, cancelled.
- Each row shows: date, time, client name, service, location, and status.

#### Appointment Actions by Status

| Status | Stylist Actions |
|---|---|
| Pending | Accept (charges client deposit), Decline (no charge) |
| Booked | Message client, Cancel, Mark Complete |
| Completed | View details |
| Cancelled | View details |

**Accept**: Confirms the booking, charges the 50% deposit to the client's vaulted card, and sends a confirmation email to the client.

**Decline**: Cancels the request. No deposit is charged. Client is notified by email.

**Mark Complete**: Marks the appointment done. Triggers the balance payment:
- If the client has a card on file: balance is charged automatically.
- If no card on file: stylist sends a Square payment link via email.
- In-person collection can also be recorded manually.

**Cancel**: Cancels a booked appointment. If cancelled 24+ hours in advance, the deposit is refunded to the client. Both parties are notified by email.

---

### 8. Payments & Payouts

- Payments are processed directly through the stylist's connected Square account.
- **Deposit (50%)**: Collected when the stylist accepts the booking.
- **Balance (50%)**: Collected when the appointment is marked complete. Options:
  - Auto-charge the card on file.
  - Send a Square checkout link to the client via email.
  - Record as collected in person (manual).
- **Founding stylists**: 0% platform fee. All payments go directly to the stylist.
- **All other stylists**: A 4.5% platform fee is deducted via Square's `app_fee_money` on each payment (deposit and balance separately, totalling 4.5% of the full appointment value).
- Stylists manage payouts directly through their Square dashboard.

---

### 9. Reviews & Responses

- All reviews for the stylist are visible at `/stylist/reviews`.
- Filter reviews by star rating.
- Average rating summary shown at the top.
- Respond publicly to any review. Each review supports one stylist response.
- Responses can be written and edited inline from the dashboard or the reviews page.
- The client receives an email when the stylist responds.
- Review responses appear publicly on the stylist's profile below the original review.

---

### 10. Analytics

Located at `/stylist/analytics`.

- Total lifetime earnings
- Earnings for the current month
- Total number of completed bookings
- Average star rating
- Top services by revenue
- Booking trends over time

---

### 11. HOPPS AI Assistant (Stylist Mode)

- Available from the navigation bar.
- Provides platform-specific guidance:
  - How to set up a profile, services, locations, and availability
  - How to navigate and use platform features
  - Light client communication coaching (professional tone, handling questions)
- HOPPS cannot access or modify account data directly.
- Image uploads are supported.
- Up to 15 messages per chat session.
- Previous sessions saved and accessible from the chat index.

---

---

## Shared Platform Features

### Real-Time Messaging
- Direct messages between a client and stylist are tied to a specific appointment.
- Messages are delivered instantly via Action Cable and Turbo Streams — no page reload required.
- Photo attachments are supported.
- Read tracking is built in (messages record a `read_at` timestamp).

### Email Notifications
Both roles receive automated emails throughout the appointment lifecycle:

| Event | Recipient |
|---|---|
| New booking request received | Stylist |
| Booking request sent confirmation | Client |
| Booking accepted | Client |
| Booking declined | Client |
| Cancellation notice | Opposing party |
| Deposit refunded | Client |
| Appointment completed receipt | Client |
| Review request | Client |
| Stylist responded to review | Client |
| Balance payment link | Client |
| Balance payment received | Stylist |
| Balance receipt | Client |
| Balance payment failed | Client |
| Balance collected in person | Stylist |
| Account welcome | All new users |

### Account Management
- Email / password authentication via Devise.
- Email confirmation required on signup.
- Password reset via email.
- Secure session management.

### Legal & Policies

Three policy pages are publicly accessible (no login required) and linked in the site footer on every page:

| Page | URL | Applies to |
|---|---|---|
| Terms of Service | `/terms` | All users |
| Privacy Policy | `/privacy` | All users |
| Payment Terms | `/payment-terms` | Stylists |

- **At signup**, all users must check a box agreeing to the Terms of Service and Privacy Policy.
- **Stylist signup** additionally requires agreement to the Payment Terms. The Payment Terms checkbox appears only when the Stylist role is selected.
- Agreement timestamps (`tos_accepted_at`, `payment_terms_accepted_at`) are stored on the user record.
- The site footer (visible on all pages) links to all three documents.
