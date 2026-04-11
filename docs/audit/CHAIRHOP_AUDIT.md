# ChairHop Codebase Audit
**Date:** 2026-03-31
**Auditor:** Claude Code
**Rails version:** 7.1.5 · **Ruby:** 3.3.5 · **Database:** PostgreSQL + pgvector

---

## Executive Summary

- **Pundit authorization is almost entirely unenforced.** Only `AppointmentsController` uses `authorize`. Every other controller — chats, messages, conversations, profiles, reviews, stylists, all stylist-namespace controllers — relies on ad-hoc custom guards or nothing at all. Any authenticated user can read any other user's chat history.
- **Three confirmed QuickBooks bugs mean the integration has never worked.** `QuickbooksJob` references a column (`payment_intent_id`) that doesn't exist, and `QuickbooksService` performs double-division on dollar amounts (dividing by 100 a second time), sending values 100× too small to QuickBooks.
- **Users can self-assign the `stylist` or `admin` role on sign-up.** The Devise permitted parameters whitelist includes `role`, with no restriction. This is a critical privilege escalation hole.
- **The documented mobile API (React Native, `/api/v1/*`, push notifications) does not exist in this codebase.** `ARCHITECTURE.md` describes a fully-designed mobile layer that was never built or has been stripped out. Vestigial config (Expo Action Cable origins, Devise-JWT endpoints) remains throughout.
- **The app is broadly functional for its core booking flow**, but several subsystems (QuickBooks, Availability Block editing, AI chat authorization, the `search_results` page) are broken or dead.

---

## Architecture Overview

### Stack
| Layer | Technology |
|-------|-----------|
| Framework | Rails 7.1.5 (full-stack, not API-only) |
| Database | PostgreSQL with `pgvector` extension |
| Auth | Devise + Devise-JWT (JWT vestigial; web uses sessions) |
| Authorization | Pundit (partially applied) |
| Frontend | Turbo + Stimulus + Bootstrap 5.3 via importmap |
| Real-time | Solid Cable (DB-backed ActionCable, replaces Redis) |
| Media | Cloudinary via Active Storage |
| Payments | Square Web Payments SDK + per-stylist OAuth |
| AI | RubyLLM (OpenAI GPT-4o backend) |
| Accounting | QuickBooks OAuth2 (broken — see bugs) |
| Jobs | ActiveJob (`:inline` in dev, `:async` in production — no persistent queue) |
| Email | ActionMailer + letter_opener (dev) + Postmark SMTP (production) |
| Deployment | Heroku |

### App Structure
```
app/
├── channels/       ActionCable (ConversationChannel — JWT-gated, browser-unreachable)
├── controllers/    18 controllers across root + stylist/ + users/ + quickbooks/ namespaces
├── helpers/        Standard Rails helpers (thin)
├── javascript/     Stimulus controllers + application.js
├── jobs/           ApplicationJob, QuickbooksJob
├── mailers/        ApplicationMailer, AppointmentMailer (7 methods)
├── models/         12 models
├── policies/       ApplicationPolicy, AppointmentPolicy (only 2 policies)
├── services/       PaymentService, QuickbooksService
└── views/          Full ERB view layer
```

### Non-Standard Patterns
- **Two overlapping messaging systems**: `Chat` (AI assistant) and `Conversation` (stylist↔customer) exist in parallel with separate models, controllers, and routes, and both have nested routes under appointments AND standalone routes.
- **Dual location storage**: `appointments.location` (legacy text column) AND `appointments.location_id` (FK to `locations` table) coexist. Old appointments use the string; new ones use the FK.
- **Business data in model code**: `SALON_ADD_ONS` constant in `Appointment` hardcodes four specific salon names with their add-on menus and prices. This is seed data that belongs in the database.
- **Cloudinary in development**: `config.active_storage.service = :cloudinary` in `development.rb` means dev file uploads go to the same Cloudinary bucket as production unless a separate dev preset is configured.

