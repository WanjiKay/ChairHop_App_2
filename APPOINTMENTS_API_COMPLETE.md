# ✅ Appointments API - Implementation Complete

**Date:** January 29, 2026
**Controller:** `app/controllers/api/v1/appointments_controller.rb`

---

## Endpoints Implemented

### 1. GET /api/v1/appointments (index)
**Purpose:** List all available appointments
**Authorization:** None required (public browsing)
**Features:**
- Lists only pending appointments (not yet booked)
- Pagination with Kaminari (20 per page default)
- Filtering:
  - `location` - filter by location string
  - `date` - filter by date (YYYY-MM-DD format)
  - `service_id` - filter by service ID
- Includes stylist info and services
- Returns metadata (current_page, total_pages, total_count)

**Example Request:**
```bash
curl -X GET "http://localhost:3000/api/v1/appointments?location=Montreal&per_page=10"
```

**Example Response:**
```json
{
  "appointments": [
    {
      "id": 5,
      "time": "2026-01-29T20:00:00.000Z",
      "date": "2026-01-29",
      "location": "210 Boulevard des Laurentides, Laval",
      "status": "pending",
      "selected_service": null,
      "stylist": {
        "id": 19,
        "name": "Chico",
        "username": "chico_styles",
        "location": "Montreal",
        "avatar_url": null
      },
      "services": []
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 6,
    "total_count": 12,
    "per_page": 10
  }
}
```

---

### 2. GET /api/v1/appointments/:id (show)
**Purpose:** Show single appointment details
**Authorization:**
- Anyone can view pending appointments
- Only customer or stylist can view booked/completed/cancelled appointments (Pundit policy)

**Features:**
- Full appointment details
- Stylist info
- Customer info (if booked)
- Add-ons with prices
- Total price calculation
- Timestamps

**Example Request:**
```bash
curl -X GET "http://localhost:3000/api/v1/appointments/5"
```

**Example Response:**
```json
{
  "appointment": {
    "id": 5,
    "time": "2026-01-29T20:00:00.000Z",
    "date": "2026-01-29",
    "location": "210 Boulevard des Laurentides, Laval",
    "status": "pending",
    "selected_service": null,
    "stylist": {...},
    "services": [],
    "add_ons": [],
    "total_price": 0,
    "created_at": "2026-01-29T01:40:38.165Z",
    "updated_at": "2026-01-29T01:40:38.165Z"
  }
}
```

---

### 3. POST /api/v1/appointments/:id/book (book)
**Purpose:** Book an available appointment
**Authorization:** Only customers (requires JWT token)
**Validation:**
- Appointment must be pending
- Appointment cannot already have a customer
- User must be a customer (not stylist)

**Request Body:**
```json
{
  "selected_service": "Haircut",
  "add_on_ids": [1, 2, 3]
}
```

**Features:**
- Assigns customer to appointment
- Sets selected_service field
- Creates AppointmentAddOn records for each service ID
- Transaction-safe (rolls back on failure)
- Status stays :pending (stylist must accept later)

**Example Request:**
```bash
curl -X POST "http://localhost:3000/api/v1/appointments/5/book" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"selected_service":"Haircut","add_on_ids":[1,2,3]}'
```

**Success Response (200 OK):**
```json
{
  "appointment": {...},
  "message": "Booking request sent to stylist"
}
```

**Error Responses:**
- 403 Forbidden - Only customers can book
- 422 Unprocessable Entity - Appointment no longer available
- 422 Unprocessable Entity - Appointment already booked

---

### 4. GET /api/v1/appointments/my_appointments (my_appointments)
**Purpose:** Show current user's appointments
**Authorization:** Required (JWT token)
**Features:**
- Returns customer's bookings if user is customer
- Returns stylist's appointments if user is stylist
- Filter by status: `?status=pending` or `?status=booked`
- Pagination (20 per page default)
- Includes all related data (stylist/customer, services, add-ons)
- Ordered by time (most recent first)

