# ✅ Reviews & Stylist Appointments API - Implementation Complete

**Date:** January 29, 2026
**Controllers:**
- `app/controllers/api/v1/reviews_controller.rb`
- `app/controllers/api/v1/stylist/appointments_controller.rb`

---

## Part 1: Reviews API

### Endpoints

#### 1. POST /api/v1/reviews
**Purpose:** Create a review for a completed appointment
**Authorization:** Required (must be appointment participant)
**Validation:**
- Appointment must be completed
- Current user must be customer or stylist of appointment
- Appointment cannot already have a review
- Rating: 1-5 (required)
- Content: max 500 characters (required per model validation)

**Request Body:**
```json
{
  "review": {
    "appointment_id": 5,
    "rating": 5,
    "content": "Excellent service! Very professional and friendly."
  }
}
```

**Success Response (201 Created):**
```json
{
  "review": {
    "id": 1,
    "appointment_id": 5,
    "rating": 5,
    "content": "Excellent service! Very professional and friendly.",
    "reviewer": {
      "id": 22,
      "name": "Customer 1",
      "username": "customer1",
      "role": "customer"
    },
    "reviewed_user": {
      "id": 19,
      "name": "Chico",
      "username": "chico_styles",
      "role": "stylist"
    },
    "created_at": "2026-01-29T23:30:00.000Z",
    "updated_at": "2026-01-29T23:30:00.000Z"
  },
  "message": "Review submitted successfully"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not part of this appointment
- 404 Not Found - Appointment doesn't exist
- 422 Unprocessable Entity - Appointment not completed / Review already exists / Validation errors

**Example Request:**
```bash
curl -X POST "http://localhost:3000/api/v1/reviews" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "review": {
      "appointment_id": 5,
      "rating": 5,
      "content": "Great haircut!"
    }
  }'