### Frontend
- Turbo Drive handles navigation (no full page reloads). Stimulus controllers for chat, search toggle, image upload, form reset.
- Bootstrap 5.3 and Flatpickr loaded via importmap (jspm.io CDN).
- **FullCalendar loaded globally on every page** via a `<script>` tag in the layout (~500KB), even on pages that don't use it.
- `window.bootstrap = bootstrap` — Bootstrap exposed as a global so inline `<script>` blocks in views can call `new bootstrap.Modal(...)` directly. This pattern makes testing and refactoring harder.
- Large inline `<script>` blocks in: `check_in.html.erb` (Square SDK init, ~80 lines), `availability_blocks/index.html.erb` (FullCalendar init, ~100 lines), `appointments/show.html.erb`, `conversations/show.html.erb`.

### Mobile / React Native
No React Native code exists in this repository. No `.tsx`, `.jsx`, `package.json`, `metro.config.js`, or Expo files found. However:
- `ARCHITECTURE.md` documents a complete React Native app with `/api/v1/*` controllers, `PushNotificationService`, and `exponent-server-sdk`.
- `push_token` column was added (migration `20260205`) then removed (migration `20260329`).
- `config/environments/development.rb` still allows Action Cable origins for `localhost:8081`, `8082`, `19006` (Expo ports).
- `config/initializers/devise.rb` configures JWT for `/api/v1/login`, `/api/v1/signup`, `/api/v1/logout` — routes that don't exist.

---

## Features Inventory

| Feature | Role | Status | Notes |
|---------|------|--------|-------|
| Browse available stylists | Guest/Customer | ✅ Implemented | Public `/stylists` index |
| View stylist profile | Guest/Customer | ✅ Implemented | No role check — any user ID works |
| Browse open appointment slots | Guest/Customer | ✅ Implemented | Public `/appointments` index with search/filters |
| Book an appointment (multi-step) | Customer | ✅ Implemented | Service selection → time slot → payment → booking |
| 50% deposit via Square | Customer | ✅ Implemented | Bypass mode for dev |
| My Appointments (tabbed dashboard) | Customer | ✅ Implemented | Pending/Upcoming/Completed/Cancelled tabs |
| Cancel appointment + refund | Customer | ✅ Implemented | 24-hour policy enforced |
| Printable receipt | Customer | ✅ Implemented | `/appointments/:id/confirmation` |
| Leave a review | Customer | ✅ Implemented | After completion only, validated |
| AI chat assistant (HOPPS) | Customer | ⚠️ Partial | Chat works; `book_appointment` method broken; no authorization on chat reads |
| Customer↔Stylist messaging | Customer/Stylist | ⚠️ Partial | Conversation model + views exist; double-render risk; no unique index |
| Stylist onboarding (4-step) | Stylist | ✅ Implemented | Step 1 skips avatar upload (Cloudinary issue) |
| Stylist dashboard | Stylist | ⚠️ Partial | N+1 earnings query; shows metrics but earnings calc is O(n) |
| Manage services | Stylist | ✅ Implemented | CRUD; add-on flag; price in cents |
| Manage availability blocks | Stylist | ⚠️ Partial | Create/delete works; **edit/update routes broken** (no controller actions) |
| Availability calendar (FullCalendar) | Stylist | ✅ Implemented | Large inline script; hardcoded path strings |
| Accept/decline booking requests | Stylist | ✅ Implemented | Decline correctly captures customer before clearing |
| Complete appointment + collect balance | Stylist | ✅ Implemented | Square balance charge; fallback for no nonce |
| Cancel booking + refund customer | Stylist | ✅ Implemented | Always refunds when stylist cancels |
| Manage locations | Stylist | ✅ Implemented | Full CRUD |
| Square OAuth connect/disconnect | Stylist | ✅ Implemented | Per-stylist OAuth; tokens in plain text |
| Profile management | Customer/Stylist | ✅ Implemented | Avatar upload; address fields; legacy string location still permitted |
| Email notifications (7 types) | All | ✅ Implemented | letter_opener in dev; Postmark in prod (ENV vars required) |
| QuickBooks invoice sync | Stylist | ❌ Broken | Job references non-existent column; double-division bugs in service |
| QuickBooks OAuth connect | Stylist | ⚠️ Partial | OAuth flow works; manual setup accepts raw tokens |
| Search appointments (full-text) | Guest/Customer | ⚠️ Partial | Works but synonym map is business logic in controller |
| Search results page | Guest/Customer | ❌ Dead | View exists (`search_results.html.erb`); no route, no controller action, contains hardcoded mockup data |
| Admin panel | Admin | ❌ Not built | `admin` enum value exists on User; no admin controllers or views |
| Push notifications | Mobile | ❌ Removed | `push_token` column removed; `PushNotificationService` never existed |
| Mobile API (`/api/v1/*`) | Mobile | ❌ Never built | Documented in ARCHITECTURE.md but no code exists |

