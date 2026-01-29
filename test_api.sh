#!/bin/bash
# Quick API Test Script
# Make this executable: chmod +x test_api.sh
# Run with: ./test_api.sh

echo "🚀 Testing ChairHop API..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000/api/v1"

echo "1️⃣  Testing Signup..."
SIGNUP_RESPONSE=$(curl -s -i -X POST $BASE_URL/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "apitest@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "API Test User",
      "username": "apitest",
      "role": "customer"
    }
  }')

if echo "$SIGNUP_RESPONSE" | grep -q "201 Created"; then
  echo -e "${GREEN}✓ Signup successful${NC}"
  TOKEN=$(echo "$SIGNUP_RESPONSE" | grep -i "Authorization:" | awk '{print $2}' | tr -d '\r')
  echo "Token: $TOKEN"
else
  echo -e "${RED}✗ Signup failed${NC}"
  echo "$SIGNUP_RESPONSE"
fi

echo ""
echo "2️⃣  Testing Login..."
LOGIN_RESPONSE=$(curl -s -i -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "apitest@example.com",
    "password": "password123"
  }')

if echo "$LOGIN_RESPONSE" | grep -q "200 OK"; then
  echo -e "${GREEN}✓ Login successful${NC}"
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -i "Authorization:" | awk '{print $2}' | tr -d '\r')
  echo "Token: $TOKEN"
else
  echo -e "${RED}✗ Login failed${NC}"
  echo "$LOGIN_RESPONSE"
fi

echo ""
echo "3️⃣  Testing Logout..."
LOGOUT_RESPONSE=$(curl -s -i -X DELETE $BASE_URL/logout \
  -H "Authorization: $TOKEN")

if echo "$LOGOUT_RESPONSE" | grep -q "200 OK"; then
  echo -e "${GREEN}✓ Logout successful${NC}"
else
  echo -e "${RED}✗ Logout failed${NC}"
  echo "$LOGOUT_RESPONSE"
fi

echo ""
echo "✅ API tests complete!"
