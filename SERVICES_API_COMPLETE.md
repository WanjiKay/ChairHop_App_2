# ✅ Services API - Implementation Complete

**Date:** January 29, 2026
**Controllers:**
- `app/controllers/api/v1/services_controller.rb`
- `app/controllers/api/v1/stylist/services_controller.rb`

---

## Part 1: Public Services API (Customer Browsing)

### Endpoints

#### 1. GET /api/v1/services
**Purpose:** Browse all active services across all stylists
**Authorization:** None required (public endpoint)
**Query Parameters:**
- `stylist_id` (integer) - Filter by specific stylist
- `active` (boolean) - Filter by active status (default: true)
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20)

**Features:**
- Lists all active services by default
- Includes stylist information for each service
- Alphabetical ordering by service name
- Pagination with Kaminari

**Success Response (200 OK):**
```json
{
  "services": [
    {
      "id": 109,
      "name": "Beard Conditioning",
      "description": "Add-on service: Beard Conditioning",
      "price": 12.0,
      "price_cents": 1200,
      "active": true,
      "stylist": {
        "id": 21,
        "name": "Marco",
        "username": "marco_fades",
        "location": "Montreal",
        "avatar_url": null
      },
      "created_at": "2026-01-29T01:40:38.125Z",
      "updated_at": "2026-01-29T01:40:38.125Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 12,
    "total_count": 56,
    "per_page": 20
  }
}
```

**Example Requests:**
```bash
# Browse all active services
curl -X GET "http://localhost:3000/api/v1/services"

# Filter by stylist
curl -X GET "http://localhost:3000/api/v1/services?stylist_id=19"

# Include inactive services
curl -X GET "http://localhost:3000/api/v1/services?active=false"

# Pagination
curl -X GET "http://localhost:3000/api/v1/services?page=2&per_page=10"
```

---

#### 2. GET /api/v1/services/:id
**Purpose:** Show single service details
**Authorization:** None required (public endpoint)

**Success Response (200 OK):**
```json
{
  "service": {
    "id": 109,
    "name": "Beard Conditioning",
    "description": "Add-on service: Beard Conditioning",
    "price": 12.0,
    "price_cents": 1200,
    "active": true,
    "stylist": {
      "id": 21,
      "name": "Marco",
      "username": "marco_fades",
      "location": "Montreal",
      "avatar_url": null
    },
    "created_at": "2026-01-29T01:40:38.125Z",
    "updated_at": "2026-01-29T01:40:38.125Z"
  }
}
```

**Error Responses:**
- 404 Not Found - Service doesn't exist

**Example Request:**
```bash
curl -X GET "http://localhost:3000/api/v1/services/109"
```

---

## Part 2: Stylist Services Management API

All endpoints require:
- Authentication (JWT token)
- User must be a stylist (role: 'stylist')

### Endpoints

#### 1. GET /api/v1/stylist/services
**Purpose:** List all services for current stylist
**Query Parameters:**
- `active` (boolean) - Filter by active status
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 20)

**Features:**
- Shows only services where stylist_id = current_user.id
- Includes both active and inactive services
- Includes appointments_count for each service
- Ordered by created_at desc (newest first)
- Pagination

**Success Response (200 OK):**
```json
{
  "services": [
    {
      "id": 104,
      "name": "Bond Builder Treatment (Olaplex, K18)",
      "description": "Add-on service: Bond Builder Treatment",
      "price": 45.0,
      "price_cents": 4500,
      "active": true,
      "stylist": {
        "id": 19,
        "name": "Chico",
        "username": "chico_styles",
        "location": "Montreal",
        "avatar_url": null
      },
      "created_at": "2026-01-29T01:40:38.113Z",
      "updated_at": "2026-01-29T01:40:38.113Z",
      "appointments_count": 0
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 6,
    "total_count": 16,
    "per_page": 20
  }
}
```

**Example Requests:**
```bash
# View all services
curl -X GET "http://localhost:3000/api/v1/stylist/services" \
  -H "Authorization: Bearer STYLIST_TOKEN"

# View only active services
curl -X GET "http://localhost:3000/api/v1/stylist/services?active=true" \
  -H "Authorization: Bearer STYLIST_TOKEN"

# View inactive services
curl -X GET "http://localhost:3000/api/v1/stylist/services?active=false" \
  -H "Authorization: Bearer STYLIST_TOKEN"
```

---

#### 2. GET /api/v1/stylist/services/:id
**Purpose:** Show single service details
**Authorization:** Required - must be service owner

