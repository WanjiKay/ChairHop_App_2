# ChairHop Architecture — How Everything Connects

## 1. High-Level Topology

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 Clients                                     │
│ ┌──────────────┐ ┌──────────────┐ ┌───────────────────────────────────────┐ │
│ │ Web browser  │ │ Stylist hub  │ │ Mobile app (React Native / Expo push)│ │
│ │ (Turbo+HTML) │ │ (Turbo views)│ │ → /api/v1/* (JWT)                    │ │
│ └──────┬───────┘ └──────┬───────┘ └───────────────────────────────────────┘ │
└────────┼───────────────────────┴───────────────────────────────────────────┘
         │ HTTP(S)
         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Rails 7.1 Application Server                         │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ Entry points                                                             │ │
│ │  - Turbo controllers (appointments, chats, conversations, stylist UI)    │ │
│ │  - /api/v1/**/* (customers + stylists w/ JWT)                            │ │
│ │  - WebSockets via Solid Cable (ActionCable replacement)                  │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                               │                   │
│                               │ ActiveJob         │ ActionCable/Solid Cable
│                               ▼                   ▼
│ ┌───────────────────────┐ ┌──────────────┐ ┌───────────────────────────────┐ │
│ │ QuickbooksJob        │ │ PushNotificationService                          │ │
│ │  (Invoices+Payments) │ │  (Expo push)  │ │ Turbo Streams + ConversationChannel │ │
│ └───────────────────────┘ └──────────────┘ └───────────────────────────────┘ │
│                               │                   │
└───────────────────────────────┼───────────────────┼───────────────────────────┘
                                │                   │
                                ▼                   ▼
                       PostgreSQL + pgvector   Cloudinary (Active Storage)
                       (core data + Solid      (avatars, appointment images,
                        Cable message log)      chat/conversation photos)