---

## Database Review

### Per-Model Breakdown

| Model | Purpose | Concerns |
|-------|---------|----------|
| `User` | Customer + Stylist in one model | Duplicate `appointments` / `appointments_as_customer` associations (same FK). `latitude`/`longitude` columns present, unused, no geocoding gem. OAuth tokens in plain text. |
| `Appointment` | Core booking record | `validates :location, presence: true` contradicts `belongs_to :location, optional: true`. Legacy `location` text column coexists with `location_id` FK. `cancel!` nullifies `customer_id`, losing audit trail. `SALON_ADD_ONS` hardcoded in model. `services` text column (legacy) alongside `selected_service` string. |
| `AppointmentAddOn` | Add-on services on a booking | Dual storage: service_id FK or legacy name+price string. `final_price` returns dollars; `QuickbooksService` divides by 100 again (bug). |
| `AvailabilityBlock` | Stylist time windows | `service_ids text[]` (PostgreSQL array). `slot_available?` uses raw SQL with PostgreSQL-specific `INTERVAL` syntax. No DB constraint preventing overlapping blocks. |
| `Chat` | AI chat session | `attr_accessor :content` (virtual). No model-level authorization. |
| `Conversation` | Stylist↔Customer thread | No uniqueness index on `appointment_id` — race condition for duplicates. No validations. |
| `ConversationMessage` | Message in a conversation | Turbo Stream + ActionCable broadcast on create. `read_at` for read receipts. Well-validated. |
| `JwtDenylist` | Revoked JWT tokens | Standard. Indexed on `jti`. |
| `Location` | Physical appointment location | Missing `has_many :availability_blocks` even though FK exists. |
| `Message` | AI chat message | `MAX_USER_MESSAGES = 15` limit (race condition: two simultaneous requests can both pass). Token tracking (`input_tokens`, `output_tokens`). |
| `QuickBooksToken` | QB OAuth tokens per user | Plain text storage. `expired?` uses 10-min buffer. |
| `Review` | Customer review of a booking | DB-level uniqueness on `appointment_id`. Well-validated. |
| `Service` | Stylist's offered services | `price_cents` (integer). Composite index on `(stylist_id, name)` exists but not `unique: true` — no uniqueness enforcement. |

### Overall Schema Assessment

**Strengths:**
- Foreign keys are consistently declared.
- `pgvector` integration for AI embeddings is clean.
- Migrations are incremental and well-named.
- `reviews` has a DB-level uniqueness constraint (correct).

**Weaknesses:**

| Issue | Tables Affected |
|-------|----------------|
| Legacy columns not removed after migration | `appointments.location` (text), `appointments.services` (text), `appointments.booked` (boolean), `users.location` (string) |
| Missing unique index | `conversations.appointment_id` |
| Non-unique composite index | `services(stylist_id, name)` |
| Plain-text secret storage | `users.square_access_token`, `users.square_refresh_token`, `quick_books_tokens.access_token`, `quick_books_tokens.refresh_token` |
| Unused columns | `users.latitude`, `users.longitude` (no geocoder gem) |
| No DB constraint on availability block overlaps | `availability_blocks` |

### Missing Indexes (by query pattern)
- `conversations.appointment_id` — unique index missing (query + race condition)
- `appointments.stylist_id` — FK index exists; verify query plans for stylist dashboard
- `messages.chat_id` — FK present; check for pagination queries

---

## Dead Code Log

