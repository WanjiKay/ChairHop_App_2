# ChairHop API Setup Documentation

## 🎉 API Foundation Complete!

Rails backend now has a complete JWT-authenticated API ready for React Native mobile apps.

---

## 🔐 JWT Secret Key Setup

Add this to your `.env` file (create it if it doesn't exist):

```bash
DEVISE_JWT_SECRET_KEY=e40b9df6bcc9ae585b8d62f0cc086165b67d3e1bdba8cb22081384f89ee1ecf21b7b5d1f6c3e63f9b8c68ff362f23071ea081ad1c0adadb9927239eae621d20c
```

**Important:** Never commit this secret to version control! Add `.env` to your `.gitignore`.

To generate a new secret key in the future, run:
```bash
rails secret
```

---

## 📍 API Endpoints

### Authentication

#### 1. **Sign Up (Register)**
- **POST** `/api/v1/signup`
- **Body:**
```json
{
  "user": {
    "email": "customer@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "John Doe",
    "username": "johndoe",
    "location": "Montreal",
    "role": "customer"
  }
}
```
- **Success Response (201):**
```json
{
  "message": "Signed up successfully",
  "user": {
    "id": 1,
    "email": "customer@example.com",
    "name": "John Doe",
    "username": "johndoe",
    "role": "customer",
    "location": "Montreal",
    "about": null,
    "avatar_url": null
  }
}
```
- **Response Headers:**
  - `Authorization: Bearer <JWT_TOKEN>`

---

#### 2. **Login**
- **POST** `/api/v1/login`
- **Body:**
```json
{
  "email": "customer@example.com",
  "password": "password123"
}
```
- **Success Response (200):**
```json
{
  "message": "Logged in successfully",
  "user": {
    "id": 1,
    "email": "customer@example.com",
    "name": "John Doe",
    "username": "johndoe",
    "role": "customer",
    "location": "Montreal",
    "about": null,
    "avatar_url": null
  }
}
```
- **Response Headers:**
  - `Authorization: Bearer <JWT_TOKEN>`

- **Error Response (401):**
```json
{
  "error": "Invalid email or password"
}
```

---

#### 3. **Logout**
- **DELETE** `/api/v1/logout`
- **Headers:**
  - `Authorization: Bearer <JWT_TOKEN>`
- **Success Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

## 🧪 Testing the API

### Using cURL

#### Sign Up:
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "name": "Test User",
      "username": "testuser",
      "role": "customer"
    }
  }' \
  -i
```

#### Login:
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }' \
  -i
```

The JWT token will be in the `Authorization` header of the response.

#### Logout:
```bash
curl -X DELETE http://localhost:3000/api/v1/logout \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -i
```

---

## 📱 React Native Integration

### Storing the Token

When you receive the JWT token from login/signup, store it securely:

```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';

// After successful login
const response = await fetch('http://localhost:3000/api/v1/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});

const data = await response.json();
const token = response.headers.get('Authorization');

// Store token
await AsyncStorage.setItem('authToken', token);
```

### Making Authenticated Requests

```javascript
const token = await AsyncStorage.getItem('authToken');

const response = await fetch('http://localhost:3000/api/v1/appointments', {
  method: 'GET',
  headers: {
    'Authorization': token,
    'Content-Type': 'application/json',
  }
});
```

---

## 🔧 What's Been Set Up

### 1. **API Base Controller** ([app/controllers/api/v1/base_controller.rb](app/controllers/api/v1/base_controller.rb))
- Inherits from `ActionController::API` (lightweight, no view rendering)
- Skips CSRF verification (not needed for API)
- Includes Pundit for authorization
- JSON error handling for unauthorized access and not found errors
- Helper methods for consistent JSON responses

### 2. **JWT Authentication**
- `devise-jwt` gem installed and configured
- JWT tokens expire after 30 days
- Revocation strategy using `JwtDenylist` model
- Tokens are automatically issued on login/signup
- Tokens are revoked on logout

### 3. **JWT Denylist Table**
- Tracks revoked tokens (logout functionality)
- Automatic cleanup of expired tokens
- Database table: `jwt_denylists` with `jti` (JWT ID) and `exp` (expiration)

### 4. **CORS Configuration** ([config/initializers/cors.rb](config/initializers/cors.rb))
- Allows requests from:
  - React Native Metro bundler: `http://localhost:8081`
  - Expo dev server: `http://localhost:19000`
  - Expo web: `http://localhost:19006`
  - Expo Go app: `exp://` scheme
- Configured for `/api/*` routes only
- Allows credentials (cookies/auth headers)
- Exposes `Authorization` header to clients

### 5. **User Roles**
- Already configured with enum: `customer`, `stylist`, `admin`
- New signups default to `customer` role
- Role returned in all authentication responses

---

## 🚀 Next Steps

### Create API Endpoints for Core Features:

1. **Appointments API** (`app/controllers/api/v1/appointments_controller.rb`)
   - GET `/api/v1/appointments` - List available appointments
   - GET `/api/v1/appointments/:id` - Show appointment details
   - POST `/api/v1/appointments/:id/book` - Book an appointment
   - DELETE `/api/v1/appointments/:id` - Cancel appointment
   - PATCH `/api/v1/appointments/:id/complete` - Mark as complete

2. **Profile API** (`app/controllers/api/v1/profiles_controller.rb`)
   - GET `/api/v1/profile` - Get current user profile
   - PATCH `/api/v1/profile` - Update profile
   - POST `/api/v1/profile/avatar` - Upload avatar

3. **Conversations API** (`app/controllers/api/v1/conversations_controller.rb`)
   - GET `/api/v1/conversations` - List conversations
   - GET `/api/v1/conversations/:id` - Show conversation
   - POST `/api/v1/conversations/:id/messages` - Send message

4. **Reviews API** (`app/controllers/api/v1/reviews_controller.rb`)
   - POST `/api/v1/appointments/:appointment_id/reviews` - Create review
   - GET `/api/v1/stylists/:id/reviews` - Get stylist reviews

---

## 🔒 Security Notes

1. **JWT Secret**: Keep your `DEVISE_JWT_SECRET_KEY` secure and never commit it
2. **HTTPS**: In production, always use HTTPS for API endpoints
3. **Token Expiration**: Tokens expire after 30 days - implement refresh logic in your app
4. **CORS**: Update CORS origins in production to only allow your deployed app domains
5. **Rate Limiting**: Consider adding `rack-attack` gem for rate limiting in production

---

## 🐛 Troubleshooting

### "JWT secret not configured" error
Make sure `DEVISE_JWT_SECRET_KEY` is set in your `.env` file and restart Rails server.

### CORS errors in React Native
1. Make sure your React Native dev server is running on one of the allowed origins
2. Check that you're making requests to `/api/v1/*` routes
3. Ensure the `Authorization` header is being sent with the token

### Token not being set
The JWT token is returned in the `Authorization` response header, not in the JSON body. Check your headers!

---

## 📚 Resources

- [Devise JWT Documentation](https://github.com/waiting-for-dev/devise-jwt)
- [Pundit Authorization](https://github.com/varvet/pundit)
- [Rails API Mode](https://guides.rubyonrails.org/api_app.html)
- [React Native AsyncStorage](https://react-native-async-storage.github.io/async-storage/)
