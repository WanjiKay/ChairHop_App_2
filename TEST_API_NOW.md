# 🧪 API Authentication Testing Guide

**Copy and paste these commands to test your API!**

Server is running on: `http://localhost:3000`

---

## Test A: Register New Customer User

**Command:**
```bash
curl -i -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "testcustomer@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "Test Customer",
      "username": "testcustomer",
      "role": "customer",
      "location": "Montreal"
    }
  }'
```

**Expected Response:**
- Status: `HTTP/1.1 201 Created`
- Headers include: `Authorization: Bearer eyJhbGc...`
- Body contains: `"message": "Signed up successfully"`
- Body contains: `"role": "customer"`

**Verify:**
✓ Status is 201
✓ Authorization header present
✓ User email matches
✓ Role is "customer"

---

## Test B: Register New Stylist User

**Command:**
```bash
curl -i -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "teststylist@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "Test Stylist",
      "username": "teststylist",
      "role": "stylist",
      "location": "Laval"
    }
  }'
```

**Expected Response:**
- Status: `HTTP/1.1 201 Created`
- Headers include: `Authorization: Bearer eyJhbGc...`
- Body contains: `"role": "stylist"`

**Verify:**
✓ Status is 201
✓ Authorization header present
✓ Role is "stylist"

---

## Test C: Login as Customer

**Command:**
```bash
curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer1@example.com",
    "password": "password"
  }'
```

**Expected Response:**
- Status: `HTTP/1.1 200 OK`
- Headers include: `Authorization: Bearer eyJhbGc...`
- Body contains: `"message": "Logged in successfully"`
- Body contains: `"email": "customer1@example.com"`

**Verify:**
✓ Status is 200
✓ Token in Authorization header
✓ User data returned

**SAVE THE TOKEN** - you'll need it for next tests!

---

## Test D: Login as Stylist

**Command:**
```bash
curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "tilly@example.com",
    "password": "password"
  }'
```

**Expected Response:**
- Status: `HTTP/1.1 200 OK`
- Headers include: `Authorization: Bearer eyJhbGc...`
- Body contains: `"role": "stylist"`
- Body contains: `"email": "tilly@example.com"`

**Verify:**
✓ Status is 200
✓ Token in Authorization header
✓ Role is "stylist"

---

## Test E: Access Protected Endpoint WITH Valid Token

### Step 1: Login and capture token

**Command:**
```bash
TOKEN=$(curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer1@example.com","password":"password"}' \
  2>/dev/null | grep -i "Authorization:" | awk '{print $2}' | tr -d '\r')

echo "Token saved: $TOKEN"
```

**Expected Output:**
```
Token saved: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Step 2: Access profile endpoint with token

**Command:**
```bash
curl -i -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Response:**
- Status: `HTTP/1.1 200 OK`
- Body contains current user info:
```json
{
  "id": 5,
  "email": "customer1@example.com",
  "name": "Customer 1",
  "username": "customer1",
  "role": "customer",
  "location": "Montreal",
  "about": null,
  "avatar_url": null
}
```

**Verify:**
✓ Status is 200
✓ User data matches logged-in user
✓ Role is correct

---

## Test F: Access Protected Endpoint WITHOUT Token (Should Fail)

**Command:**
```bash
curl -i -X GET http://localhost:3000/api/v1/profile \
  -H "Content-Type: application/json"
```

**Expected Response:**
- Status: `HTTP/1.1 401 Unauthorized`
- Body contains error message about authentication

**Verify:**
✓ Status is 401
✓ Access denied
✓ Error message present

---

## Test G: Logout and Revoke Token

### Step 1: Logout

**Command:**
```bash
curl -i -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: $TOKEN"
```

**Expected Response:**
- Status: `HTTP/1.1 200 OK`
- Body contains: `"message": "Logged out successfully"`

**Verify:**
✓ Status is 200
✓ Success message returned

### Step 2: Try to use revoked token (should fail)

**Command:**
```bash
curl -i -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Response:**
- Status: `HTTP/1.1 401 Unauthorized`
- Token is revoked and no longer valid

**Verify:**
✓ Status is 401
✓ Revoked token rejected

---

## 🚀 Quick Test Script (Run All Tests at Once)

Copy and paste this entire block:

```bash
echo "🧪 ChairHop API Testing"
echo "======================="
echo ""

echo "✅ Test A: Register Customer"
RESPONSE_A=$(curl -s -i -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"quicktest1@example.com","password":"password123","password_confirmation":"password123","name":"Quick Test 1","username":"quicktest1","role":"customer"}}')
if echo "$RESPONSE_A" | grep -q "201 Created"; then
  echo "✅ Customer registration: PASSED"