External APIs:
- Square sandbox/production for payments & refunds
- QuickBooks Online (OAuth2) for invoices and payment recording
- RubyLLM for text+vision chat + appointment embeddings
- Expo Push service (exponent-server-sdk)
```

## 2. Application Layers

| Layer | Responsibilities | Key Components |
| --- | --- | --- |
| Presentation (Web) | Turbo Rails views for appointments, stylist dashboards, manual QuickBooks connect/disconnect, AI chat UI. | `appointments_controller.rb`, `stylist/*`, `chats_controller.rb`, Turbo Streams partials. |
| Presentation (Mobile/API) | Stateless REST endpoints under `/api/v1/` for login/signup, profiles, appointments, services, conversations, payments, uploads, stylist tools. | `Api::V1::*` controllers, Devise-JWT, Rack-CORS. |
| Real-time | Two-person conversations with attachments; ActionCable replaced by Solid Cable for persistence + horizontal scaling. | `ConversationChannel`, `ConversationMessage` callbacks, Turbo broadcasts. |
| Background jobs | QuickBooks invoice/payment sync queued when a paid appointment is completed. | `QuickbooksJob` + `QuickbooksService`. |
| Integrations | Square payments/refunds, QuickBooks OAuth, RubyLLM embeddings + chat, Expo push notifications. | `SQUARE_CLIENT` initializer, `QuickbooksController`, `RubyLLM` usage in `Appointment` + `ChatsController`, `PushNotificationService`. |

## 3. Core Flows

### 3.1 Booking + Payment (Web or Mobile)

1. **Discovery**: customers browse stylists from Turbo pages or call `GET /api/v1/appointments` (filters for location/date/service). Data pulled with eager-loaded stylist + add-on info.
2. **Booking request**: `POST /api/v1/appointments/:id/book` (customers only) or Turbo `AppointmentsController#book` sets `customer_id`, selected service, and optional add-ons.
3. **Payment** (API-first): `POST /api/v1/appointments/:appointment_id/payment` hits Square via `SQUARE_CLIENT`. Successful charges set `payment_status=paid`, store Square payment ID + card last4, and move the appointment to `booked`.
4. **Notifications**: `PushNotificationService` (Expo) alerts the stylist about the booking. Turbo pages refresh via Stimulus/Turbo Stream partials; ActionCable can also broadcast updates.
5. **Stylist action**: from `/api/v1/stylist/appointments` or the Turbo dashboard, stylists accept/decline (`Appointment#accept!`) and later `complete` once the timeslot has passed.

### 3.2 QuickBooks Sync

```
Stylist completes appointment (booked + paid)
    ↓
Appointment callback (after_update) enqueues QuickbooksJob
    ↓
QuickbooksJob loads stylist token → refreshes if expiring
    ↓
QuickbooksService.sync_customer (create/update)
    ↓
QuickbooksService.create_invoice (service + add-ons, GST/HST code)
    ↓
Optional record_payment if Square payment exists
    ↓
Appointment stores QuickBooks invoice/payment IDs for auditing
```

Manual flows: `/quickbooks/connect` drives OAuth, `/quickbooks/manual_setup` lets stylists paste sandbox tokens, and `/quickbooks/disconnect` removes credentials.

### 3.3 Messaging

- **Conversations**: one per appointment. Creation ensures the current customer and stylist share a record. Messages support text + multiple photos, persist read receipts (`read_at`), broadcast via Turbo Streams, and stream through `ConversationChannel`. Unauthorized users are rejected server-side.
- **Push notifications**: After each message, the backend identifies the other participant and sends an Expo push payload containing conversation metadata.
- **AI Chats**: `Chat` + `Message` tables power an LLM concierge for browsing appointments. User prompts call RubyLLM with either GPT-4o (vision) or GPT-4.1-nano depending on attachments. When no appointment context exists, the assistant queries `Appointment.nearest_neighbors(:embedding, …)` via the `neighbor` gem to surface suggestions.

### 3.4 Mobile-only niceties

- **Push token registration**: `POST /api/v1/users/push_token` stores Expo tokens in `users.push_token`.
- **Uploads**: avatars, appointment photos, and conversation attachments all post to dedicated `/api/v1/uploads/*` endpoints which validate file type/size before delegating to Cloudinary via Active Storage.
- **Payments & refunds**: stylists/customers can poll `/api/v1/appointments/:id/payment/status` or trigger `refund_payment` if a cancellation happens.

## 4. Authentication & Authorization

| Context | Mechanism | Notes |
| --- | --- | --- |
| Web | Devise session cookies | `before_action :authenticate_user!` across dashboards, bookings, chats, QuickBooks pages. |
| API | Devise-JWT | `Authorization: Bearer` header; denylisted tokens stored in `jwt_denylists`. |
| Roles | `User.role` enum (`customer`, `stylist`, `admin`) | Pundit policies on appointments, services, QuickBooks, stylist namespace, etc. |
| QuickBooks connect | Additional `ensure_stylist!` filters | Prevents non-stylists from touching accounting endpoints. |

## 5. Data, Search & Files

- **PostgreSQL** holds everything: users, services, locations, appointments, add-ons, conversations, chats, Active Storage metadata, QuickBooks tokens, and even Solid Cable’s persisted messages for resilience.
- **pgvector + neighbor** provide semantic lookups for appointments. Each appointment stores a 1536-dim embedding generated in `Appointment#set_embedding` (failures are logged and skipped).
- **Active Storage + Cloudinary** manage avatars, appointment images, AI chat photos, and conversation attachments. Uploads enforce MIME types (PNG/JPEG/WEBP) and 5 MB limits.

## 6. Notifications & Real-Time

- **Solid Cable** replaces Redis-backed ActionCable, writing channel payloads to `solid_cable_messages`. `ConversationMessage` automatically appends Turbo Stream fragments and broadcasts JSON payloads for any connected client.
- **Expo push**: `PushNotificationService` wraps `exponent-server-sdk`; controllers call `send_to_user` with structured `data` (booking_request, booking_accepted, booking_cancelled, review_request, new_message, etc.). Tokens are optional and can be cleared on logout.

## 7. External Integrations

| Integration | Trigger | Failure Handling |
| --- | --- | --- |
| Square (payments/refunds) | Explicit API calls during booking or cancellation. | Exceptions are caught and surfaced to clients; logs record the Square error payload. |
| QuickBooks Online | `QuickbooksController` (OAuth/manual) + `QuickbooksJob`. | Token refresh errors bubble up to logs and instruct stylists to reconnect. Invoice/payment errors are logged and appointment remains flagged locally. |
| RubyLLM | Appointment callback + AI chat flows. | Embedding failures log a warning but do not block bookings; chat errors show UI messages. |
| Expo Push | Booking lifecycle & messaging controllers. | Exceptions are logged; requests continue even if push delivery fails. |
| Cloudinary | Active Storage attachments. | Validation prevents oversized/invalid uploads; failures render standard Rails errors. |

## 8. Deployment Considerations

- **Puma** handles concurrent traffic; scale horizontally for high chat loads.
- **Background processing**: ensure ActiveJob (async or queuing backend) is configured so QuickBooks syncs don’t block web requests.
- **Environment secrets**: Square, QuickBooks, Cloudinary, Devise JWT secret, and LLM keys live in `.env`/Rails credentials; CI never commits them.
- **Webhooks**: none required today; QuickBooks + Square interactions are outbound only.
- **Monitoring**: logs capture payment/accounting/push failures; instrumentation can be layered with Sentry/Rollbar/New Relic as needed.

---

Use this document with `DATABASE_DESIGN.md` (for schema specifics) and `TECH_STACK.md` (for gem/service references) whenever you extend ChairHop.
