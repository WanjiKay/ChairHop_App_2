# 🎉 API Authentication Test Results

**Date:** January 28, 2026
**Status:** ✅ ALL TESTS PASSING

---

## Test Summary

| Test | Endpoint | Status |
|------|----------|--------|
| A | POST /api/v1/signup (customer) | ✅ PASSED |
| B | POST /api/v1/signup (stylist) | ✅ PASSED |
| C | POST /api/v1/login (customer) | ✅ PASSED |
| D | POST /api/v1/login (stylist) | ✅ PASSED |
| E | GET /api/v1/profile (with token) | ✅ PASSED |
| F | GET /api/v1/profile (no token) | ✅ PASSED |
| G | DELETE /api/v1/logout | ✅ PASSED |
| H | Revoked token rejection | ✅ PASSED |

---

## Issues Fixed During Testing

### Issue 1: 404 Errors on API Routes
**Problem:** All API endpoints were returning 404 Not Found
**Cause:** API authentication routes needed to be wrapped in `devise_scope :user` block
**Fix:** Updated `config/routes.rb`:
```ruby
devise_scope :user do
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  post 'signup', to: 'registrations#create'
end
```

### Issue 2: CSRF Token Verification Errors
**Problem:** API endpoints returning 422 Unprocessable Content with CSRF errors
**Cause:** Devise controllers have CSRF protection enabled by default
**Fix:** Added to both SessionsController and RegistrationsController:
```ruby
skip_before_action :verify_authenticity_token
```

### Issue 3: JWT Authentication Not Working
**Problem:** Profile endpoint redirecting to login page (302) or returning 401
**Cause:** Default `authenticate_user!` uses session-based auth, not JWT
**Fix:** Implemented custom JWT authentication in `api/v1/base_controller.rb`:
```ruby
def authenticate_api_user!
  token = request.headers['Authorization']&.split(' ')&.last
  # ... JWT decode and validation logic
end
```

### Issue 4: Missing JWT Secret Key
**Problem:** JWT tokens couldn't be decoded
**Cause:** DEVISE_JWT_SECRET_KEY not set in environment
**Fix:** Added to `.env`:
```
DEVISE_JWT_SECRET_KEY=e40b9df6bcc9ae585b8d62f0cc086165b67d3e1bdba8cb22081384f89ee1ecf21b7b5d1f6c3e63f9b8c68ff362f23071ea081ad1c0adadb9927239eae621d20c
```

---

## Working API Endpoints

### Authentication Endpoints

#### 1. Sign Up (Register New User)
```bash
curl -i -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "Test User",
      "username": "testuser",
      "role": "customer",
      "location": "Montreal"
    }
  }'
```

**Response:** 201 Created
- Returns JWT token in `Authorization` header
- Returns user data in JSON body

#### 2. Login
```bash
curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer1@example.com",
    "password": "password"
  }'
```

**Response:** 200 OK
- Returns JWT token in `Authorization` header
- Returns user data in JSON body

#### 3. Get Profile (Authenticated)
```bash
TOKEN="Bearer <your-token-here>"
curl -i -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json"
```

**Response:** 200 OK
```json
{
  "id": 22,
  "email": "customer1@example.com",
  "name": "Customer 1",
  "username": "customer1",
  "role": "customer",
  "location": "Longueuil",
  "about": null,
  "avatar_url": null
}
```

#### 4. Logout
```bash
curl -i -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: $TOKEN"
```

**Response:** 200 OK
- Revokes JWT token (adds to denylist)

---

## Quick Test Script

Copy and paste this to run all tests:

```bash
#!/bin/bash

echo "🧪 ChairHop API Test Suite"
echo "=========================="

# Test 1: Signup
echo "Test 1: Signup"
curl -s -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123","password_confirmation":"password123","name":"Test","username":"test","role":"customer"}}' | python3 -m json.tool

# Test 2: Login and capture token
echo -e "\nTest 2: Login"
TOKEN=$(curl -s -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer1@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')
echo "Token: ${TOKEN:0:70}..."

# Test 3: Access profile with token
echo -e "\nTest 3: Profile (authenticated)"
curl -s -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN" | python3 -m json.tool

# Test 4: Access profile without token
echo -e "\nTest 4: Profile (unauthenticated - should fail)"
curl -s -X GET http://localhost:3000/api/v1/profile | python3 -m json.tool

# Test 5: Logout
echo -e "\nTest 5: Logout"
curl -s -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: $TOKEN" | python3 -m json.tool

# Test 6: Try revoked token
echo -e "\nTest 6: Revoked token (should fail)"
curl -s -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN" | python3 -m json.tool

echo -e "\n=========================="
echo "✅ Test Suite Complete"
```

---

## Files Modified

1. **config/routes.rb** - Added `devise_scope :user` wrapper
2. **app/controllers/api/v1/sessions_controller.rb** - Added `skip_before_action :verify_authenticity_token`
3. **app/controllers/api/v1/registrations_controller.rb** - Added `skip_before_action :verify_authenticity_token`
4. **app/controllers/api/v1/base_controller.rb** - Implemented custom JWT authentication
5. **.env** - Added `DEVISE_JWT_SECRET_KEY`

---

## Next Steps

With authentication working, you can now:

1. ✅ Build customer API endpoints (appointments, booking, services)
2. ✅ Build stylist API endpoints (dashboard, availability, services management)
3. ✅ Initialize React Native projects and test integration
4. ✅ Add more protected endpoints following the same pattern

---

**Ready for Day 2 development!** 🚀
