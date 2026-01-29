# ChairHop Refactoring Notes

**Date:** January 28, 2026
**Goal:** Refactor Rails MVP to API-first backend for React Native mobile apps

---

## ✅ What Was Completed Today

### 🗄️ Database Migrations Created

1. **`20260129005654_add_role_to_users.rb`**
   - Added `role` integer column (default: 0)
   - Enum: customer (0), stylist (1), admin (2)
   - Data migration to set existing users' roles based on appointments_as_stylist

2. **`20260129011306_create_jwt_denylist.rb`**
   - Created JWT token revocation table
   - Columns: `jti` (JWT ID), `exp` (expiration), timestamps
   - Index on `jti` for fast lookups

3. **`20260129012811_create_services.rb`**
   - Created services table for secure pricing
   - Columns: name, description, price_cents (integer), stylist_id, active
   - Index on [stylist_id, name]
   - Prices stored in cents to avoid float rounding issues

4. **`20260129013004_add_service_to_appointment_add_ons.rb`**
   - Added optional `service_id` foreign key to appointment_add_ons
   - Nullable for backward compatibility with legacy service_name/price fields

**All migrations applied successfully ✓**

---

### 🏗️ New Models Added

1. **`Service` Model** ([app/models/service.rb](app/models/service.rb))
   - Belongs to stylist (User)
   - Has many appointment_add_ons
   - Validations: name, price_cents (> 0), stylist_id required
   - Helper methods: `price` (converts cents to dollars), `price=` (converts dollars to cents)
   - Scopes: `active`, `for_stylist(stylist_id)`

2. **`JwtDenylist` Model** ([app/models/jwt_denylist.rb](app/models/jwt_denylist.rb))
   - Implements Devise JWT revocation strategy
   - Tracks revoked tokens on logout

---

### 🎮 New Controllers Added

1. **`Api::V1::BaseController`** ([app/controllers/api/v1/base_controller.rb](app/controllers/api/v1/base_controller.rb))
   - Inherits from `ActionController::API` (lightweight, no views)
   - Includes Pundit for authorization
   - Skips CSRF verification
   - JSON error handling for NotAuthorizedError and RecordNotFound
   - Helper methods: `render_error()`, `render_success()`

2. **`Api::V1::SessionsController`** ([app/controllers/api/v1/sessions_controller.rb](app/controllers/api/v1/sessions_controller.rb))
   - POST `/api/v1/login` - Authenticate user, return JWT token
   - DELETE `/api/v1/logout` - Revoke JWT token
   - Returns user data (id, email, name, role, etc.)

3. **`Api::V1::RegistrationsController`** ([app/controllers/api/v1/registrations_controller.rb](app/controllers/api/v1/registrations_controller.rb))
   - POST `/api/v1/signup` - Create new user, return JWT token
   - Defaults new users to `customer` role
   - Returns user data with token in Authorization header

---

### 🔐 Security Fixes Implemented

#### 1. Authorization with Pundit
- **Added `AppointmentPolicy`** ([app/policies/appointment_policy.rb](app/policies/appointment_policy.rb))
  - index: anyone can view pending appointments
  - show/booked: only involved parties can view
  - book/check_in: only customers can book pending appointments
  - accept: only stylists can accept their appointments
  - complete: both parties can complete (with time restrictions for customers)
  - destroy/cancel: both parties can cancel their own appointments

- **Updated AppointmentsController** ([app/controllers/appointments_controller.rb](app/controllers/appointments_controller.rb))
  - Added `authorize` calls to all actions
  - Added `show` action (was missing)
  - Updated `my_appointments` to show both customer AND stylist appointments