| Type | Name | File | Recommendation |
|------|------|------|---------------|
| View | `search_results.html.erb` | `app/views/pages/search_results.html.erb` | Delete or implement the route + action |
| JS Controller | `hello_controller.js` | `app/javascript/controllers/hello_controller.js` | Delete |
| Controller Method | `calculate_add_ons_total` | `app/controllers/appointments_controller.rb:418` | Delete (never called) |
| Controller Method | `book_appointment` | `app/controllers/messages_controller.rb:443` | Delete (references non-existent attributes) |
| Commented code | Old `check_in` action | `app/controllers/appointments_controller.rb:129–137` | Delete |
| Commented code | Old `home` action | `app/controllers/pages_controller.rb:527–531` | Delete |
| Commented code | `user_cannot_book_multiple` validation | `app/models/appointment.rb:14,197–202` | Delete or implement properly |
| Config | Expo Action Cable origins | `config/environments/development.rb:63–70` | Delete |
| Config | Devise JWT endpoints (`/api/v1/*`) | `config/initializers/devise.rb:371–381` | Delete |
| Schema column | `users.latitude`, `users.longitude` | `db/schema.rb` | Add geocoder gem or remove columns |
| Schema column | `appointments.booked` boolean | `db/schema.rb` | Remove; superseded by `status` enum |
| Schema column | `appointments.services` text | `db/schema.rb` | Remove; superseded by `selected_service` + `services` join |
| Schema column | `appointments.location` text | `db/schema.rb` | Remove; superseded by `location_id` FK |
| Schema column | `users.location` string | `db/schema.rb` | Remove; superseded by structured address columns |
| Documentation | `ARCHITECTURE.md` | `docs/ARCHITECTURE.md` | Rewrite; describes a mobile API that does not exist |
| Initializer entry | `assets.rb` bootstrap/popper precompile | `config/initializers/assets.rb` | Verify; Bootstrap is loaded via importmap, not Sprockets |

---

## Dev / Sandbox vs Production Findings

| Finding | Environment | Risk |
|---------|-------------|------|
| `BYPASS_SQUARE_PAYMENTS=true` skips all payment processing | Development only | Low — guarded by `Rails.env.development?` check in `PaymentService` |
| `Net::HTTP` SSL `VERIFY_NONE` patch | Development only | Low — correctly scoped to dev in `square.rb` initializer |
| Active Storage uploads to Cloudinary (not local disk) | Development | Medium — dev uploads go to the same Cloudinary bucket unless separate preset is configured |
| `letter_opener` email delivery | Development only | Low — correctly in `:development` Gemfile group |
| `active_job.queue_adapter = :inline` | Development only | Low — synchronous in dev, `:async` in production |
| **No persistent job queue in production** | Production | High — ActiveJob uses `:async` (in-process), so QuickBooks sync jobs are lost on Heroku dyno restart |
| `simple_form` loaded from GitHub HEAD | All | Medium — unpinned pre-release gem can break between deployments |
| `config.require_master_key` commented out | Production | Medium — app can boot without a master key; encrypted credentials become inaccessible silently |
| `config.hosts` commented out | Production | Low — no host allowlist; all `Host` headers accepted |
| **Devise mailer sender is a placeholder** | All | High — password reset emails ship from `please-change-me@example.com` in production |
| `SMTP_ADDRESS` / `SMTP_USERNAME` / `SMTP_PASSWORD` ENV vars required but not documented | Production | High — if not set, production emails fail silently (raise_delivery_errors is true) |
| Square OAuth tokens stored as plain text in DB | All | High — a DB read gives you access tokens without any decryption |
| `Rails.logger.debug` calls in `check_in` action | All | Low — debug noise in production logs; not a data risk |
| FullCalendar loaded on every page from CDN | All | Performance — ~500KB JS loaded even on pages that don't use calendar |

---

## Rails Compliance Issues