else
  echo "❌ Customer registration: FAILED"
  echo "$RESPONSE_A" | head -20
fi
echo ""

echo "✅ Test B: Register Stylist"
RESPONSE_B=$(curl -s -i -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"quicktest2@example.com","password":"password123","password_confirmation":"password123","name":"Quick Test 2","username":"quicktest2","role":"stylist"}}')
if echo "$RESPONSE_B" | grep -q "201 Created"; then
  echo "✅ Stylist registration: PASSED"
else
  echo "❌ Stylist registration: FAILED"
fi
echo ""

echo "✅ Test C: Login as Customer"
RESPONSE_C=$(curl -s -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer1@example.com","password":"password"}')
if echo "$RESPONSE_C" | grep -q "200 OK"; then
  echo "✅ Customer login: PASSED"
  TOKEN=$(echo "$RESPONSE_C" | grep -i "Authorization:" | awk '{print $2}' | tr -d '\r')
  echo "   Token: ${TOKEN:0:50}..."
else
  echo "❌ Customer login: FAILED"
fi
echo ""

echo "✅ Test D: Login as Stylist"
RESPONSE_D=$(curl -s -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"tilly@example.com","password":"password"}')
if echo "$RESPONSE_D" | grep -q "200 OK"; then
  echo "✅ Stylist login: PASSED"
else
  echo "❌ Stylist login: FAILED"
fi
echo ""

echo "✅ Test E: Access Profile WITH Token"
RESPONSE_E=$(curl -s -i -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json")
if echo "$RESPONSE_E" | grep -q "200 OK"; then
  echo "✅ Authenticated request: PASSED"
  echo "$RESPONSE_E" | grep -A 20 "{"
else
  echo "❌ Authenticated request: FAILED"
fi
echo ""

echo "✅ Test F: Access Profile WITHOUT Token"
RESPONSE_F=$(curl -s -i -X GET http://localhost:3000/api/v1/profile \
  -H "Content-Type: application/json")
if echo "$RESPONSE_F" | grep -q "401"; then
  echo "✅ Unauthenticated request rejected: PASSED"
else
  echo "❌ Unauthenticated request should fail: FAILED"
fi
echo ""

echo "✅ Test G: Logout"
RESPONSE_G=$(curl -s -i -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: $TOKEN")
if echo "$RESPONSE_G" | grep -q "200 OK"; then
  echo "✅ Logout: PASSED"
else
  echo "❌ Logout: FAILED"
fi
echo ""

echo "✅ Test H: Revoked Token Rejected"
RESPONSE_H=$(curl -s -i -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json")
if echo "$RESPONSE_H" | grep -q "401"; then
  echo "✅ Revoked token rejected: PASSED"
else
  echo "❌ Revoked token should be rejected: FAILED"
fi
echo ""

echo "======================="
echo "🎉 Testing Complete!"
echo "======================="
```

---

## 🔍 Troubleshooting

### Issue: "Connection refused"
**Solution:** Make sure Rails server is running:
```bash
rails server
```

### Issue: "Devise secret key not configured"
**Solution:** Add to `.env`:
```bash
DEVISE_JWT_SECRET_KEY=e40b9df6bcc9ae585b8d62f0cc086165b67d3e1bdba8cb22081384f89ee1ecf21b7b5d1f6c3e63f9b8c68ff362f23071ea081ad1c0adadb9927239eae621d20c
```

Then restart server.

### Issue: Token not in response
**Solution:** Check the `-i` flag is included in curl (includes headers)

### Issue: Can't extract token
**Solution:** Manual extraction:
```bash
# Save response to file
curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer1@example.com","password":"password"}' > response.txt

# View file
cat response.txt

# Manually copy the token from Authorization header
```

---

## ✅ Expected Results Summary

| Test | Expected Status | Expected Behavior |
|------|----------------|-------------------|
| A - Register Customer | 201 Created | Token in header, role: customer |
| B - Register Stylist | 201 Created | Token in header, role: stylist |
| C - Login Customer | 200 OK | Token in header, user data |
| D - Login Stylist | 200 OK | Token in header, role: stylist |
| E - Auth Request (with token) | 200 OK | User profile returned |
| F - Auth Request (no token) | 401 Unauthorized | Access denied |
| G - Logout | 200 OK | Success message |
| H - Use revoked token | 401 Unauthorized | Token rejected |

---

## 📊 Database Verification

After running tests, verify data was created:

```bash
rails console
```

Then in console:
```ruby
# Count users
User.count

# Find test users
User.where("email LIKE ?", "%test%")

# Check JWT denylist
JwtDenylist.count
```

---

**Ready to test!** 🚀

Just copy the commands above and paste into your terminal!