**Success Response (200 OK):**
```json
{
  "service": {
    "id": 113,
    "name": "Premium Haircut & Style",
    "description": "Includes consultation, cut, wash, and styling",
    "price": 85.0,
    "price_cents": 8500,
    "active": true,
    "stylist": {...},
    "created_at": "2026-01-29T23:34:10.372Z",
    "updated_at": "2026-01-29T23:34:10.372Z",
    "appointments_count": 0
  }
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not a stylist or service doesn't belong to user
- 404 Not Found - Service doesn't exist

**Example Request:**
```bash
curl -X GET "http://localhost:3000/api/v1/stylist/services/113" \
  -H "Authorization: Bearer STYLIST_TOKEN"
```

---

#### 3. POST /api/v1/stylist/services
**Purpose:** Create new service
**Request Body:**
```json
{
  "service": {
    "name": "Premium Haircut & Style",
    "description": "Includes consultation, cut, wash, and styling",
    "price_cents": 8500,
    "active": true
  }
}
```

**Fields:**
- `name` (required) - Service name
- `description` (optional) - Service description
- `price_cents` (required) - Price in cents (integer > 0)
- `active` (optional) - Active status (default: true)

**Logic:**
- Sets stylist_id to current_user.id automatically
- Validates price_cents > 0
- Validates name presence

**Success Response (201 Created):**
```json
{
  "service": {
    "id": 113,
    "name": "Premium Haircut & Style",
    "description": "Includes consultation, cut, wash, and styling",
    "price": 85.0,
    "price_cents": 8500,
    "active": true,
    "stylist": {...},
    "created_at": "2026-01-29T23:34:10.372Z",
    "updated_at": "2026-01-29T23:34:10.372Z",
    "appointments_count": 0
  },
  "message": "Service created successfully"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not a stylist
- 422 Unprocessable Entity - Validation errors

**Example Request:**
```bash
curl -X POST "http://localhost:3000/api/v1/stylist/services" \
  -H "Authorization: Bearer STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "name": "Premium Haircut",
      "description": "Professional haircut with styling",
      "price_cents": 8500,
      "active": true
    }
  }'
```

---

#### 4. PATCH /api/v1/stylist/services/:id
**Purpose:** Update existing service
**Request Body:**
```json
{
  "service": {
    "price_cents": 9500,
    "description": "Premium service with extra care"
  }
}
```

**Fields:** All fields are optional (only send what you want to update)
- `name` - Service name
- `description` - Service description
- `price_cents` - Price in cents
- `active` - Active status

**Success Response (200 OK):**
```json
{
  "service": {
    "id": 113,
    "name": "Premium Haircut & Style",
    "description": "Premium service with extra care",
    "price": 95.0,
    "price_cents": 9500,
    "active": true,
    "stylist": {...},
    "created_at": "2026-01-29T23:34:10.372Z",
    "updated_at": "2026-01-29T23:34:10.501Z",
    "appointments_count": 0
  },
  "message": "Service updated successfully"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not a stylist or service doesn't belong to user
- 404 Not Found - Service doesn't exist
- 422 Unprocessable Entity - Validation errors

**Example Request:**
```bash
curl -X PATCH "http://localhost:3000/api/v1/stylist/services/113" \
  -H "Authorization: Bearer STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "price_cents": 9500
    }
  }'
```

---

#### 5. DELETE /api/v1/stylist/services/:id
**Purpose:** Soft delete service (deactivate)
**Logic:**
- Sets `active = false` instead of destroying record
- If service has associated appointment_add_ons, prevents deletion
- Protects historical data

**Success Response (200 OK):**
```json
{
  "message": "Service deactivated successfully"
}
```

**Error Responses:**
- 401 Unauthorized - Not logged in
- 403 Forbidden - Not a stylist or service doesn't belong to user
- 404 Not Found - Service doesn't exist
- 422 Unprocessable Entity - Service has associated appointments

**Example Request:**
```bash
curl -X DELETE "http://localhost:3000/api/v1/stylist/services/113" \
  -H "Authorization: Bearer STYLIST_TOKEN"
```

---

## Routes Added

```ruby
# Public Services (no auth required)
GET    /api/v1/services           api/v1/services#index
GET    /api/v1/services/:id       api/v1/services#show

