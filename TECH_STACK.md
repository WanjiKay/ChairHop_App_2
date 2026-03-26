# ChairHop Core Tech Stack

Mirror of the production app in [WanjiKay/ChairHop_App_2](https://github.com/WanjiKay/ChairHop_App_2). Versions referenced below come from the `Gemfile`/`Gemfile.lock` at commit time (March 2026).

---

## 1. Platform Overview

| Layer | Tooling | Why it exists |
| --- | --- | --- |
| Language & runtime | **Ruby 3.3.5**, **Rails 7.1.5.2** | Mature batteries-included MVC for both HTML + JSON generations. |
| Web server | **Puma ≥5** | Threaded server optimized for Rails, easy horizontal scaling. |
| Database | **PostgreSQL** + `pgvector` extension | ACID guarantees, `vector(1536)` for semantic search, built-in JSON, works with Solid Cable persistence. |
| Frontend | **Turbo Rails**, **Stimulus**, **Bootstrap 5.3**, **Simple Form** | Server-rendered UX, minimal JS bundle, rapid UI iteration. |
| API | REST `/api/v1/*`, **Rack-CORS**, **Devise-JWT**, **Kaminari** | Mobile clients interact over stateless JSON with pagination + role gating. |
| Real-time | **Solid Cable** (ActionCable drop-in) | Stores messages in Postgres, no Redis dependency. |
| AI | **ruby_llm ~> 1.6.4**, **neighbor** | Embeddings for appointments, conversational AI concierge, nearest-neighbor search. |
| Files | **Active Storage** + **Cloudinary** | Global CDN, automatic resizing, keeps the app stateless. |
| Payments & accounting | **square.rb**, **oauth2**, **httparty** | Square card charges/refunds; QuickBooks OAuth + REST for invoices/payments. |
| Push notifications | **exponent-server-sdk** | Expo push service for customer/stylist alerts. |
| Misc | **geocoder**, **image_processing**, **sassc-rails**, **font-awesome-sass** | Address helpers, attachment transforms, CSS tooling, icons. |

---

## 2. Backend Core

### Rails 7.1.5.2 (Ruby 3.3.5)
- Standard MVC stack with Hotwire baked in.
- `ActiveSupport::CurrentAttributes` supplies `current_user` over ActionCable/Solid Cable.
- Importmap drives JavaScript modules; there is no bundler like Webpack/Vite.

### Env bootstrap
- `dotenv-rails` loads `.env` for local dev; production secrets live in Rails credentials or platform-specific key stores.
- Default `bin/dev` (Foreman/Procfile) spins up Puma + JS bundlers + CSS watchers.

### Routing & namespaces
- Web: root `pages#home`, `appointments`, `conversations`, `chats`, `stylist/*`, `quickbooks/*`.
- API: `/api/v1` namespace plus nested `/api/v1/stylist` endpoints for pro tools.

---

## 3. Data & Persistence

### PostgreSQL + pgvector
- `vector` extension stores 1,536‑dimension embeddings on `appointments.embedding`.
- `neighbor` gem gives `Appointment.nearest_neighbors` for AI search.
- Standard indexes enforce referential integrity across services/appointments/locations/reviews.

### Active Storage + Cloudinary
- Gem: `cloudinary`; configuration ties Active Storage service to the Cloudinary bucket defined in env vars.
- Used for: user avatars, appointment photos, chat photos, conversation attachments.
- `image_processing` handles server-side transformations; validations enforce PNG/JPEG/WEBP + ≤5 MB per file.

### Solid Cable
- Gem: `solid_cable`; stores ActionCable messages in Postgres (`solid_cable_messages` table) for reliability.
- `ConversationChannel` uses `stream_for conversation`, so multiple web/mobile clients can subscribe simultaneously.

---

## 4. Authentication & Authorization

| Concern | Gem/Tool | Notes |
| --- | --- | --- |
| Web auth | `devise` | Email/password login, recovery, remember-me, etc. |
| API auth | `devise-jwt` | Adds JWT generation/verification plus denylist strategy (`JwtDenylist` model). |
| Authorization | `pundit` | Policies for appointments, services, stylist namespaces, QuickBooks endpoints. |
| Password storage | Devise defaults (bcrypt via ActiveModel). |

Session-based and token-based auth live side-by-side; cookies authenticate Turbo pages, JWTs secure `/api/v1/*` requests.

---

## 5. API & Mobile Tooling

- **Rack-CORS** exposes `/api/v1/*` to mobile/Expo origins (wide-open in dev, typically restricted in prod).
- **Kaminari** paginates list endpoints (appointments, stylist dashboards, etc.) with metadata blocks.
- **Uploads**: dedicated API controllers send photos through Active Storage, ensuring mobile apps don’t have to craft multipart logic themselves.
- **Push tokens**: `users.push_token` updated via `POST /api/v1/users/push_token`; the Expo SDK handles delivery.

---

## 6. Payments, Accounting & Notifications

### Square (`square.rb`)
- Configured in `config/initializers/square.rb` as a singleton `SQUARE_CLIENT` targeting sandbox or production based on `Rails.env`.
- `Api::V1::PaymentsController` handles charges (`payments.create`), refunds, and payment status queries. All dollar amounts are stored as cents or decimals on the appointment row to avoid rounding issues.

### QuickBooks Online (`oauth2`, `httparty`)
- OAuth dance triggered at `/quickbooks/connect`; manual sandbox entry at `/quickbooks/manual_setup` for testers.
- `QuickbooksService` encapsulates API calls (customer sync, invoices, payments) and token refresh logic.
- `QuickbooksJob` (ActiveJob) fires asynchronously when a stylist marks a paid appointment `completed`.

### Push Notifications (`exponent-server-sdk`)
- `PushNotificationService` wraps Expo send calls. Controllers feed it typed payloads (`booking_request`, `booking_accepted`, `review_request`, `new_message`, etc.).
- Tokens stored on the user row; failures log warnings but don’t block controller responses.

---

## 7. AI & Search

- **ruby_llm (~>1.6.4)** drives two flows:
  1. `Appointment#set_embedding` → semantic search for the mobile AI concierge.
  2. `ChatsController` → AI assistant (text and optional image support via GPT‑4o). Input/output token counts are stored per message for analytics.
- **neighbor** supplies the `has_neighbors` mixin; `Appointment.nearest_neighbors(:embedding, query_vector, distance: "euclidean")` is used to find relevant slots.

---

## 8. Frontend Stack

| Tool | Purpose |
| --- | --- |
| **Turbo Rails** | Navigations and form submissions become AJAX requests; Turbo Streams update conversation/message partials in real time. |
| **Stimulus** | Lightweight controllers for chat scrolling, form resets, file previews, etc. |
| **Bootstrap 5.3 + font-awesome-sass** | Layout + icons for dashboards, booking forms, QuickBooks pages. |
| **Simple Form (GitHub)** | Batteries-included form builder tuned for Bootstrap classes. |
| **Importmap-Rails** | Loads JS modules without bundling. |
| **sassc-rails / autoprefixer-rails** | Stylesheet compilation + vendor prefixing. |

---

## 9. Background & Jobs

- **ActiveJob** (inline/async adapter by default) handles `QuickbooksJob`. Switch to Sidekiq/GoodJob/etc. for production durability.
- Rails built-in mailers/jobs structure is present even if not heavily used yet.

---

## 10. Geo & Utilities

- **geocoder** is wired up in the `User` model (currently commented out pending SSL fixes). When re-enabled, it will geocode stylist addresses and persist lat/long.
- **tzinfo-data** ensures timezone support on Windows.
- **bootsnap** reduces boot times.
- **debug**, **capybara**, **selenium-webdriver** provide local debugging + system tests.

---

## 11. Testing & Tooling

- API smoke-test scripts (`test_api.sh`, `test_appointments_api.sh`, etc.) exercise curl-based flows.
- Rails test suite (MiniTest) is scaffolded with Capybara for end-to-end scenarios.
- `REFACTORING_NOTES.md` and other markdown docs in the repo capture manual QA steps; Markdown parsing uses `kramdown` + `rouge` + `kramdown-parser-gfm`.

---

## 12. Deployment Considerations

- **Dockerfile** builds from `ruby:3.3.5`, installs bundle, precompiles assets, and runs `rails server -b 0.0.0.0`.
- **Environment variables** needed at boot:
  - `SQUARE_SANDBOX_ACCESS_TOKEN` and `SQUARE_LOCATION_ID`
  - `SQUARE_ACCESS_TOKEN` (prod)
  - `QUICKBOOKS_CLIENT_ID/SECRET/REDIRECT_URI/ENVIRONMENT`
  - `CLOUDINARY_URL`
  - `DEVISE_JWT_SECRET_KEY`
  - API keys for RubyLLM/OpenAI provider
- **Scaling**: increase Puma workers & threads, or deploy multiple app servers behind a load balancer. Solid Cable lets you keep ActionCable traffic on the same dynos without Redis.
- **Monitoring**: integrate Sentry/Rollbar/NewRelic/etc. to watch payment/accounting failures and LLM token usage.

---

Keep this document next to `ARCHITECTURE.md` and `DATABASE_DESIGN.md`. Together they describe **what** the platform does, **how** traffic flows, and **which** dependencies must be configured to reproduce production behavior.