| Severity | File | Issue | Recommendation |
|----------|------|-------|---------------|
| 🔴 Critical | `app/controllers/application_controller.rb:30` | `role` permitted for `:account_update` — users can escalate their own role | Remove `:role` from account_update permitted params; handle role in admin context only |
| 🔴 Critical | `app/controllers/users/registrations_controller.rb:20` | `role` permitted on sign-up | Remove `:role` from sign-up params; assign default role in User model or after_create callback |
| 🔴 Critical | `app/controllers/chats_controller.rb:13` | `Chat.find` without current_user scope | Scope to `current_user.chats.find(...)` |
| 🔴 Critical | `app/controllers/messages_controller.rb:466` | `Chat.find` without current_user scope | Same fix as above |
| 🔴 Critical | `app/jobs/quickbooks_job.rb:14` | `appointment.payment_intent_id` — column does not exist | Replace with `appointment.payment_id` |
| 🔴 Critical | `app/services/quickbooks_service.rb:132,136` | `final_price / 100.0` — double-division, values 100× too small | Remove the `/ 100.0` — `final_price` already returns dollars |
| 🔴 Critical | `app/services/quickbooks_service.rb:53,56` | `payment_amount / 100.0` where amount is already dollars | Remove the `/ 100.0` |
| 🟠 High | `app/controllers/stylist/availability_blocks_controller.rb` | `edit` and `update` routed but not implemented | Implement actions or remove routes |
| 🟠 High | `app/controllers/conversations_controller.rb:show` | `authorize_conversation_access!` calls redirect without halting — potential double render | Add `and return` after each redirect call in the guard method |
| 🟠 High | `app/controllers/stylist/dashboard_controller.rb:9–11` | N+1: loads all completed appointments, calls `total_price` on each (another DB query per appointment) | Use SQL `SUM` with a `joins` query instead |
| 🟠 High | All non-appointment controllers | Pundit `authorize` never called | Add Pundit policies or explicit `skip_authorization` to every action |
| 🟠 High | `app/models/appointment.rb:4,17` | `belongs_to :location, optional: true` + `validates :location, presence: true` contradict | Choose one: make the belongs_to non-optional OR remove the presence validation |
| 🟠 High | `config/initializers/devise.rb:83` | Devise mailer sender is placeholder `please-change-me@example.com` | Set to `noreply@chairhop.com` |
| 🟡 Medium | `app/controllers/appointments_controller.rb:391–395` | Customer `complete` bypasses payment — no balance collection | Either remove customer-triggered complete or call `PaymentService#charge_balance` |
| 🟡 Medium | `app/models/appointment.rb:139–144` | `cancel!` sets `customer = nil` — destroys audit trail | Use `cancelled_by`/`cancelled_at` fields instead; preserve the customer FK |
| 🟡 Medium | `app/controllers/pages_controller.rb:535` | `Appointment.where(booked: false)` — uses legacy boolean, not status enum | Replace with `Appointment.pending` scope |
| 🟡 Medium | `app/models/appointment.rb:27–76` | `SALON_ADD_ONS` hardcoded hash of four salon names and prices | Move to database or a seeded configuration table |
| 🟡 Medium | `app/controllers/appointments_controller.rb:405–456` | Synonym expansion for search is business logic in a controller | Extract to a `SearchService` or model scope |
| 🟡 Medium | `app/channels/application_cable/connection.rb` | JWT-based connection auth — browser sessions rejected | Either implement token injection for browser clients or use session-based cable auth for web |
| 🟡 Medium | `app/controllers/stylist/appointments_controller.rb:124–172` | 50-line Square balance charge logic in controller | Extract to `PaymentService#complete_appointment` |
| 🟡 Medium | Multiple controllers | No `rescue_from` for `ActiveRecord::RecordNotFound` | Add `rescue_from ActiveRecord::RecordNotFound` in ApplicationController |
| 🟢 Low | `app/models/message.rb` | `user_message_limit` validation has race condition — two simultaneous requests both pass at 14 | Add DB-level counter cache or use `with_lock` |
| 🟢 Low | `app/models/conversation.rb` | No uniqueness constraint on `appointment_id` | Add `add_index :conversations, :appointment_id, unique: true` migration |
| 🟢 Low | `app/javascript/controllers/chat_message_controller.js:45` | `this.messagesTarget` — target named `messagesContainer`, accessed as `messages` | Fix target reference to `messagesContainerTarget` |
| 🟢 Low | `config/initializers/filter_parameter_logging.rb` | Does not filter `:access_token` or `:refresh_token` | Add these to the filtered params list |

