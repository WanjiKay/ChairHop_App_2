# ChairHop API Testing Guide

Complete guide for testing the ChairHop API using cURL, Postman, or React Native.

---

## 🚀 Quick Start

### Prerequisites
1. Rails server running: `rails server`
2. API base URL: `http://localhost:3000/api/v1`
3. JWT secret configured in `.env`

### Test Accounts (from seeds)
- **Customer:** customer1@example.com / password
- **Stylist:** tilly@example.com / password

---

## 🧪 Testing with cURL

### 1. Register a New Customer

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "newcustomer@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "Jane Doe",
      "username": "janedoe",
      "location": "Montreal",
      "role": "customer"
    }
  }' \
  -i
```

**Expected Response (201 Created):**
```http
HTTP/1.1 201 Created
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxNSIsInNjcCI6InVzZXIiLCJhdWQiOm51bGwsImlhdCI6MTczODEyMzQ1NiwiZXhwIjoxNzQwNzE1NDU2LCJqdGkiOiIxMjM0NTY3ODkwIn0.abcdef...

{
  "message": "Signed up successfully",
  "user": {
    "id": 15,
    "email": "newcustomer@example.com",
    "name": "Jane Doe",
    "username": "janedoe",
    "role": "customer",
    "location": "Montreal",
    "about": null,
    "avatar_url": null
  }
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "error": "Signup failed",
  "errors": [
    "Email has already been taken",
    "Password confirmation doesn't match Password"
  ]
}
```

---

### 2. Register a New Stylist

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "newstylist@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "Alex Smith",
      "username": "alexstylist",
      "location": "Laval",
      "role": "stylist"
    }
  }' \
  -i
```

**Expected Response (201 Created):**
```json
{
  "message": "Signed up successfully",
  "user": {
    "id": 16,
    "email": "newstylist@example.com",
    "name": "Alex Smith",
    "username": "alexstylist",
    "role": "stylist",
    "location": "Laval",
    "about": null,
    "avatar_url": null
  }
}
```

**Important Notes:**
- JWT token is in the `Authorization` response header, NOT in the JSON body
- Token format: `Bearer <token>`
- Save this token for authenticated requests

---

### 3. Login with Existing Account

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer1@example.com",
    "password": "password"
  }' \
  -i
```

**Expected Response (200 OK):**
```http
HTTP/1.1 200 OK
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "message": "Logged in successfully",
  "user": {
    "id": 5,
    "email": "customer1@example.com",
    "name": "Customer 1",
    "username": "customer1",
    "role": "customer",
    "location": "Montreal",
    "about": null,
    "avatar_url": null
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Invalid email or password"
}
```

---

### 4. Extract and Store JWT Token

**From cURL response:**
```bash
# Save full response to file
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email": "customer1@example.com", "password": "password"}' \
  -i > response.txt

# Extract token from Authorization header
TOKEN=$(grep "Authorization:" response.txt | awk '{print $2}' | tr -d '\r')
echo $TOKEN
```

**Or capture directly:**
```bash
# Capture response headers
RESPONSE=$(curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email": "customer1@example.com", "password": "password"}')

# Extract token
TOKEN=$(echo "$RESPONSE" | grep -i "Authorization:" | awk '{print $2}' | tr -d '\r')
echo "Token: $TOKEN"
```

---

### 5. Access Protected Endpoint with Token

**Example: Get User Profile (Future Endpoint)**
```bash
curl -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**Example: List My Appointments (Future Endpoint)**
```bash
curl -X GET http://localhost:3000/api/v1/my_appointments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Success Response (200 OK):**
```json
{
  "appointments": [
    {
      "id": 1,
      "time": "2026-01-30T10:00:00.000Z",
      "location": "1450 St-Catherine St W, Montreal",
      "status": "booked",
      "stylist": {
        "id": 1,
        "name": "Tilly",
        "username": "tilly_browslocks"
      }
    }
  ]
}
```

**Error Response - Unauthorized (401):**
```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

**Error Response - Invalid Token (401):**
```json
{
  "error": "Invalid or expired token"
}
```

---

### 6. Logout and Revoke Token

**Request:**
```bash
curl -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: Bearer $TOKEN" \
  -i
```

**Expected Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

**After Logout:**
- Token is added to JwtDenylist
- Token can no longer be used for authentication
- Subsequent requests with this token will return 401 Unauthorized

---

## 📮 Testing with Postman

### 1. Setup Postman Environment

**Create Environment Variables:**
1. Open Postman → Environments → Create
2. Name: "ChairHop Development"
3. Add variables:
   - `base_url`: `http://localhost:3000/api/v1`
   - `token`: (leave empty, will be set automatically)

### 2. Create Signup Request

**Method:** `POST`
**URL:** `{{base_url}}/signup`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "user": {
    "email": "postman@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "Postman Test",
    "username": "postmantest",
    "role": "customer"
  }
}
```

**Tests Tab (Auto-save token):**
```javascript
// Save token from Authorization header
if (pm.response.headers.get("Authorization")) {
    const token = pm.response.headers.get("Authorization");
    pm.environment.set("token", token);
    console.log("Token saved:", token);
}