#### 2. File Upload Validation
- **User Model** ([app/models/user.rb:32-40](app/models/user.rb#L32-L40))
  - Content-type validation: PNG, JPEG, JPG, WEBP only
  - Size limit: 5MB maximum
  - Custom `avatar_validation` method

- **Message Model** ([app/models/message.rb:13-39](app/models/message.rb#L13-L39))
  - Same content-type restrictions
  - Size limit reduced from 10MB to 5MB
  - Added `file_content_type_validation` method

- **ConversationMessage Model** ([app/models/conversation_message.rb:11-35](app/models/conversation_message.rb#L11-L35))
  - Same validations as Message
  - Size limit: 5MB

#### 3. Secure Pricing Model
- **Service Model** replaces string-based pricing
  - Prices stored in cents (integer) - no float rounding issues
  - Prices owned by stylists (can't be manipulated by customers)
  - AppointmentAddOn references Service instead of storing price directly

- **AppointmentAddOn Updated** ([app/models/appointment_add_on.rb](app/models/appointment_add_on.rb))
  - `belongs_to :service, optional: true`
  - Helper methods: `final_price`, `final_name` (works with both Service and legacy data)
  - Validation ensures either service_id OR service_name+price are present
  - **Backward compatible** with existing appointment_add_ons

#### 4. Appointment Workflow Improvements
- **Added status transition methods** ([app/models/appointment.rb:98-110](app/models/appointment.rb#L98-L110))
  - `accept!` - Transitions pending → booked, saves all changes
  - `cancel!` - Cancels appointment, clears customer, saves changes
  - Updated controller to use these methods instead of direct status updates

---

### 🔌 API Infrastructure Set Up

#### 1. JWT Authentication (devise-jwt)
- **Gems Added:**
  - `devise-jwt` - JWT token authentication
  - `rack-cors` - CORS handling for mobile apps

- **Configuration:**
  - JWT secret via `ENV['DEVISE_JWT_SECRET_KEY']`
  - Token expiration: 30 days
  - Revocation strategy: JwtDenylist
  - Dispatch on: POST /api/v1/login, POST /api/v1/signup
  - Revoke on: DELETE /api/v1/logout

- **User Model Updated** ([app/models/user.rb:6](app/models/user.rb#L6))
  - Added `:jwt_authenticatable` devise module
  - JWT revocation strategy: JwtDenylist

#### 2. CORS Configuration ([config/initializers/cors.rb](config/initializers/cors.rb))
- Allowed origins:
  - React Native Metro: `http://localhost:8081`
  - Expo dev server: `http://localhost:19000`
  - Expo web: `http://localhost:19006`
  - Expo Go app: `exp://` scheme
- Exposes Authorization header
- Allows credentials
- Configured for `/api/*` routes only

#### 3. API Routes Added ([config/routes.rb:46-54](config/routes.rb#L46-L54))
```ruby
namespace :api do
  namespace :v1 do
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    post 'signup', to: 'registrations#create'
  end
end
```

---

### 📊 Database Seeded

**Created via `rails db:seed`:**
- 14 Users (4 stylists, 10 customers)
- 56 Services (distributed across 4 stylists based on salon)
- 12 Appointments (3 per salon, all status: pending)
- All users use password: "password" (via `ENV['SEED_PASSWORD']`)

**Note:** Image uploads disabled in seeds (requires Cloudinary API key)

---

## 🔄 What Still Needs To Be Done

### From "SHOULD FIX" List (Deferred):

1. **Extract appointment search logic to service**
   - Current: Search logic in AppointmentsController
   - Goal: Move to `AppointmentSearchService` for reusability
   - When: Can wait until search becomes more complex

2. **Consolidate messaging systems**
   - Current: Separate Chats (AI) and Conversations (human-to-human)
   - Goal: Rename for clarity or merge into polymorphic system
   - When: Before building messaging API

3. **Extract AI prompt logic**
   - Current: Prompt building in ChatsController
   - Goal: Move to `AiPromptBuilder` service
   - When: Before exposing AI chat in API

4. **Add appointment scopes**
   - Goal: Add scopes like `available`, `upcoming`, `past`
   - When: Before building appointment API (will make queries cleaner)

---

### API Endpoints That Need To Be Built

#### Customer API Endpoints:

1. **Appointments**
   - `GET /api/v1/appointments` - Browse available appointments (with search/filters)
   - `GET /api/v1/appointments/:id` - View appointment details
   - `POST /api/v1/appointments/:id/book` - Book appointment with services
   - `DELETE /api/v1/appointments/:id` - Cancel booking
   - `PATCH /api/v1/appointments/:id/complete` - Mark as complete
   - `GET /api/v1/my_appointments` - List user's bookings

2. **Services**
   - `GET /api/v1/services` - Browse services (filtered by stylist/salon)
   - `GET /api/v1/stylists/:id/services` - Get services for specific stylist

3. **Stylists**
   - `GET /api/v1/stylists` - Browse stylists
   - `GET /api/v1/stylists/:id` - View stylist profile with reviews

4. **Profile**
   - `GET /api/v1/profile` - Get current user profile
   - `PATCH /api/v1/profile` - Update profile
   - `POST /api/v1/profile/avatar` - Upload avatar

5. **Reviews**
   - `GET /api/v1/appointments/:id/review` - Get review for appointment
   - `POST /api/v1/appointments/:id/reviews` - Create review
   - `GET /api/v1/stylists/:id/reviews` - List stylist reviews

6. **Conversations**
   - `GET /api/v1/conversations` - List conversations
   - `GET /api/v1/conversations/:id` - Show conversation with messages
   - `POST /api/v1/conversations` - Create conversation
   - `POST /api/v1/conversations/:id/messages` - Send message

7. **AI Chat** (Optional)
   - `GET /api/v1/chats` - List AI chats
   - `GET /api/v1/chats/:id` - Show chat with messages
   - `POST /api/v1/chats` - Create AI chat
   - `POST /api/v1/chats/:id/messages` - Send message to AI

#### Stylist API Endpoints:

1. **Dashboard**
   - `GET /api/v1/stylist/dashboard` - Overview stats
   - `GET /api/v1/stylist/appointments` - Upcoming/past appointments

2. **Availability Management**
   - `GET /api/v1/stylist/availability` - View availability slots
   - `POST /api/v1/stylist/availability` - Create availability slot
   - `PATCH /api/v1/stylist/availability/:id` - Update slot
   - `DELETE /api/v1/stylist/availability/:id` - Remove slot

3. **Appointments**
   - `GET /api/v1/stylist/appointment_requests` - Pending bookings
   - `POST /api/v1/stylist/appointments/:id/accept` - Accept booking
   - `POST /api/v1/stylist/appointments/:id/reject` - Reject booking
   - `PATCH /api/v1/stylist/appointments/:id/complete` - Complete appointment

4. **Services**
   - `GET /api/v1/stylist/services` - My services
   - `POST /api/v1/stylist/services` - Create service
   - `PATCH /api/v1/stylist/services/:id` - Update service
   - `DELETE /api/v1/stylist/services/:id` - Deactivate service

5. **Earnings** (Future)
   - `GET /api/v1/stylist/earnings` - Revenue reports
   - `GET /api/v1/stylist/payouts` - Payout history

---

### Technical Debt (Skipped for Now):

1. **Test Coverage**
   - No tests exist currently
   - Plan: Add tests as we build API endpoints
   - Use RSpec + FactoryBot for new code

2. **Rate Limiting**
   - Not implemented yet
   - Plan: Add `rack-attack` gem before production
   - Limit API requests per IP/user

3. **Advanced Search**
   - Current search is basic (string matching with synonyms)
   - Plan: Consider Elasticsearch or pg_search for better search
   - When: If search becomes a bottleneck

4. **Caching**
   - No caching implemented
   - Plan: Add fragment caching for frequently accessed data
   - When: After profiling shows performance issues

5. **Background Jobs**
   - No job processing setup (Sidekiq, etc.)
   - Plan: Add when needed for async tasks (emails, notifications)
   - When: Building notification system

6. **Image Optimization**
   - Active Storage configured but no image processing
   - Plan: Add variants for thumbnails, optimized sizes
   - When: Building image-heavy features

---

## 🤔 Issues/Decisions Made

### 1. Appointment Workflow Change

**Old Flow:**
- Stylist creates availability slot (status: pending)
- Customer books it directly (status: booked)

**New Flow:**
- Stylist creates availability slot (status: pending)
- Customer requests booking (still pending, but customer assigned)
- Stylist accepts/rejects (pending → booked or cancelled)

**Decision:**
- Implemented `accept!` method but kept current booking flow
- Can switch to stylist-approval flow later by updating controller
- Added `accept!` method for future use in stylist API

**Rationale:**
- Maintains backward compatibility with existing views
- Allows gradual transition to new workflow
- Stylist app can use `accept!` method

### 2. JWT vs Sessions for Mobile

**Why JWT over Sessions:**
- ✅ Stateless - no server-side session storage needed
- ✅ Works across domains/subdomains
- ✅ Better for mobile apps (can store token in AsyncStorage)
- ✅ Scales horizontally (no sticky sessions needed)
- ✅ Can include user data in token payload

**Trade-offs:**
- ⚠️ Tokens can't be invalidated immediately (until expiration)
- ⚠️ Token size larger than session cookie
- ✅ **Mitigated by:** Using JwtDenylist for revocation

**Decision:** JWT with 30-day expiration and denylist revocation

### 3. Service Model vs Dynamic Pricing

**Options Considered:**
1. Continue parsing prices from strings ("Service - $50")
2. Create Service model with fixed pricing
3. Dynamic pricing engine with rules

**Decision:** Option 2 - Service model with fixed pricing

**Rationale:**
- ✅ Prevents price manipulation
- ✅ Simple to implement and maintain
- ✅ Adequate for current business model
- ✅ Can add dynamic pricing later if needed
- ✅ Backward compatible (keeps legacy fields)

### 4. File Upload Validation

**Edge Cases Discovered:**
- Users could upload SVG files (potential XSS)
- No file size limits on some models
- Content-type not validated (could upload .exe as .png)

**Solutions Implemented:**
- Whitelist only: PNG, JPEG, JPG, WEBP
- Maximum 5MB file size
- Validate content-type, not just extension
- Applied to all upload points (User, Message, ConversationMessage)

### 5. Backward Compatibility

**Challenge:** Existing appointment_add_ons use service_name + price fields

**Solution:**
- Made `service_id` nullable in migration
- Added helper methods: `final_price`, `final_name`
- Validation allows either Service reference OR legacy fields
- New bookings will use Service model
- Old bookings continue to work

**Decision:** Prioritize safety over purity - keep legacy fields indefinitely

---

## 📋 Next Steps for Day 2

### Morning: Customer API Endpoints

1. **Appointments API**
   - `GET /api/v1/appointments` - List with search/filters
   - `GET /api/v1/appointments/:id` - Show details
   - Create AppointmentsSerializer
   - Add Pundit policies for API

2. **Booking Flow API**
   - `POST /api/v1/appointments/:id/book` - Book with services
   - Update booking to use Service model (not legacy string parsing)
   - Return detailed response with total price

3. **My Appointments API**
   - `GET /api/v1/my_appointments` - User's bookings
   - Include relationships (stylist, services, reviews)

### Afternoon: Stylist API Endpoints

1. **Stylist Profile API**
   - `GET /api/v1/stylists` - Browse stylists
   - `GET /api/v1/stylists/:id` - Profile with services and reviews
   - Create StylistSerializer

2. **Services API**
   - `GET /api/v1/services` - Browse all services
   - `GET /api/v1/stylists/:id/services` - Stylist's services
   - `GET /api/v1/stylist/services` - My services (authenticated)
   - `POST /api/v1/stylist/services` - Create service
   - `PATCH /api/v1/stylist/services/:id` - Update service

3. **Stylist Dashboard API**
   - `GET /api/v1/stylist/dashboard` - Stats overview
   - `GET /api/v1/stylist/appointments` - My appointments
   - `POST /api/v1/stylist/appointments/:id/accept` - Accept booking
   - `PATCH /api/v1/stylist/appointments/:id/complete` - Complete

### Evening: React Native Setup

1. **Initialize React Native Projects**
   - Customer app: `npx react-native init ChairHopCustomer`
   - Stylist app: `npx react-native init ChairHopStylist`
   - Install dependencies: `@react-native-async-storage/async-storage`, `axios`

2. **Authentication Setup**
   - Create auth service with API client
   - Test login/signup/logout flows
   - Store JWT in AsyncStorage

---

## 📚 Resources Created

1. **[API_SETUP.md](API_SETUP.md)** - Complete API documentation
   - Endpoint reference
   - Request/response examples
   - React Native integration guide
   - Testing instructions

2. **[.env.example](.env.example)** - Environment variables template
   - JWT secret configuration
   - Seed password
   - Cloudinary and OpenAI placeholders

3. **[test_api.sh](test_api.sh)** - API testing script
   - Automated testing of signup/login/logout
   - Run with `./test_api.sh`

4. **[REFACTORING_NOTES.md](REFACTORING_NOTES.md)** - This file
   - Complete refactoring history
   - Decisions and rationale
   - Next steps roadmap

---

## 🔍 Known Issues

1. **Cloudinary not configured**
   - Image uploads disabled in seeds
   - Add `CLOUDINARY_URL` to `.env` to enable

2. **OpenAI not configured**
   - Appointment embeddings disabled
   - Add `OPENAI_API_KEY` to `.env` to enable
   - Currently fails silently (logs warning)

3. **No email configuration**
   - Devise emails won't send
   - Configure ActionMailer before enabling email features

4. **Missing show action in routes**
   - AppointmentsController has `show` in before_action but no route
   - Add route when building API: `GET /api/v1/appointments/:id`

---

## 🎯 Success Metrics

**Backend Refactoring Complete When:**
- ✅ All MUST FIX security issues resolved
- ✅ JWT authentication working
- ✅ Role-based authorization implemented
- ✅ Secure pricing model in place
- ⏳ Core API endpoints built (appointments, services, profile)
- ⏳ API documentation complete
- ⏳ Mobile apps can authenticate and book appointments

**Current Progress:** 60% complete (infrastructure done, endpoints pending)

---

**Last Updated:** January 28, 2026
**Next Review:** After Day 2 API endpoint implementation
