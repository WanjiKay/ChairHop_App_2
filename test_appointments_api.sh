#!/bin/bash

echo "🧪 ChairHop Appointments API - Complete Test Suite"
echo "==================================================="
echo ""

BASE_URL="http://localhost:3000/api/v1"

# Colors for output
GREEN='\033[0.32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: List available appointments (no auth required)
echo "Test 1: GET /api/v1/appointments"
echo "================================="
echo "List all available appointments (status: pending):"
RESPONSE=$(curl -s -X GET "$BASE_URL/appointments?per_page=3")
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null
echo ""

# Test 2: Filter appointments by location
echo "Test 2: GET /api/v1/appointments?location=Laval"
echo "================================================"
curl -s -X GET "$BASE_URL/appointments?location=210%20Boulevard%20des%20Laurentides%2C%20Laval&per_page=2" | python3 -m json.tool 2>/dev/null
echo ""

# Test 3: Get single appointment (no auth required for pending)
FIRST_ID=$(curl -s -X GET "$BASE_URL/appointments?per_page=1" | python3 -c "import sys, json; print(json.load(sys.stdin)['appointments'][0]['id'])" 2>/dev/null)
echo "Test 3: GET /api/v1/appointments/$FIRST_ID"
echo "==========================================="
curl -s -X GET "$BASE_URL/appointments/$FIRST_ID" | python3 -m json.tool 2>/dev/null
echo ""

# Test 4: Login as customer
echo "Test 4: POST /api/v1/login (customer)"
echo "====================================="
TOKEN=$(curl -s -i -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"customer1@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')
echo "Token: ${TOKEN:0:70}..."
echo ""

# Test 5: Get my appointments (empty for customer1)
echo "Test 5: GET /api/v1/appointments/my_appointments"
echo "================================================="
curl -s -X GET "$BASE_URL/appointments/my_appointments" \
  -H "Authorization: $TOKEN" | python3 -m json.tool 2>/dev/null
echo ""

# Test 6: Book an appointment
echo "Test 6: POST /api/v1/appointments/$FIRST_ID/book"
echo "================================================="
echo "Booking appointment $FIRST_ID..."

# First, get available services for this stylist
STYLIST_ID=$(curl -s -X GET "$BASE_URL/appointments/$FIRST_ID" | python3 -c "import sys, json; print(json.load(sys.stdin)['appointment']['stylist']['id'])" 2>/dev/null)

# Get services for this stylist
SERVICE_IDS=$(rails runner "puts Service.where(stylist_id: $STYLIST_ID).limit(2).pluck(:id).join(',')" 2>/dev/null)

# Book the appointment
BOOK_RESPONSE=$(curl -s -X POST "$BASE_URL/appointments/$FIRST_ID/book" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"selected_service\":\"Haircut\",\"add_on_ids\":[$SERVICE_IDS]}")
echo "$BOOK_RESPONSE" | python3 -m json.tool 2>/dev/null
echo ""

# Test 7: Get my appointments again (should show the booked appointment)
echo "Test 7: GET /api/v1/appointments/my_appointments (after booking)"
echo "================================================================="
curl -s -X GET "$BASE_URL/appointments/my_appointments" \
  -H "Authorization: $TOKEN" | python3 -m json.tool 2>/dev/null | head -80
echo ""

# Test 8: Try to book already booked appointment (should fail)
echo "Test 8: POST /api/v1/appointments/$FIRST_ID/book (should fail - already booked)"
echo "================================================================================"
TOKEN2=$(curl -s -i -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"customer2@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')

FAIL_RESPONSE=$(curl -s -X POST "$BASE_URL/appointments/$FIRST_ID/book" \
  -H "Authorization: $TOKEN2" \
  -H "Content-Type: application/json" \
  -d '{"selected_service":"Haircut"}')
echo "$FAIL_RESPONSE" | python3 -m json.tool 2>/dev/null
echo ""

# Test 9: Login as stylist and view my appointments
echo "Test 9: Login as stylist and view appointments"
echo "==============================================="
STYLIST_TOKEN=$(curl -s -i -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"chico@example.com","password":"password"}' | \
  grep -i "authorization:" | sed 's/authorization: //i' | tr -d '\r')

echo "Stylist appointments:"
curl -s -X GET "$BASE_URL/appointments/my_appointments" \
  -H "Authorization: $STYLIST_TOKEN" | python3 -m json.tool 2>/dev/null | head -80
echo ""

echo "==================================================="
echo "✅ Complete API Test Suite Finished!"
echo "==================================================="