# Stylist Services Management (auth required, stylist only)
GET    /api/v1/stylist/services           api/v1/stylist/services#index
POST   /api/v1/stylist/services           api/v1/stylist/services#create
GET    /api/v1/stylist/services/:id       api/v1/stylist/services#show
PATCH  /api/v1/stylist/services/:id       api/v1/stylist/services#update
DELETE /api/v1/stylist/services/:id       api/v1/stylist/services#destroy
```

---

## Service Model

### Fields
- `name` - String (required)
- `description` - Text (optional)
- `price_cents` - Integer (required, > 0)
- `active` - Boolean (default: true)
- `stylist_id` - Foreign key to users table

### Helper Methods
```ruby
def price
  price_cents / 100.0
end

def price=(dollars)
  self.price_cents = (dollars.to_f * 100).round
end
```

### Associations
- `belongs_to :stylist, class_name: 'User'`
- `has_many :appointment_add_ons`

---

## Authorization Summary

### Public Services Controller
- ✅ No authentication required
- ✅ Anyone can browse services
- ✅ Anyone can view service details
- ✅ Only active services shown by default

### Stylist Services Controller
- ✅ Requires authentication for all endpoints
- ✅ User must have role: 'stylist'
- ✅ Stylists can only manage their own services (stylist_id = current_user.id)
- ✅ Soft delete prevents data loss
- ✅ Protects services with existing appointments

---

## Price Handling

**Storage:** All prices stored in cents (integer) to avoid floating-point rounding errors

**Input:** API accepts `price_cents` as integer
```json
{
  "price_cents": 8500  // $85.00
}
```

**Output:** API returns both formats
```json
{
  "price": 85.0,
  "price_cents": 8500
}
```

**Benefits:**
- No rounding errors in calculations
- Accurate totals for bookings
- Database-friendly (integer type)

---

## Testing

### Manual Testing

**Public Browsing:**
```bash
# Browse all services
curl -X GET "http://localhost:3000/api/v1/services"

# Filter by stylist
curl -X GET "http://localhost:3000/api/v1/services?stylist_id=19"

# View single service
curl -X GET "http://localhost:3000/api/v1/services/109"
```

**Stylist Management:**
```bash
# Login as stylist
STYLIST_TOKEN=$(curl -s -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"chico@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')

# View my services
curl -X GET "http://localhost:3000/api/v1/stylist/services" \
  -H "Authorization: $STYLIST_TOKEN"

# Create service
curl -X POST "http://localhost:3000/api/v1/stylist/services" \
  -H "Authorization: $STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "name": "Premium Cut",
      "price_cents": 8500
    }
  }'

# Update service
curl -X PATCH "http://localhost:3000/api/v1/stylist/services/113" \
  -H "Authorization: $STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"service":{"price_cents":9500}}'

# Deactivate service
curl -X DELETE "http://localhost:3000/api/v1/stylist/services/113" \
  -H "Authorization: $STYLIST_TOKEN"
```

---

## Files Created

1. **`app/controllers/api/v1/services_controller.rb`** (79 lines)
   - Public browsing of services
   - No authentication required
   - Filtering and pagination

2. **`app/controllers/api/v1/stylist/services_controller.rb`** (171 lines)
   - Full CRUD for stylist's services
   - Stylist-only access
   - Ownership enforcement
   - Soft delete protection

3. **Updated:** `config/routes.rb`
   - Added public services routes
   - Added stylist services routes

---

## Key Implementation Details

### Public Services Controller
- **No auth required:** Anyone can browse services for booking decisions
- **Active by default:** Only shows active services unless explicitly requested
- **Stylist info included:** Helps customers make informed decisions
- **Efficient queries:** Uses `.includes(:stylist)` to avoid N+1

### Stylist Services Controller
- **Role-based access:** Only stylists can manage services
- **Ownership enforcement:** Stylists can only manage their own services
- **Soft delete:** Prevents accidental data loss and maintains appointment history
- **Protection:** Can't delete services with existing appointments
- **Appointments count:** Shows how many times service has been used

---

## Business Logic

### Service Lifecycle
1. **Create:** Stylist creates service with price
2. **Active:** Service available for customers to book
3. **Update:** Stylist can modify price, description, etc.
4. **Deactivate:** Set active = false (soft delete)
5. **Protected:** Can't delete if used in appointments

### Price Management
- Stored in cents for accuracy
- Can be updated at any time
- Historical bookings preserve original price via AppointmentAddOn

---

## Next Steps

✅ **Completed:**
- Customer Appointments API
- Reviews API
- Stylist Appointments Management API
- Public Services Browsing API
- Stylist Services Management API

**Remaining:**
1. Stylists Browsing API:
   - GET /api/v1/stylists (list all stylists)
   - GET /api/v1/stylists/:id (stylist profile with services and reviews)

---

**API Status:** ✅ Services API Complete and Tested

Ready for React Native integration! 🚀
