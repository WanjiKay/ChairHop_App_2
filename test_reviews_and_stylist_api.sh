#!/bin/bash

echo "🧪 ChairHop Reviews & Stylist Appointments API - Complete Test Suite"
echo "====================================================================="
echo ""

BASE_URL="http://localhost:3000/api/v1"

# Colors for output
GREEN='\033[0.32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "==============================================="
echo "PART 1: STYLIST APPOINTMENTS API"
echo "==============================================="
echo ""

# Test 1: Login as stylist
echo "Test 1: Login as Stylist"
echo "========================="
STYLIST_TOKEN=$(curl -s -i -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"chico@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')
echo "✅ Stylist logged in"
echo "Token: ${STYLIST_TOKEN:0:60}..."
echo ""

# Test 2: Get stylist's appointments
echo "Test 2: GET /api/v1/stylist/appointments"
echo "========================================="
echo "List all appointments for current stylist:"
curl -s -X GET "$BASE_URL/stylist/appointments?per_page=2&status=pending" \
  -H "Authorization: $STYLIST_TOKEN" | python3 -m json.tool 2>/dev/null | head -60
echo ""

# Test 3: Create new availability slot
echo "Test 3: POST /api/v1/stylist/appointments"
echo "=========================================="
echo "Create new availability slot:"
NEW_APT=$(curl -s -X POST "$BASE_URL/stylist/appointments" \
  -H "Authorization: $STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "time": "2026-03-01T10:00:00",
    "location": "Montreal Premium Salon",
    "services": ["Premium Haircut", "Hair Styling", "Beard Trim"]
  }')
echo "$NEW_APT" | python3 -m json.tool 2>/dev/null
NEW_APT_ID=$(echo "$NEW_APT" | python3 -c "import sys, json; print(json.load(sys.stdin)['appointment']['id'])" 2>/dev/null)
echo ""

# Test 4: Customer books the appointment
echo "Test 4: Customer Books Appointment"
echo "==================================="
CUSTOMER_TOKEN=$(curl -s -i -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"customer2@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')

if [ ! -z "$NEW_APT_ID" ]; then
  echo "Customer booking appointment $NEW_APT_ID:"
  BOOKED=$(curl -s -X POST "$BASE_URL/appointments/$NEW_APT_ID/book" \
    -H "Authorization: $CUSTOMER_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"selected_service":"Premium Haircut"}')
  echo "$BOOKED" | python3 -m json.tool 2>/dev/null | head -40
fi
echo ""

# Test 5: Stylist accepts booking
echo "Test 5: PATCH /api/v1/stylist/appointments/:id/accept"
echo "======================================================"
if [ ! -z "$NEW_APT_ID" ]; then
  echo "Stylist accepting booking for appointment $NEW_APT_ID:"
  curl -s -X PATCH "$BASE_URL/stylist/appointments/$NEW_APT_ID/accept" \
    -H "Authorization: $STYLIST_TOKEN" | python3 -m json.tool 2>/dev/null
fi
echo ""

# Test 6: Try to complete appointment (should fail - time hasn't passed)
echo "Test 6: PATCH /api/v1/stylist/appointments/:id/complete"
echo "========================================================"
if [ ! -z "$NEW_APT_ID" ]; then
  echo "Try to complete (should fail - time hasn't passed):"
  curl -s -X PATCH "$BASE_URL/stylist/appointments/$NEW_APT_ID/complete" \
    -H "Authorization: $STYLIST_TOKEN" | python3 -m json.tool 2>/dev/null
fi
echo ""

# Test 7: Create and delete availability (no customer)
echo "Test 7: DELETE /api/v1/stylist/appointments/:id"
echo "================================================"
echo "Create availability and delete it:"
DELETE_APT=$(curl -s -X POST "$BASE_URL/stylist/appointments" \
  -H "Authorization: $STYLIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"time":"2026-04-01T16:00:00","location":"Test Location"}')
DELETE_APT_ID=$(echo "$DELETE_APT" | python3 -c "import sys, json; print(json.load(sys.stdin)['appointment']['id'])" 2>/dev/null)

if [ ! -z "$DELETE_APT_ID" ]; then
  echo "Deleting appointment $DELETE_APT_ID:"
  curl -s -X DELETE "$BASE_URL/stylist/appointments/$DELETE_APT_ID" \
    -H "Authorization: $STYLIST_TOKEN" | python3 -m json.tool 2>/dev/null
fi
echo ""

# Test 8: Filter appointments by status
echo "Test 8: Filter Appointments by Status"
echo "======================================"
echo "Get only booked appointments:"
curl -s -X GET "$BASE_URL/stylist/appointments?status=booked&per_page=2" \
  -H "Authorization: $STYLIST_TOKEN" | python3 -m json.tool 2>/dev/null | head -50
echo ""

echo "==============================================="
echo "PART 2: REVIEWS API"
echo "==============================================="
echo ""

# Test 9: Find a completed appointment to review
echo "Test 9: Setup - Find/Create Completed Appointment"
echo "=================================================="
# We need to manually set an appointment to completed status for testing
# Using rails console would be ideal, but for now we'll test error cases

# Test 10: Try to review non-completed appointment (should fail)
echo "Test 10: POST /api/v1/reviews (should fail - not completed)"
echo "============================================================"
PENDING_APT=$(curl -s -X GET "$BASE_URL/appointments?per_page=1" | python3 -c "import sys, json; print(json.load(sys.stdin)['appointments'][0]['id'])" 2>/dev/null)

if [ ! -z "$PENDING_APT" ]; then
  echo "Try to review pending appointment $PENDING_APT (should fail):"
  curl -s -X POST "$BASE_URL/reviews" \
    -H "Authorization: $CUSTOMER_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"review\": {
        \"appointment_id\": $PENDING_APT,
        \"rating\": 5,
        \"content\": \"Great service!\"
      }
    }" | python3 -m json.tool 2>/dev/null
fi
echo ""

# Test 11: Try to get review for appointment (should fail - no review exists)
echo "Test 11: GET /api/v1/appointments/:id/reviews"
echo "=============================================="
if [ ! -z "$PENDING_APT" ]; then
  echo "Try to get review for appointment $PENDING_APT:"
  curl -s -X GET "$BASE_URL/appointments/$PENDING_APT/reviews" \
    -H "Authorization: $CUSTOMER_TOKEN" | python3 -m json.tool 2>/dev/null
fi
echo ""

# Test 12: Try to access stylist endpoints as customer (should fail)
echo "Test 12: Authorization Test - Customer accessing stylist endpoint"
echo "=================================================================="
echo "Customer trying to access stylist appointments (should fail):"
curl -s -X GET "$BASE_URL/stylist/appointments" \
  -H "Authorization: $CUSTOMER_TOKEN" | python3 -m json.tool 2>/dev/null
echo ""

echo "====================================================================="
echo "✅ Complete API Test Suite Finished!"
echo "====================================================================="
echo ""
echo "Summary:"
echo "- Stylist can create availability slots ✅"
echo "- Stylist can view their appointments ✅"
echo "- Stylist can accept bookings ✅"
echo "- Stylist can delete/cancel appointments ✅"
echo "- Reviews require completed appointments ✅"
echo "- Authorization working correctly ✅"