// Verify response
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

pm.test("User created successfully", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.message).to.eql("Signed up successfully");
    pm.expect(jsonData.user.email).to.exist;
});
```

### 3. Create Login Request

**Method:** `POST`
**URL:** `{{base_url}}/login`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "email": "customer1@example.com",
  "password": "password"
}
```

**Tests Tab:**
```javascript
// Save token from Authorization header
if (pm.response.headers.get("Authorization")) {
    const token = pm.response.headers.get("Authorization");
    pm.environment.set("token", token);
    console.log("Token saved:", token);
}

pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Logged in successfully", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.message).to.eql("Logged in successfully");
});
```

### 4. Create Authenticated Request

**Method:** `GET`
**URL:** `{{base_url}}/profile`

**Headers:**
```
Content-Type: application/json
Authorization: {{token}}
```

**Pre-request Script (Optional - Check token exists):**
```javascript
if (!pm.environment.get("token")) {
    console.error("No token found! Please login first.");
}
```

### 5. Create Logout Request

**Method:** `DELETE`
**URL:** `{{base_url}}/logout`

**Headers:**
```
Authorization: {{token}}
```

**Tests Tab:**
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Clear token from environment
pm.environment.unset("token");
console.log("Token cleared from environment");
```

---

## 📱 Testing from React Native

### 1. Setup API Client

**Create `src/services/api.js`:**
```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';

const API_URL = 'http://localhost:3000/api/v1';

// Create axios instance
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add token
api.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = token;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to save token
api.interceptors.response.use(
  async (response) => {
    // Save token from Authorization header
    const token = response.headers.authorization;
    if (token) {
      await AsyncStorage.setItem('authToken', token);
    }
    return response;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default api;
```

### 2. Authentication Service

**Create `src/services/auth.js`:**
```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';
import api from './api';

export const authService = {
  // Sign up
  async signup(userData) {
    try {
      const response = await api.post('/signup', {
        user: userData,
      });
      return {
        success: true,
        user: response.data.user,
        message: response.data.message,
      };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.error || 'Signup failed',
        errors: error.response?.data?.errors || [],
      };
    }
  },

  // Login
  async login(email, password) {
    try {
      const response = await api.post('/login', {
        email,
        password,
      });
      return {
        success: true,
        user: response.data.user,
        message: response.data.message,
      };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.error || 'Login failed',
      };
    }
  },

  // Logout
  async logout() {
    try {
      await api.delete('/logout');
      await AsyncStorage.removeItem('authToken');
      return { success: true };
    } catch (error) {
      // Still remove token even if API call fails
      await AsyncStorage.removeItem('authToken');
      return { success: true };
    }
  },

  // Check if user is authenticated
  async isAuthenticated() {
    const token = await AsyncStorage.getItem('authToken');
    return !!token;
  },

  // Get current token
  async getToken() {
    return await AsyncStorage.getItem('authToken');
  },
};
```

### 3. Example Usage in Component

**Signup Component:**
```javascript
import React, { useState } from 'react';
import { View, TextInput, Button, Text } from 'react-native';
import { authService } from '../services/auth';