**Example Request:**
```bash
curl -X GET "http://localhost:3000/api/v1/appointments/my_appointments?status=booked" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Example Response:**
```json
{
  "appointments": [
    {
      "id": 5,
      "time": "2026-01-29T20:00:00.000Z",
      "date": "2026-01-29",
      "location": "210 Boulevard des Laurentides, Laval",
      "status": "pending",
      "selected_service": "Haircut",
      "stylist": {...},
      "customer": {...},
      "services": [...],
      "add_ons": [
        {
          "id": 1,
          "name": "Hair Coloring",
          "price": 80.0
        }
      ],
      "total_price": 80.0,
      "created_at": "2026-01-29T01:40:38.165Z",
      "updated_at": "2026-01-29T02:15:22.451Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 1,
    "per_page": 20
  }
}
```

---

## Routes Added

```ruby
namespace :api do
  namespace :v1 do
    resources :appointments, only: [:index, :show] do
      member do
        post :book
      end
      collection do
        get :my_appointments
      end
    end
  end
end
```

**Generated Routes:**
```
GET    /api/v1/appointments                    api/v1/appointments#index
GET    /api/v1/appointments/:id                api/v1/appointments#show
POST   /api/v1/appointments/:id/book           api/v1/appointments#book
GET    /api/v1/appointments/my_appointments    api/v1/appointments#my_appointments
```

---

## Error Handling

All endpoints include comprehensive error handling:

### 400 Bad Request
- Invalid date format in filters

### 401 Unauthorized
- Missing or invalid JWT token (for protected endpoints)

### 403 Forbidden
- Non-customers trying to book appointments
- Unauthorized access to private appointments

### 404 Not Found
- Appointment ID doesn't exist

### 422 Unprocessable Entity
- Appointment not available (no longer pending)
- Appointment already booked by another customer
- Validation errors when saving

---

## Key Implementation Details

### Database Schema Notes
- Appointments table has single `time` column (datetime), not separate date/time
- The controller returns both `time` (full datetime) and `date` (date only) in JSON
- Date filtering uses PostgreSQL `DATE()` function

### Association Fixes
- Appointments don't have direct `services` association
- Services accessed through `appointment_add_ons`
- Controller uses: `.includes(appointment_add_ons: :service)`

### Eager Loading
- Prevents N+1 queries with proper `.includes()`
- Loads stylist, customer, and services efficiently

### Pagination
- Uses Kaminari gem
- Default: 20 items per page
- Returns meta with: current_page, total_pages, total_count

### Authorization
- Uses Pundit policies
- Public: index (pending only), show (pending only)
- Protected: book (customers only), my_appointments (any authenticated user)

### Backward Compatibility
- Handles legacy AppointmentAddOns without service_id
- Falls back to service_name and price fields

---

## Testing

### Test Script
Run comprehensive tests with:
```bash
chmod +x test_appointments_api.sh
./test_appointments_api.sh
```

### Manual Testing Examples

**1. Browse appointments:**
```bash
curl -X GET "http://localhost:3000/api/v1/appointments?per_page=5"
```

**2. Filter by location:**
```bash
curl -X GET "http://localhost:3000/api/v1/appointments?location=Montreal"
```

**3. Login and book:**
```bash
# Login
TOKEN=$(curl -s -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer1@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')

# Book appointment
curl -X POST "http://localhost:3000/api/v1/appointments/5/book" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"selected_service":"Haircut","add_on_ids":[1,2]}'
```

**4. View my appointments:**
```bash
curl -X GET "http://localhost:3000/api/v1/appointments/my_appointments" \
  -H "Authorization: $TOKEN"
```

---

## Files Modified

1. **Created:** `app/controllers/api/v1/appointments_controller.rb`
   - 227 lines
   - 4 public actions + 3 private helpers
   - Full error handling and authorization

2. **Modified:** `config/routes.rb`
   - Added appointments routes under api/v1 namespace

3. **Created:** `test_appointments_api.sh`
   - Comprehensive test script
   - Tests all endpoints and error cases

4. **Verified:** `app/policies/appointment_policy.rb`
   - Already has `book?` method
   - Works with API authorization

---

## Next Steps

✅ **Completed:**
- Customer API endpoints for appointments
- Browse, view, book, and manage appointments
- Proper authorization and error handling

**Remaining for Day 2:**
1. Stylist API endpoints:
   - GET /api/v1/stylist/appointments (dashboard view)
   - POST /api/v1/stylist/appointments/:id/accept
   - PATCH /api/v1/stylist/appointments/:id/complete

2. Services API endpoints:
   - GET /api/v1/services (browse all services)
   - GET /api/v1/stylists/:id/services (stylist's services)

3. Stylists browsing:
   - GET /api/v1/stylists (list stylists)
   - GET /api/v1/stylists/:id (stylist profile with reviews)

---

**API Status:** ✅ Customer Appointments API Complete and Tested

Ready for React Native integration!
