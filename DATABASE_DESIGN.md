# ChairHop Database Design (PostgreSQL + pgvector)

Schema version: `2026_02_19_214906` (matches WanjiKay/ChairHop_App_2 `db/schema.rb`). Extensions enabled: `plpgsql`, `vector`.

---

## 1. Core Entities

### 1.1 Users

Stores every account (customer, stylist, admin) plus profile metadata and mobile push tokens.

```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email CITEXT NOT NULL UNIQUE,
  encrypted_password TEXT NOT NULL,
  name VARCHAR,
  username VARCHAR,
  about TEXT,
  role SMALLINT NOT NULL DEFAULT 0,              -- enum: 0 customer, 1 stylist, 2 admin
  push_token VARCHAR,                            -- Expo token for push notifications
  street_address VARCHAR,
  city VARCHAR,
  state VARCHAR,
  zip_code VARCHAR,
  latitude DECIMAL(10,6),
  longitude DECIMAL(10,6),
  quickbooks_customer_id VARCHAR,
  reset_password_token VARCHAR UNIQUE,
  reset_password_sent_at TIMESTAMP,
  remember_created_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

**Relationships**
- Appointments via `appointments.customer_id` and `appointments.stylist_id`.
- Services (`services.stylist_id`).
- Locations (`locations.user_id`).
- Reviews (both author + target).
- Chats (customer-only) and Conversations (customer + stylist pair).
- One `quick_books_token` per stylist.
- Active Storage association for avatars.

Indexes: `users_email_idx`, `users_reset_password_token_idx`, `users_quickbooks_customer_id_idx`.

### 1.2 Locations

A stylist can manage multiple business addresses.

```sql
CREATE TABLE locations (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  name VARCHAR NOT NULL,
  street_address VARCHAR NOT NULL,
  city VARCHAR NOT NULL,
  state VARCHAR NOT NULL,
  zip_code VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

Used by appointments via `appointments.location_id` (optional) so the system can reference a normalized address instead of free-text `location` strings.

### 1.3 Services

Services belong to stylists, store pricing in cents, and optionally track duration.

```sql
CREATE TABLE services (
  id BIGSERIAL PRIMARY KEY,
  stylist_id BIGINT NOT NULL REFERENCES users(id),
  name VARCHAR NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL,
  duration_minutes INTEGER,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE (stylist_id, name)
);
```

### 1.4 Appointments

Represents a time slot that a stylist can publish and a customer can book.

```sql
CREATE TABLE appointments (
  id BIGSERIAL PRIMARY KEY,
  time TIMESTAMP,
  location VARCHAR,                   -- human-readable fallback
  location_id BIGINT REFERENCES locations(id),
  salon VARCHAR,
  services TEXT,                      -- comma-separated summary
  selected_service VARCHAR,           -- chosen service for a booking
  customer_id BIGINT REFERENCES users(id),
  stylist_id BIGINT NOT NULL REFERENCES users(id),
  booked BOOLEAN,
  status SMALLINT NOT NULL DEFAULT 0, -- enum: pending, booked, completed, cancelled
  content TEXT,
  embedding VECTOR(1536),             -- pgvector for semantic search
  payment_amount DECIMAL(10,2),
  payment_status VARCHAR DEFAULT 'pending',
  payment_id VARCHAR,                 -- Square payment identifier
  payment_method VARCHAR,             -- card last 4 digits
  quickbooks_invoice_id VARCHAR,
  quickbooks_payment_id VARCHAR,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
CREATE INDEX index_appointments_on_customer_id ON appointments(customer_id);
CREATE INDEX index_appointments_on_stylist_id ON appointments(stylist_id);
CREATE INDEX index_appointments_on_location_id ON appointments(location_id);
CREATE INDEX index_appointments_on_quickbooks_invoice_id ON appointments(quickbooks_invoice_id);
```

**Callbacks & workflows**
- `has_neighbors :embedding` (via the `neighbor` gem) enables nearest-neighbor queries for AI appointment search.
- `after_create :set_embedding` calls RubyLLM; errors are logged but do not fail the transaction.
- `after_update :sync_to_quickbooks` triggers when `completed` + `paid` + stylist has tokens. Adds invoice/payment IDs to the same row.

### 1.5 Appointment Add-ons

Connect optional add-on services (e.g., scalp massage) to an appointment. Supports both references to the `services` table and legacy ad-hoc entries.

```sql
CREATE TABLE appointment_add_ons (
  id BIGSERIAL PRIMARY KEY,
  appointment_id BIGINT NOT NULL REFERENCES appointments(id),
  service_id BIGINT REFERENCES services(id),   -- optional
  service_name VARCHAR,                        -- legacy fallback
  price DECIMAL(8,2),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
CREATE INDEX index_appointment_add_ons_on_appointment_id ON appointment_add_ons(appointment_id);
CREATE INDEX index_appointment_add_ons_on_service_id ON appointment_add_ons(service_id);
```

Model helpers expose `final_name`/`final_price` so downstream JSON responses don’t have to branch on legacy vs. normalized data.

### 1.6 QuickBooks Tokens

One row per stylist after they connect QuickBooks (OAuth2 or manual sandbox entry).

```sql
CREATE TABLE quick_books_tokens (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE REFERENCES users(id),
  access_token TEXT NOT NULL,
  refresh_token TEXT NOT NULL,
  realm_id VARCHAR NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

`QuickbooksService` refreshes tokens when `expires_at <= NOW() + 10 minutes`.

---

## 2. Communication Surfaces

### 2.1 Chats (AI Concierge)

```sql
CREATE TABLE chats (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES users(id),
  appointment_id BIGINT REFERENCES appointments(id),
  title VARCHAR,
  model_id VARCHAR,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

Chats belong only to customers and store the LLM model that handled the thread (`gpt-4.1-nano` for text, `gpt-4o` for vision). When unattached to an appointment, RubyLLM embeddings + the `neighbor` gem surface nearby availability options.

### 2.2 Messages

```sql
CREATE TABLE messages (
  id BIGSERIAL PRIMARY KEY,
  chat_id BIGINT NOT NULL REFERENCES chats(id),
  role VARCHAR NOT NULL,             -- "user" or "assistant"
  content TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

- Photo attachments (`has_many_attached :photos`).
- Validations cap user messages at 15 per chat and enforce 5 MB/image + PNG/JPEG/WEBP mime-types.

### 2.3 Conversations (Customer ↔ Stylist)

```sql
CREATE TABLE conversations (
  id BIGSERIAL PRIMARY KEY,
  appointment_id BIGINT NOT NULL REFERENCES appointments(id),
  customer_id BIGINT NOT NULL REFERENCES users(id),
  stylist_id BIGINT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

Pairs of users tied to a single appointment. Each conversation exposes both Turbo Streams (for the HTML UI) and ActionCable broadcasts (through Solid Cable) so mobile clients can subscribe.

```sql
CREATE TABLE conversation_messages (
  id BIGSERIAL PRIMARY KEY,
  conversation_id BIGINT NOT NULL REFERENCES conversations(id),
  role VARCHAR NOT NULL,             -- "customer" or "stylist"
  content TEXT,
  read_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

- Message attachments use Active Storage (same validations as chat photos).
- Two callbacks fire per insert:
  1. `broadcast_append_to` Turbo stream → updates the HTML conversation list.
  2. `ConversationChannel.broadcast_to` → ActionCable payload `{ type: 'new_message', ... }` for real-time clients.

### 2.4 Reviews

One review per completed appointment.

```sql
CREATE TABLE reviews (
  id BIGSERIAL PRIMARY KEY,
  appointment_id BIGINT NOT NULL UNIQUE REFERENCES appointments(id),
  customer_id BIGINT NOT NULL REFERENCES users(id),
  stylist_id BIGINT NOT NULL REFERENCES users(id),
  rating SMALLINT,
  content TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

### 2.5 JWT Denylist

Used by Devise-JWT to revoke tokens on logout.

```sql
CREATE TABLE jwt_denylists (
  id BIGSERIAL PRIMARY KEY,
  jti VARCHAR NOT NULL UNIQUE,
  exp TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

### 2.6 Solid Cable Messages

When `solid_cable` is enabled, ActionCable payloads persist here for reliability across dynos.

```sql
CREATE TABLE solid_cable_messages (
  id BIGSERIAL PRIMARY KEY,
  channel TEXT,
  payload TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
CREATE INDEX index_solid_cable_messages_on_created_at ON solid_cable_messages(created_at);
```

### 2.7 Active Storage Tables

Standard Rails tables for attachments (avatars, appointment images, chat/conversation photos). Both enforce uniqueness + referential integrity.

---

## 3. Relationships Diagram

```
Users (roles + push tokens + QuickBooks customer IDs)
 ├─< Services (price_cents, duration)
 ├─< Locations (multiple per stylist)
 ├─< Appointments (embeddings, payment + accounting fields)
 │    ├─< AppointmentAddOns (optional Service reference)
 │    ├─1 Conversation (customer ↔ stylist)
 │    │    └─< ConversationMessages (photos, read receipts)
 │    ├─1 Review (post-completion)
 │    └─< Chats (AI concierge threads)
 │          └─< Messages (LLM transcript + token counts)
 └─1 QuickBooksToken (stylists only)
```

---

## 4. Typical Query Patterns

| Goal | SQL sketch |
| --- | --- |
| Customer’s upcoming appointments | `SELECT * FROM appointments WHERE customer_id = $1 AND time >= NOW() ORDER BY time ASC;` |
| Stylist dashboard counts | `SELECT status, COUNT(*) FROM appointments WHERE stylist_id = $1 GROUP BY status;` |
| Semantic search | `SELECT * FROM appointments ORDER BY embedding <-> $query_vector LIMIT 5;` |
| Booking history for review prompts | `SELECT * FROM appointments WHERE stylist_id = $1 AND status = 2 AND quickbooks_invoice_id IS NULL;` |
| Conversations unread | `SELECT conversation_id, COUNT(*) FROM conversation_messages WHERE stylist_id = $CURRENT AND read_at IS NULL GROUP BY conversation_id;` |

---

## 5. Scaling & Maintenance Notes

- **Indexes**: add composite indexes (`(status, time)`, `(stylist_id, status, time)`) if booking lists grow large. pgvector can leverage IVF/HNSW indexes once the dataset justifies it.
- **Partitions**: chat/conversation messages can be archived or partitioned by month to keep Solid Cable payloads lean.
- **Storage**: Cloudinary handles binary files; database stores metadata only.
- **Retention**: JWT denylist rows can be pruned via cron once `exp < NOW()`.
- **Privacy**: QuickBooks tokens include refresh secrets—restrict access and ensure backups are encrypted.

---

This schema snapshot stays synchronized with the upstream repository. Update it whenever migrations change or new integrations (e.g., loyalty programs, gift cards) introduce additional tables.