export default function SignupScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState('');

  const handleSignup = async () => {
    const result = await authService.signup({
      email,
      password,
      password_confirmation: passwordConfirmation,
      name,
      role: 'customer',
    });

    if (result.success) {
      navigation.navigate('Home');
    } else {
      setError(result.error);
    }
  };

  return (
    <View>
      <TextInput
        placeholder="Name"
        value={name}
        onChangeText={setName}
      />
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
      />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      <TextInput
        placeholder="Confirm Password"
        value={passwordConfirmation}
        onChangeText={setPasswordConfirmation}
        secureTextEntry
      />
      {error ? <Text style={{ color: 'red' }}>{error}</Text> : null}
      <Button title="Sign Up" onPress={handleSignup} />
    </View>
  );
}
```

**Login Component:**
```javascript
import React, { useState } from 'react';
import { View, TextInput, Button, Text } from 'react-native';
import { authService } from '../services/auth';

export default function LoginScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = async () => {
    const result = await authService.login(email, password);

    if (result.success) {
      navigation.navigate('Home');
    } else {
      setError(result.error);
    }
  };

  return (
    <View>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
      />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      {error ? <Text style={{ color: 'red' }}>{error}</Text> : null}
      <Button title="Login" onPress={handleLogin} />
    </View>
  );
}
```

---

## 🔍 Common Issues & Solutions

### Issue 1: "Revoked token" error after logout

**Problem:** Token is in JwtDenylist but still being sent
**Solution:** Clear token from AsyncStorage
```javascript
await AsyncStorage.removeItem('authToken');
```

### Issue 2: Token not being saved

**Problem:** Authorization header not detected
**Solution:** Check header name is exact: `Authorization` (capital A)
```javascript
// Correct
const token = response.headers.authorization;

// Wrong
const token = response.headers.Authorization;
```

### Issue 3: CORS errors in React Native

**Problem:** CORS blocking requests from mobile
**Solution:** Check CORS configuration in `config/initializers/cors.rb`

For development on device (not simulator):
```ruby
# Add your computer's IP address
origins 'http://192.168.1.XXX:8081'
```

### Issue 4: "Devise secret key not configured"

**Problem:** Missing JWT secret in environment
**Solution:** Add to `.env`:
```bash
DEVISE_JWT_SECRET_KEY=your_secret_key_here
```

Then restart Rails server.

### Issue 5: Token expires too quickly

**Problem:** 30-day expiration too long/short
**Solution:** Adjust in `config/initializers/devise.rb`:
```ruby
jwt.expiration_time = 7.days.to_i  # Change to desired duration
```

---

## 📊 Testing Checklist

Use this checklist to verify authentication is working:

- [ ] **Signup as Customer**
  - [ ] Valid data returns 201
  - [ ] Token in Authorization header
  - [ ] User data in response body
  - [ ] Invalid data returns 422 with errors

- [ ] **Signup as Stylist**
  - [ ] Role set to "stylist"
  - [ ] Token issued successfully

- [ ] **Login**
  - [ ] Valid credentials return 200
  - [ ] Token in Authorization header
  - [ ] Invalid credentials return 401

- [ ] **Authenticated Requests**
  - [ ] Token in Authorization header works
  - [ ] Missing token returns 401
  - [ ] Invalid token returns 401

- [ ] **Logout**
  - [ ] Returns 200 OK
  - [ ] Token added to JwtDenylist
  - [ ] Revoked token no longer works

- [ ] **Token Persistence**
  - [ ] Token saved in AsyncStorage
  - [ ] Token persists across app restarts
  - [ ] Token cleared on logout

---

## 🚀 Automated Testing Script

**Run All Tests:**
```bash
./test_api.sh
```

**Manual Test Sequence:**
```bash
# 1. Signup
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123","password_confirmation":"password123","name":"Test User","role":"customer"}}' \
  -i

# 2. Login and save token
TOKEN=$(curl -i -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  | grep -i "Authorization:" | awk '{print $2}' | tr -d '\r')

# 3. Test authenticated endpoint (when available)
curl -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN"

# 4. Logout
curl -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: $TOKEN"

# 5. Try to use revoked token (should fail)
curl -X GET http://localhost:3000/api/v1/profile \
  -H "Authorization: $TOKEN"
```

---

## 📖 Additional Resources

- **API Documentation:** See [API_SETUP.md](API_SETUP.md)
- **Postman Collection:** Import collection from `postman/ChairHop.postman_collection.json` (to be created)
- **React Native Guide:** See [API_SETUP.md#react-native-integration](API_SETUP.md#react-native-integration)

---

**Last Updated:** January 29, 2026
**API Version:** v1
