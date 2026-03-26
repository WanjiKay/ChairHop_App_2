# ChairHop - Hair Salon Booking Platform

**Launch Date:** March 16, 2026
**Environment:** Development (Sandbox testing)
**Tech Stack:** Rails 7.1 (API-only) + Web Frontend

---

## Project Overview

ChairHop is a comprehensive hair salon booking and payment management platform connecting customers with hair stylists. The platform serves the Quebec market with full regulatory compliance including Canadian GST/HST tax requirements.

---

## Implemented Features

### **Authentication & Authorization**
- User registration/login (Devise + JWT)
- Role-based access control (Customer, Stylist, Admin)
- Profile management with avatars (Cloudinary)
- Structured address fields (street, city, province, postal code)

### **Stylist Features**
- Dashboard with statistics (earnings, bookings, reviews)
- Service management (CRUD operations)
- Location management (multiple business locations)
- Availability creation (open time slots)
- Appointment management (view, accept, decline, complete)
- Review viewing and management

### **Customer Features**
- Stylist discovery (browse, search, filter by service)
- Stylist profile viewing (services, ratings, reviews, about)
- Appointment booking with add-ons
- My appointments view (upcoming/past)
- Review system (rate and review after appointments)
- In-app messaging (polling-based chat with stylists)

### **Payment Processing**
- Square integration for payment processing
- Service pricing with add-ons
- Payment on booking
- Canadian tax calculation (GST/HST)

### **QuickBooks Integration**
- OAuth connection (manual token entry)
- Automatic customer sync to QuickBooks
- Invoice creation when appointments complete
- Canadian tax inclusion (GST/HST)
- Background job processing
- Payment recording capability

### **Core Features**
- Mobile responsive design (Bootstrap)
- Image uploads (Cloudinary)
- Calendar functionality
- Search and filtering

---

## Getting Started

### **Prerequisites**
- Ruby 3.3.5
- Rails 7.1.6
- PostgreSQL
- Node.js (for asset pipeline)

### **Installation**

1. Clone the repository:
```bash
git clone [repository-url]
cd ChairHop_App_2
```

2. Install dependencies:
```bash
bundle install
```

3. Set up database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Copy environment variables template and fill in values:
```bash
cp .env.example .env
# Edit .env with your credentials (ask team lead for values)
```

5. Start the server:
```bash
rails s
```

6. Access at: `http://localhost:3000`

---

## Credentials & API Keys

All sensitive credentials are stored in `.env` (NOT committed to git). Ask the team lead for the actual values.

### **Square Payment (Sandbox)**
```
SQUARE_SANDBOX_ACCESS_TOKEN=<see .env>
SQUARE_LOCATION_ID=<see .env>
```
- Test card: `4111 1111 1111 1111`, CVV: any 3 digits, Expiry: any future date
- Sandbox dashboard: https://developer.squareup.com/

### **QuickBooks (Sandbox)**
```
QUICKBOOKS_CLIENT_ID=<see .env>
QUICKBOOKS_CLIENT_SECRET=<see .env>
QUICKBOOKS_ENVIRONMENT=sandbox
```
- Developer portal: https://developer.intuit.com/
- Sandbox company: "ChairHop Test Salon"
- OAuth Playground: https://developer.intuit.com/app/developer/playground

### **Cloudinary (Image Uploads)**
```
CLOUDINARY_CLOUD_NAME=<see .env>
CLOUDINARY_API_KEY=<see .env>
CLOUDINARY_API_SECRET=<see .env>
```

### **Devise JWT**
```
DEVISE_JWT_SECRET_KEY=<see .env>
```

---

## Testing Guide

### **Test User Accounts**

**Stylist Account:**
- Email: `tilly@example.com`
- Password: `password123`

**Customer Account:**
- Email: `customer@example.com`
- Password: `password123`

### **Feature Testing Checklist**

#### **1. Authentication & Profiles (2 hours)**
- [ ] Sign up as customer
- [ ] Sign up as stylist
- [ ] Edit profile (both roles)
- [ ] Upload avatar
- [ ] Update address
- [ ] Sign out/sign in