---

## Security Findings

| Severity | Finding | File | Fix |
|----------|---------|------|-----|
| 🔴 Critical | Users can self-assign any role (including `admin`) at sign-up and account update | `application_controller.rb:30`, `registrations_controller.rb:20` | Remove `:role` from permitted params entirely |
| 🔴 Critical | Any authenticated user can read any other user's AI chat history | `chats_controller.rb:13`, `messages_controller.rb:466` | Scope finds to `current_user` |
| 🟠 High | Square and QuickBooks OAuth tokens stored as plain text in database | `users` and `quick_books_tokens` tables | Use `attr_encrypted` or Rails encrypted attributes |
| 🟠 High | `StylistsController#show` accepts any user ID, not just stylists | `stylists_controller.rb:19` | Add `.where(role: :stylist)` to the find |
| 🟠 High | QuickBooks manual setup accepts raw tokens from form params | `quickbooks/manual_setup_controller.rb:10–13` | Add format validation; restrict to expected token format |
| 🟡 Medium | No Content Security Policy configured | `config/initializers/content_security_policy.rb` | Implement CSP allowing Square, jspm.io, FullCalendar CDN sources |
| 🟡 Medium | `filter_parameter_logging` does not filter OAuth tokens | `config/initializers/filter_parameter_logging.rb` | Add `:access_token`, `:refresh_token`, `:square_access_token` |
| 🟡 Medium | Square Application ID embedded in ERB and rendered to page HTML | `check_in.html.erb` | This is a public key (Square Web SDK requires it client-side) — but ensure it's not the secret key |
| 🟢 Low | No rate limiting on booking or payment endpoints | `appointments_controller.rb` | Add Rack::Attack or similar throttle on `book` action |
| 🟢 Low | Conversation race condition: two simultaneous creates produce duplicate threads | `conversations_controller.rb:create` | Add `find_or_create_by` with `with_lock` or DB unique index |

---

## Top 10 Recommendations

### 1. 🔴 Remove `role` from Devise permitted parameters immediately
**Files:** `app/controllers/application_controller.rb:30`, `app/controllers/users/registrations_controller.rb:20`
Any visitor can register as a stylist or admin, or upgrade their own account. Remove `:role` from both `:sign_up` and `:account_update` permitted params. Set the default role via a `before_create` callback in the User model instead.

### 2. 🔴 Scope `Chat.find` and `Message` lookups to `current_user`
**Files:** `app/controllers/chats_controller.rb:13`, `app/controllers/messages_controller.rb:466`
Change `Chat.find(params[:id])` to `current_user.chats.find(params[:id])` in both places. Any authenticated user can currently read another user's complete AI conversation history.

### 3. 🔴 Fix the QuickBooks integration (3 bugs, none of which have ever worked)
**Files:** `app/jobs/quickbooks_job.rb:14`, `app/services/quickbooks_service.rb:132,136,53,56`
- Replace `appointment.payment_intent_id` with `appointment.payment_id`.
- Remove `/ 100.0` from `build_invoice_data` (line items are already in dollars).
- Remove `/ 100.0` from `record_payment` (total_price is already in dollars).
These three changes together will make QuickBooks sync functional for the first time.

### 4. 🟠 Apply Pundit consistently or document intentional gaps
**Files:** All controllers except `AppointmentsController`
Either add `AppointmentPolicy` methods for the missing actions and create policies for `Chat`, `Conversation`, `Review`, `Service`, `Location`, or call `skip_authorization` explicitly in each controller action that intentionally bypasses Pundit. Right now, Pundit's `after_action :verify_authorized` is not enabled, so no action fails for missing authorization — it just silently skips the check.