```

---

#### 2. GET /api/v1/appointments/:appointment_id/reviews
**Purpose:** Get review for a specific appointment
**Authorization:** Required (must be appointment participant)

**Success Response (200 OK):**
```json
{
  "review": {
    "id": 1,
    "appointment_id": 5,
    "rating": 5,
    "content": "Excellent service!",
    "reviewer": {...},
    "reviewed_user": {...},
    "created_at": "2026-01-29T23:30:00.000Z",
    "updated_at": "2026-01-29T23:30:00.000Z"
  }
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not part of this appointment
- 404 Not Found - Appointment doesn't exist or no review found

**Example Request:**
```bash
curl -X GET "http://localhost:3000/api/v1/appointments/5/reviews" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Part 2: Stylist Appointments API

All endpoints require:
- Authentication (JWT token)
- User must be a stylist (role: 'stylist')

### Endpoints

#### 1. GET /api/v1/stylist/appointments
**Purpose:** List all appointments for current stylist
**Query Parameters:**
- `status` - Filter by status (pending, booked, completed, cancelled)
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 20)

**Features:**
- Shows only appointments where stylist_id = current_user.id
- Includes customer info (if assigned)
- Includes add-ons with prices
- Calculates total price
- Pagination
- Smart ordering: upcoming first for pending/booked, recent first for completed

**Success Response (200 OK):**
```json
{
  "appointments": [
    {
      "id": 5,
      "time": "2026-01-29T20:00:00.000Z",
      "date": "2026-01-29",
      "location": "210 Boulevard des Laurentides, Laval",
      "status": "pending",
      "booked": false,
      "selected_service": null,
      "services_text": "Color Treatment - $90\nHighlights - $120",
      "created_at": "2026-01-29T01:40:38.165Z",
      "updated_at": "2026-01-29T01:40:38.165Z",
      "add_ons": [],
      "total_price": 0
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 12,
    "per_page": 20
  }
}
```

**Example Request:**
```bash
curl -X GET "http://localhost:3000/api/v1/stylist/appointments?status=booked" \
  -H "Authorization: Bearer STYLIST_TOKEN"
```

---

#### 2. POST /api/v1/stylist/appointments
**Purpose:** Create new availability slot
**Request Body:**
```json
{
  "time": "2026-03-01T14:00:00",
  "location": "Montreal Salon",
  "services": ["Haircut", "Coloring", "Styling"]
}
```

**Fields:**
- `time` (required) - DateTime when slot is available
- `location` (required) - Where the appointment will take place
- `services` (optional) - Array of service names offered

**Logic:**
- Sets stylist_id to current_user.id
- Status defaults to :pending
- booked defaults to false
- customer_id is null
- Services array joined into text field

**Success Response (201 Created):**
```json
{
  "appointment": {
    "id": 14,
    "time": "2026-03-01T14:00:00.000Z",
    "date": "2026-03-01",
    "location": "Montreal Salon",
    "status": "pending",
    "booked": false,
    "selected_service": null,
    "services_text": "Haircut, Coloring, Styling",
    "created_at": "2026-01-29T23:27:06.298Z",
    "updated_at": "2026-01-29T23:27:06.298Z",
    "add_ons": [],
    "total_price": 0
  },
  "message": "Availability created successfully"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - User is not a stylist
- 422 Unprocessable Entity - Validation errors (missing time/location)

**Example Request:**
```bash
curl -X POST "http://localhost:3000/api/v1/stylist/appointments" \
  -H "Authorization: Bearer STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "time": "2026-03-01T14:00:00",
    "location": "Montreal Salon",
    "services": ["Haircut", "Styling"]
  }'
```

---

#### 3. PATCH /api/v1/stylist/appointments/:id/accept
**Purpose:** Accept a pending booking request from customer

**Validation:**
- Appointment must belong to current stylist
- Status must be :pending
- customer_id must be present (someone requested it)

**Logic:**
- Calls appointment.accept! method (sets status: :booked, booked: true)

**Success Response (200 OK):**
```json
{
  "appointment": {
    "id": 14,
    "status": "booked",
    "booked": true,
    "customer": {
      "id": 22,
      "name": "Customer 1",
      "username": "customer1"
    },
    ...
  },
  "message": "Booking accepted successfully"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not a stylist or not your appointment
- 404 Not Found - Appointment doesn't exist
- 422 Unprocessable Entity - Not pending or no customer assigned

**Example Request:**
```bash
curl -X PATCH "http://localhost:3000/api/v1/stylist/appointments/14/accept" \
  -H "Authorization: Bearer STYLIST_TOKEN"
```

---

#### 4. PATCH /api/v1/stylist/appointments/:id/complete
**Purpose:** Mark appointment as completed

**Validation:**
- Appointment must belong to current stylist
- Status must be :booked
- Appointment time must have passed (time < Time.current)

**Logic:**
- Updates status to :completed

**Success Response (200 OK):**
```json
{
  "appointment": {
    "id": 14,
    "status": "completed",
    ...
  },
  "message": "Appointment marked as completed"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not a stylist or not your appointment
- 404 Not Found - Appointment doesn't exist
- 422 Unprocessable Entity - Not booked or time hasn't passed

**Example Request:**
```bash
curl -X PATCH "http://localhost:3000/api/v1/stylist/appointments/14/complete" \
  -H "Authorization: Bearer STYLIST_TOKEN"
```

---

#### 5. DELETE /api/v1/stylist/appointments/:id
**Purpose:** Cancel or delete an appointment

**Logic:**
- If customer_id is present: Calls appointment.cancel! (sets status: :cancelled, customer_id: nil)
- If no customer: Destroys the appointment (removes availability)

**Success Response (200 OK):**
```json
{
  "message": "Appointment cancelled successfully"
}
```
OR
```json
{
  "message": "Availability slot deleted successfully"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not a stylist or not your appointment
- 404 Not Found - Appointment doesn't exist

**Example Request:**
```bash
curl -X DELETE "http://localhost:3000/api/v1/stylist/appointments/14" \
  -H "Authorization: Bearer STYLIST_TOKEN"
```

---

## Routes Added

```ruby
# Reviews
POST   /api/v1/reviews                              api/v1/reviews#create
GET    /api/v1/appointments/:appointment_id/reviews api/v1/reviews#show

# Stylist Appointments
GET    /api/v1/stylist/appointments                 api/v1/stylist/appointments#index
POST   /api/v1/stylist/appointments                 api/v1/stylist/appointments#create
PATCH  /api/v1/stylist/appointments/:id/accept      api/v1/stylist/appointments#accept
PATCH  /api/v1/stylist/appointments/:id/complete    api/v1/stylist/appointments#complete
DELETE /api/v1/stylist/appointments/:id             api/v1/stylist/appointments#destroy
```

---

## Authorization Summary

### Reviews Controller
- ✅ Requires authentication for all endpoints
- ✅ Users must be appointment participants (customer or stylist)
- ✅ Appointment must be completed before review
- ✅ One review per appointment

### Stylist Appointments Controller
- ✅ Requires authentication for all endpoints
- ✅ User must have role: 'stylist'
- ✅ Stylists can only access their own appointments (stylist_id = current_user.id)
- ✅ Authorization checked in before_action

---

## Error Handling

All endpoints return consistent JSON error responses:

**401 Unauthorized:**
```json
{
  "error": "Missing authentication token"
}
```

**403 Forbidden:**
```json
{
  "error": "Forbidden",
  "message": "Only stylists can access this endpoint"
}
```

**404 Not Found:**
```json
{
  "error": "Appointment not found"
}
```

**422 Unprocessable Entity:**
```json
{
  "error": "Cannot review",
  "message": "Appointment must be completed before leaving a review"
}
```

---

## Testing

### Test Script
Run comprehensive tests:
```bash
chmod +x test_reviews_and_stylist_api.sh
./test_reviews_and_stylist_api.sh
```

### Manual Testing

**Stylist Flow:**
```bash
# 1. Login as stylist
STYLIST_TOKEN=$(curl -s -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"chico@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')

# 2. View appointments
curl -X GET "http://localhost:3000/api/v1/stylist/appointments" \
  -H "Authorization: $STYLIST_TOKEN"

# 3. Create availability
curl -X POST "http://localhost:3000/api/v1/stylist/appointments" \
  -H "Authorization: $STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"time":"2026-03-01T14:00:00","location":"Montreal"}'

# 4. Accept booking
curl -X PATCH "http://localhost:3000/api/v1/stylist/appointments/14/accept" \
  -H "Authorization: $STYLIST_TOKEN"

# 5. Complete appointment
curl -X PATCH "http://localhost:3000/api/v1/stylist/appointments/14/complete" \
  -H "Authorization: $STYLIST_TOKEN"
```

**Review Flow:**
```bash
# 1. Create review for completed appointment
curl -X POST "http://localhost:3000/api/v1/reviews" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "review": {
      "appointment_id": 5,
      "rating": 5,
      "content": "Great service!"
    }
  }'

# 2. View review
curl -X GET "http://localhost:3000/api/v1/appointments/5/reviews" \
  -H "Authorization: Bearer TOKEN"
```

---

## Files Modified

1. **Created:** `app/controllers/api/v1/reviews_controller.rb`
   - 157 lines
   - 2 public actions (create, show)
   - Authorization with participant checks
   - Handles both customer→stylist and stylist→customer reviews

2. **Created:** `app/controllers/api/v1/stylist/appointments_controller.rb`
   - 241 lines
   - 5 public actions (index, create, accept, complete, destroy)
   - Stylist-only authorization
   - Smart business logic for booking workflow

3. **Modified:** `config/routes.rb`
   - Added reviews routes
   - Added stylist namespace with appointments routes

4. **Created:** `test_reviews_and_stylist_api.sh`
   - Comprehensive test script

---

## Key Implementation Details

### Reviews Controller
- **Bi-directional reviews:** Customer can review stylist, stylist can review customer
- **Automatic relationship detection:** Determines reviewer and reviewed user based on current_user
- **Strict validation:** Appointment must be completed, can't review twice
- **Privacy:** Only participants can view reviews

### Stylist Appointments Controller
- **Role-based access:** Only users with role 'stylist' can access
- **Ownership enforcement:** Stylists can only manage their own appointments
- **Workflow management:**
  - Create → Customer books → Stylist accepts → Complete
  - Can cancel at any stage
  - Can delete if no customer assigned
- **Smart ordering:** Upcoming first for active, recent first for completed

---

## Next Steps

✅ **Completed:**
- Customer Appointments API
- Reviews API
- Stylist Appointments Management API

**Remaining:**
1. Services API:
   - GET /api/v1/services (browse all)
   - GET /api/v1/stylists/:id/services
   - GET /api/v1/stylist/services (my services)
   - POST /api/v1/stylist/services (create)
   - PATCH /api/v1/stylist/services/:id (update)

2. Stylists Browsing API:
   - GET /api/v1/stylists (list all stylists)
   - GET /api/v1/stylists/:id (stylist profile with services and reviews)

---

**API Status:** ✅ Reviews & Stylist Appointments API Complete and Tested

Ready for React Native integration! 🚀