#### **2. Stylist Features (3 hours)**
- [ ] Create/edit/delete services
- [ ] Add/manage locations
- [ ] Create availability slots
- [ ] View appointment requests
- [ ] Accept/decline bookings
- [ ] Mark appointments complete
- [ ] View dashboard stats

#### **3. Customer Booking Flow (3 hours)**
- [ ] Browse stylists
- [ ] Search/filter stylists
- [ ] View stylist profile
- [ ] Book appointment
- [ ] Add add-ons
- [ ] Complete payment (Square)
- [ ] View my appointments
- [ ] Leave review

#### **4. Messaging & Reviews (2 hours)**
- [ ] Send message as customer
- [ ] Receive/reply as stylist
- [ ] Leave review after appointment
- [ ] View reviews on profile

#### **5. QuickBooks Integration (2 hours)**
- [ ] Connect QuickBooks (manual setup at `/quickbooks/manual_setup`)
- [ ] Complete appointment as stylist
- [ ] Verify customer created in QuickBooks
- [ ] Verify invoice created with tax
- [ ] Check invoice line items (service + add-ons)

### **Payment Testing**
Use Square sandbox test cards:
- Success: `4111 1111 1111 1111`
- Decline: `4000 0000 0000 0002`

### **QuickBooks Testing**
1. Go to stylist dashboard
2. Click "Manual Setup" under QuickBooks
3. Get tokens from OAuth Playground
4. Complete an appointment
5. Check QuickBooks sandbox for customer/invoice

---

## Bug Reporting

Report bugs in the Notion Bug Tracker with:
- Bug ID (auto-numbered)
- Feature affected
- Severity (Critical/High/Medium/Low)
- Description
- Steps to reproduce
- Screenshots if applicable

---

## Project Structure

```
ChairHop_App_2/
├── app/
│   ├── controllers/
│   │   ├── api/              # API endpoints
│   │   ├── stylist/          # Stylist namespace
│   │   ├── customer/         # Customer namespace
│   │   └── quickbooks/       # QuickBooks integration
│   ├── models/
│   ├── services/
│   │   └── quickbooks_service.rb  # QuickBooks API integration
│   ├── jobs/
│   │   └── quickbooks_job.rb      # Background sync job
│   └── views/
├── config/
│   ├── initializers/
│   │   └── quickbooks.rb     # QuickBooks configuration
│   └── routes.rb
├── db/
│   ├── migrate/
│   └── schema.rb
└── .env                      # Environment variables (NOT in git)
```

---

## Deployment

### **Production Checklist**
- [ ] Set up Heroku production app
- [ ] Configure production environment variables
- [ ] Switch to production QuickBooks app
- [ ] Switch to production Square account
- [ ] Set up database backups
- [ ] Configure custom domain & SSL
- [ ] Set up error monitoring (Sentry/Rollbar)
- [ ] Run security audit
- [ ] Load test critical flows

### **Environment Variables for Production**
All sandbox credentials must be replaced with production equivalents:
- Square production access token
- QuickBooks production app credentials
- Production Cloudinary account
- New JWT secret key

---

## QuickBooks Setup Guide

### **For Development (Sandbox):**
1. Create QuickBooks developer account
2. Create sandbox app at https://developer.intuit.com/
3. Add redirect URI: `http://localhost:3000/quickbooks/callback`
4. Create sandbox test company
5. Use manual token setup at `/quickbooks/manual_setup`

### **For Production:**
1. Submit app for production approval (Intuit review process)
2. Update redirect URI to production domain
3. Update environment variables
4. Test OAuth flow thoroughly

---

## Support & Resources

- **QuickBooks Docs:** https://developer.intuit.com/docs/
- **Square Docs:** https://developer.squareup.com/docs/
- **Rails Guides:** https://guides.rubyonrails.org/
- **Devise:** https://github.com/heartcombo/devise

---

## Roadmap (Post-Launch)

### **Phase 2 Features:**
- Email notifications (booking confirmations, reminders)
- Push notifications
- Advanced analytics dashboard
- Cancellation policies and fees
- Stylist team management
- Gift cards and promotions
- Loyalty program