### 5. 🟠 Implement `edit`/`update` for `AvailabilityBlock` or remove the routes
**Files:** `config/routes.rb:22`, `app/controllers/stylist/availability_blocks_controller.rb`
Routes for `edit_stylist_availability_block` and `update_stylist_availability_block` exist but the controller has no corresponding actions. Any request to these routes raises `AbstractController::ActionNotFound`. Either build the actions (stylists can't edit their own time blocks) or remove those routes.

### 6. 🟠 Fix the Stylist Dashboard N+1 earnings query
**File:** `app/controllers/stylist/dashboard_controller.rb:9–11`
```ruby
# Current (broken): loads every completed appointment + N more queries
@total_earnings = current_user.appointments_as_stylist.completed.sum { |a| a.total_price }

# Fix: single SQL query
@total_earnings = current_user.appointments_as_stylist
  .completed
  .joins(:appointment_add_ons)
  .sum("appointments.payment_amount")
```

### 7. 🟠 Set up a persistent job queue for production
**File:** `config/environments/production.rb`
`ActiveJob` defaults to `:async` in production, meaning `QuickbooksJob` and all `deliver_later` emails are lost on Heroku dyno restart. Add `gem "solid_queue"` (already have Solid Cable, same pattern) or configure `gem "good_job"` with a Heroku Postgres connection. This is a data-loss risk for QuickBooks syncs.

### 8. 🟡 Encrypt OAuth tokens at rest
**Tables:** `users.square_access_token`, `users.square_refresh_token`, `quick_books_tokens.access_token`, `quick_books_tokens.refresh_token`
A database dump or a single SQL injection gives an attacker live Square and QuickBooks access tokens for every stylist. Use Rails' built-in `encrypts` (Rails 7 Active Record Encryption) on these columns:
```ruby
encrypts :square_access_token, :square_refresh_token
```

### 9. 🟡 Resolve the location field ambiguity and remove legacy columns
**Tables:** `appointments` (`location` text, `booked` boolean, `services` text), `users` (`location` string)
Write migrations to:
1. Backfill any remaining `location`-only appointments to create `Location` records.
2. Remove `appointments.location`, `appointments.booked`, `appointments.services`.
3. Remove `users.location`.
Also fix `Appointment` model: pick either `belongs_to :location, optional: true` OR `validates :location, presence: true` — not both.

### 10. 🟡 Set the Devise mailer sender and document required ENV vars
**Files:** `config/initializers/devise.rb:83`, deployment docs
Change `config.mailer_sender` from the placeholder to `'ChairHop <noreply@chairhop.com>'`. Also create a `.env.example` documenting every required production ENV var: `APP_HOST`, `SMTP_ADDRESS`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `OPENAI_API_KEY`, `SQUARE_APPLICATION_ID`, `SQUARE_ACCESS_TOKEN`, `SQUARE_OAUTH_CLIENT_ID`, `CLOUDINARY_URL`, `QUICKBOOKS_CLIENT_ID`, `QUICKBOOKS_CLIENT_SECRET`.

---

## Appendix: Confirmed Bugs (not just compliance issues)

| # | Bug | File:Line | Symptom |
|---|-----|-----------|---------|
| 1 | `appointment.payment_intent_id` — column doesn't exist | `quickbooks_job.rb:14` | Payment recording in QB never runs |
| 2 | `final_price / 100.0` double-division | `quickbooks_service.rb:132,136` | QB line items 100× too small |
| 3 | `payment_amount / 100.0` double-division | `quickbooks_service.rb:53,56` | QB invoice totals 100× too small |
| 4 | `this.messagesTarget` — target named `messagesContainer` | `chat_message_controller.js:45` | Stimulus console error on chat pages |
| 5 | `edit`/`update` routes with no controller actions | `availability_blocks_controller.rb` | `AbstractController::ActionNotFound` at runtime |
| 6 | `appointment.update(user: ...)` — attribute doesn't exist | `messages_controller.rb:453` | `book_appointment` always fails silently |
| 7 | `Appointment.where(booked: false)` — uses legacy boolean | `pages_controller.rb:535` | Home page may show incorrect available slots |
| 8 | `validates :location, presence: true` + `optional: true` | `appointment.rb:4,17` | Appointments without `location_id` fail validation |
