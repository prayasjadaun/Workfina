# Workfina - Complete Developer Documentation

> **Comprehensive Guide for Frontend, APIs, and Notifications**
>
> **Version:** 1.0.0
> **Last Updated:** January 2026
> **Platform:** Flutter (Android & iOS)

---

## 📋 Table of Contents

### Part 1: App Overview & Architecture
1. [Introduction](#1-introduction)
2. [App Overview](#2-app-overview)
3. [Architecture Pattern](#3-architecture-pattern)
4. [Project Structure](#4-project-structure)
5. [Technology Stack](#5-technology-stack)

### Part 2: API Documentation
6. [API Configuration](#6-api-configuration)
7. [Authentication & Token Management](#7-authentication--token-management)
8. [Authentication APIs](#8-authentication-apis)
9. [Candidate APIs](#9-candidate-apis)
10. [Recruiter APIs](#10-recruiter-apis)
11. [Location APIs](#11-location-apis)
12. [Search & Filtering APIs](#12-search--filtering-apis)
13. [Candidate Management APIs](#13-candidate-management-apis)
14. [Wallet APIs](#14-wallet-apis)
15. [Subscription APIs](#15-subscription-apis)
16. [Notification APIs](#16-notification-apis)
17. [Miscellaneous APIs](#17-miscellaneous-apis)

### Part 3: Frontend Architecture
18. [Authentication Flow](#18-authentication-flow)
19. [Candidate Features](#19-candidate-features)
20. [Recruiter Features](#20-recruiter-features)
21. [Wallet & Payment System](#21-wallet--payment-system)
22. [Subscription System](#22-subscription-system)
23. [Search & Filtering System](#23-search--filtering-system)
24. [State Management](#24-state-management)
25. [Routing & Navigation](#25-routing--navigation)

### Part 4: Notification System
26. [Firebase Cloud Messaging Setup](#26-firebase-cloud-messaging-setup)
27. [Notification Handlers](#27-notification-handlers)
28. [Platform-Specific Configuration](#28-platform-specific-configuration)
29. [FCM Token Management](#29-fcm-token-management)
30. [Notification Flow by App State](#30-notification-flow-by-app-state)

### Part 5: Data Models & Components
31. [Data Models](#31-data-models)
32. [UI Components](#32-ui-components)
33. [Theme & Styling](#33-theme--styling)
34. [Error Handling](#34-error-handling)

### Part 6: Testing & Deployment
35. [Testing Notifications](#35-testing-notifications)
36. [Troubleshooting](#36-troubleshooting)
37. [Best Practices](#37-best-practices)
38. [Quick Reference](#38-quick-reference)

---

# Part 1: App Overview & Architecture

## 1. Introduction

**Workfina** is a two-sided recruitment marketplace built with Flutter that connects job candidates with HR recruiters. The platform operates on a credit-based system where recruiters pay to unlock candidate profiles.

### Key Features

**For Candidates:**
- ✅ Free profile creation
- ✅ Resume and video introduction upload
- ✅ Hiring availability toggle
- ✅ Profile completeness tracking

**For Recruiters:**
- ✅ Browse and filter candidates
- ✅ Unlock candidate contact details (10 credits)
- ✅ Manage unlocked candidates with notes and follow-ups
- ✅ Subscription plans or pay-as-you-go wallet system

---

## 2. App Overview

### Business Model

```
┌─────────────────────────────────────────────────────────┐
│                   WORKFINA PLATFORM                      │
├───────────────────────┬─────────────────────────────────┤
│    CANDIDATES         │         RECRUITERS              │
│    (Free)             │         (Paid)                  │
├───────────────────────┼─────────────────────────────────┤
│ • Create Profile      │ • Browse Candidates             │
│ • Upload Resume       │ • Filter by Skills/Location     │
│ • Video Introduction  │ • Unlock Profiles (10 credits)  │
│ • Toggle Availability │ • Manage Notes & Follow-ups     │
│ • Free Forever        │ • Wallet or Subscription        │
└───────────────────────┴─────────────────────────────────┘
```

### Monetization

1. **Credit System:** 10 credits per candidate unlock
2. **Wallet Recharge:** Pay-as-you-go credit purchases
3. **Subscription Plans:**
   - Basic Plan: 50 credits/month (₹999)
   - Professional Plan: 150 credits/quarter (₹2,499)
   - Enterprise Plan: Unlimited (₹9,999/year)

---

## 3. Architecture Pattern

### MVC-like Architecture with GetX

```
┌─────────────────────────────────────────────────────┐
│                   VIEW LAYER                         │
│         (Screens, Widgets, UI Components)            │
├─────────────────────────────────────────────────────┤
│                CONTROLLER LAYER                      │
│    (Business Logic, State Management - GetX)        │
├─────────────────────────────────────────────────────┤
│                  SERVICE LAYER                       │
│   (API Service, Notification Service, Storage)      │
├─────────────────────────────────────────────────────┤
│                   MODEL LAYER                        │
│          (Data Models, DTOs, Entities)              │
└─────────────────────────────────────────────────────┘
```

### Key Principles

- **Separation of Concerns:** Clear layer boundaries
- **Reactive Programming:** GetX for state management
- **Single Responsibility:** Each controller manages specific domain
- **Dependency Injection:** GetX dependency management
- **Clean Code:** Consistent structure and naming

---

## 4. Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── controllers/                       # Business logic & state
│   ├── auth_controller.dart          # Authentication
│   ├── candidate_controller.dart     # Candidate operations
│   ├── recuriter_controller.dart     # Recruiter operations
│   ├── wallet_controller.dart        # Wallet management
│   ├── theme_controller.dart         # Theme switching
│   └── app_version_controller.dart   # Version checking
│
├── models/                            # Data models
│   ├── user_model.dart
│   ├── candidate_model.dart
│   ├── recruiter_model.dart
│   ├── subscription_model.dart
│   ├── wallet_model.dart
│   ├── transaction_model.dart
│   ├── filter_options_model.dart
│   └── pagination_model.dart
│
├── services/                          # External services
│   ├── api_service.dart              # HTTP API client
│   └── notification_service.dart     # FCM notifications
│
└── views/                             # UI Layer
    └── screens/
        ├── splash_screen.dart
        ├── auth/
        │   ├── email_screen.dart
        │   ├── otp_screen.dart
        │   ├── login_screen.dart
        │   └── create_account_screen.dart
        ├── role/
        │   └── role_selection_screen.dart
        ├── home/
        │   ├── candidate_home_screen.dart
        │   └── recuriter_home_screen.dart
        ├── candidates/
        │   ├── candidate_setup_screen.dart
        │   ├── candidate_dashboard.dart
        │   ├── candidate_profile.dart
        │   └── candidate_edit_profile.dart
        ├── recuriters/
        │   ├── recuriter_setup_screen.dart
        │   ├── recruiter_dashboard.dart
        │   ├── category_screen.dart
        │   ├── recruiter_candidate_screen.dart
        │   ├── recruiter_candidate_details_screen.dart
        │   ├── recruiter_wallet_screen.dart
        │   ├── subscription_main_screen.dart
        │   └── subscription_plans_screen.dart
        ├── notification/
        │   └── notification_screen.dart
        └── widgets/
            ├── candidate_card_widget.dart
            ├── category_card_widget.dart
            ├── search_bar.dart
            └── subscription_status_banner.dart
```

---

## 5. Technology Stack

### Frontend
- **Framework:** Flutter 3.x
- **Language:** Dart 3.x
- **State Management:** GetX
- **HTTP Client:** Dio
- **Local Storage:** SharedPreferences

### Backend Integration
- **API:** RESTful APIs
- **Authentication:** JWT (Access + Refresh tokens)
- **Base URL:** `http://localhost:8000/api` (Development)

### Notifications
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Local Notifications:** flutter_local_notifications

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5                          # State management
  dio: ^5.0.0                          # HTTP client
  shared_preferences: ^2.0.15          # Local storage
  firebase_core: ^3.12.0               # Firebase core
  firebase_messaging: ^16.1.0          # FCM
  flutter_local_notifications: ^19.5.0 # Local notifications
```

---

# Part 2: API Documentation

## 6. API Configuration

### Base URLs

**Development:**
```
Real Device:    http://192.168.0.130:8000/api
Simulator/Mac:  http://localhost:8000/api
```

**Production:**
```
Production:     [UPDATE FOR PRODUCTION]
```

**Media URLs:**
```
Real Device:    http://192.168.0.130:8000
Simulator/Mac:  http://localhost:8000
```

### HTTP Client Setup

**Library:** Dio
**Timeouts:**
- Connect: 60 seconds
- Receive: 60 seconds
- Send: 60 seconds

### Default Headers

```json
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "Authorization": "Bearer {access_token}"
}
```

**For File Uploads:**
```json
{
  "Authorization": "Bearer {access_token}",
  "Content-Type": "multipart/form-data"
}
```

---

## 7. Authentication & Token Management

### JWT Token System

Workfina uses **JWT tokens** for authentication:
- **Access Token:** Short-lived (expires in ~15 minutes)
- **Refresh Token:** Long-lived (expires in ~7 days)

### Token Storage

```
SharedPreferences Keys:
├── access_token
├── refresh_token
└── user_data (JSON string)
```

### Automatic Token Refresh

```
Request Flow:
├── Check token expiry (30-second buffer)
├── If expiring soon → Refresh token
├── Update stored token
├── Continue with original request
└── On 401 error → Attempt refresh → Retry or Logout
```

### Token Lifecycle

1. **Login/Signup** → Receive tokens
2. **Store tokens** in SharedPreferences
3. **Every API request** → Add access token to header
4. **Before request** → Check expiry, refresh if needed
5. **On 401 error** → Refresh token → Retry request
6. **If refresh fails** → Logout user

---

## 8. Authentication APIs

### 8.1 Send OTP

**Endpoint:** `POST /auth/send-otp/`
**Authentication:** Not required

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Success Response (200):**
```json
{
  "message": "OTP sent successfully"
}
```

**Error Responses:**
```json
{
  "error": "Email already exists"
}
```

---

### 8.2 Verify OTP

**Endpoint:** `POST /auth/verify-otp/`
**Authentication:** Not required

**Request:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Success Response (200):**
```json
{
  "message": "OTP verified successfully"
}
```

**Error Responses:**
```json
{
  "error": "Invalid OTP",
  "non_field_errors": ["OTP expired"]
}
```

---

### 8.3 Create Account

**Endpoint:** `POST /auth/create-account/`
**Authentication:** Not required

**Request:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "SecurePass123!",
  "confirm_password": "SecurePass123!"
}
```

**Success Response (200):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "123",
    "email": "user@example.com",
    "username": "johndoe",
    "role": null,
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

**Error Responses:**
```json
{
  "username": ["This username is already taken"],
  "email": ["This email is already registered"]
}
```

---

### 8.4 Login

**Endpoint:** `POST /auth/login/`
**Authentication:** Not required

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Success Response (200):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "123",
    "email": "user@example.com",
    "username": "johndoe",
    "role": "CANDIDATE",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

**User Roles:**
- `CANDIDATE` - Job seeker
- `RECRUITER` - HR/Recruiter
- `null` - Role not selected yet

---

### 8.5 Refresh Token

**Endpoint:** `POST /auth/refresh/`
**Authentication:** Not required (uses refresh token)

**Request:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response (200):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Note:** Called automatically when access token expires.

---

### 8.6 Logout

**Endpoint:** `POST /auth/logout/`
**Authentication:** Required

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

### 8.7 Update User Role

**Endpoint:** `PATCH /auth/update-role/`
**Authentication:** Required

**Request:**
```json
{
  "role": "RECRUITER"
}
```

**Valid Roles:** `CANDIDATE`, `RECRUITER`

**Success Response (200):**
```json
{
  "message": "Role updated successfully"
}
```

---

### 8.8 Update FCM Token

**Endpoint:** `POST /auth/update-fcm-token/`
**Authentication:** Required

**Request:**
```json
{
  "token": "fL3Ck8xRQvG-token-example..."
}
```

**Success Response (200):**
```json
{
  "message": "FCM token updated"
}
```

**Note:** Called automatically after login for push notifications.

---

## 9. Candidate APIs

### 9.1 Register Candidate

**Endpoint:** `POST /candidates/register/`
**Authentication:** Required
**Content-Type:** `multipart/form-data`

**Request Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| full_name | String | Yes | Full name |
| phone | String | Yes | Phone with country code |
| age | Integer | Yes | Age in years |
| role | String | Yes | Job role/title |
| experience_years | Integer | Yes | Years of experience |
| current_ctc | Decimal | No | Current salary (annual) |
| expected_ctc | Decimal | No | Expected salary (annual) |
| country | String | Yes | Country name |
| state | String | Yes | State name |
| city | String | Yes | City name |
| education | String | Yes | Education history |
| skills | String | Yes | Comma-separated skills |
| work_experience | String | Yes | Work experience details |
| resume | File | Yes | Resume PDF |
| video_intro | File | No | Video introduction |
| profile_image | File | No | Profile photo |

**Success Response (200):**
```json
{
  "id": "456",
  "full_name": "John Doe",
  "email": "user@example.com",
  "phone": "+919876543210",
  "age": 25,
  "role": "Software Engineer",
  "experience_years": 3,
  "resume_url": "http://localhost:8000/media/resumes/john_resume.pdf",
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

### 9.2 Get Candidate Profile

**Endpoint:** `GET /candidates/profile/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "id": "456",
  "full_name": "John Doe",
  "email": "user@example.com",
  "phone": "+919876543210",
  "age": 25,
  "role": "Software Engineer",
  "experience_years": 3,
  "current_ctc": 500000.00,
  "expected_ctc": 800000.00,
  "state": "Maharashtra",
  "city": "Mumbai",
  "skills": "Python, Django, React",
  "resume_url": "http://localhost:8000/media/resumes/john_resume.pdf",
  "is_available_for_hiring": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

### 9.3 Update Candidate Profile

**Endpoint:** `PUT /candidates/profile/update/`
**Authentication:** Required
**Content-Type:** `multipart/form-data`

**Request:** Same fields as registration (all optional)

**Success Response (200):**
```json
{
  "profile": {
    "id": "456",
    "full_name": "John Doe Updated",
    ...
  }
}
```

---

### 9.4 Get/Update Candidate Availability

**Get Availability:**
`GET /candidates/availability/`

**Response:**
```json
{
  "is_available_for_hiring": true
}
```

**Update Availability:**
`POST /candidates/availability/update/`

**Request:**
```json
{
  "is_available_for_hiring": false
}
```

**Response:**
```json
{
  "message": "Availability updated successfully",
  "is_available_for_hiring": false
}
```

---

### 9.5 Save Candidate Step

**Endpoint:** `POST /candidates/save-step/`
**Authentication:** Required
**Content-Type:** `multipart/form-data`

**Request:**
```
step: 1
full_name: "John Doe"
phone: "+919876543210"
... (fields for this step)
```

**Success Response (200):**
```json
{
  "message": "Step saved successfully"
}
```

**Note:** Used in multi-step candidate setup form.

---

## 10. Recruiter APIs

### 10.1 Register Recruiter

**Endpoint:** `POST /recruiters/register/`
**Authentication:** Required

**Request:**
```json
{
  "full_name": "Jane Smith",
  "company_name": "Tech Corp Pvt Ltd",
  "designation": "HR Manager",
  "phone": "+919876543210",
  "company_website": "https://techcorp.com",
  "company_size": "50-100"
}
```

**Company Size Options:** "1-10", "10-50", "50-100", "100-500", "500+"

**Success Response (200):**
```json
{
  "id": "789",
  "full_name": "Jane Smith",
  "company_name": "Tech Corp Pvt Ltd",
  "designation": "HR Manager",
  "phone": "+919876543210",
  "company_size": "50-100",
  "total_spent": 0,
  "is_verified": false,
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Note:** `is_verified` starts as false. Admin approval required.

---

### 10.2 Get Recruiter Profile

**Endpoint:** `GET /recruiters/profile/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "id": "789",
  "full_name": "Jane Smith",
  "company_name": "Tech Corp Pvt Ltd",
  "designation": "HR Manager",
  "total_spent": 150,
  "is_verified": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

### 10.3 Update Recruiter Profile

**Endpoint:** `PATCH /recruiters/profile/update/`
**Authentication:** Required

**Request:** All fields optional
```json
{
  "full_name": "Jane Smith Updated",
  "designation": "Senior HR Manager"
}
```

---

## 11. Location APIs

### 11.1 Get States

**Endpoint:** `GET /candidates/locations/states/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "states": [
    {"name": "Maharashtra", "slug": "maharashtra"},
    {"name": "Delhi", "slug": "delhi"},
    {"name": "Karnataka", "slug": "karnataka"}
  ]
}
```

---

### 11.2 Get Cities

**Endpoint:** `GET /candidates/locations/cities/?state={state_slug}`
**Authentication:** Required

**Query Parameters:**
- `state` (required): State slug

**Success Response (200):**
```json
{
  "cities": [
    {"name": "Mumbai", "slug": "mumbai"},
    {"name": "Pune", "slug": "pune"},
    {"name": "Nagpur", "slug": "nagpur"}
  ]
}
```

---

## 12. Search & Filtering APIs

### 12.1 Get Filter Options

**Endpoint:** `GET /candidates/filter-options/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "roles": ["Software Engineer", "Data Scientist", "DevOps Engineer"],
  "cities": ["Mumbai", "Pune", "Bangalore"],
  "states": ["Maharashtra", "Karnataka", "Delhi"],
  "skills": ["Python", "Java", "React", "Angular"],
  "educations": ["B.Tech", "M.Tech", "MBA"]
}
```

---

### 12.2 Get Specific Filter Options (Paginated)

**Endpoint:** `GET /candidates/filter-options/?type={type}&page={page}&search={query}`
**Authentication:** Required

**Query Parameters:**
- `type` (required): roles, cities, states, skills
- `page` (optional): Page number (default: 1)
- `page_size` (optional): Results per page (default: 20)
- `search` (optional): Search query

**Success Response (200):**
```json
{
  "results": ["Python", "Python Django", "Python Flask"],
  "count": 3,
  "next": null,
  "previous": null
}
```

---

### 12.3 Get Filter Categories

**Endpoint:** `GET /candidates/filter-categories/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "categories": [
    {"name": "Technology", "slug": "technology", "count": 150},
    {"name": "Marketing", "slug": "marketing", "count": 75},
    {"name": "Sales", "slug": "sales", "count": 60}
  ]
}
```

---

### 12.4 Get Filtered Candidates

**Endpoint:** `GET /recruiters/candidates/filter/`
**Authentication:** Required

**Query Parameters:**
- `role`: Job role
- `min_experience`, `max_experience`: Experience range
- `min_age`, `max_age`: Age range
- `city`, `state`, `country`: Location filters
- `education`: Education level
- `skills`: Comma-separated skills
- `min_ctc`, `max_ctc`: CTC range
- `page`, `page_size`: Pagination

**Success Response (200):**
```json
{
  "candidates": [
    {
      "id": "456",
      "full_name": "John Doe",
      "masked_name": "J*** D**",
      "phone": "******3210",
      "email": "j***@example.com",
      "age": 25,
      "role": "Software Engineer",
      "experience_years": 3,
      "city": "Mumbai",
      "skills": "Python, Django, React",
      "is_unlocked": false,
      "unlock_cost": 10
    }
  ],
  "pagination": {
    "count": 150,
    "page": 1,
    "page_size": 20,
    "total_pages": 8
  }
}
```

**Locked Candidates:**
- `masked_name`: "J*** D**"
- `phone`: "******3210"
- `email`: "j***@example.com"
- No resume/video URLs

**Unlocked Candidates:**
- Full contact information
- Resume and video URLs included
- `is_unlocked`: true

---

## 13. Candidate Management APIs

### 13.1 Unlock Candidate

**Endpoint:** `POST /candidates/{candidate_id}/unlock/`
**Authentication:** Required

**URL Parameters:**
- `candidate_id`: Candidate's ID

**Success Response (200):**
```json
{
  "message": "Candidate unlocked successfully",
  "candidate": {
    "id": "456",
    "full_name": "John Doe",
    "phone": "+919876543210",
    "email": "john@example.com",
    "resume_url": "http://localhost:8000/media/resumes/john_resume.pdf",
    ...
  },
  "credits_used": 10,
  "remaining_balance": 90,
  "already_unlocked": false
}
```

**Error Response:**
```json
{
  "error": "Insufficient credits",
  "detail": "You need 10 credits. Current balance: 5 credits."
}
```

**Credit Deduction Priority:**
1. Active subscription credits
2. Wallet credits
3. Error if both insufficient

---

### 13.2 Get Unlocked Candidates

**Endpoint:** `GET /candidates/unlocked/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "unlocked_candidates": [
    {
      "id": "456",
      "full_name": "John Doe",
      "phone": "+919876543210",
      "email": "john@example.com",
      "resume_url": "http://localhost:8000/media/resumes/john_resume.pdf",
      "unlocked_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

---

### 13.3 Add Candidate Note

**Endpoint:** `POST /candidates/{candidate_id}/note/`
**Authentication:** Required

**Request:**
```json
{
  "note_text": "Good candidate. Strong Python skills. Interviewed on 2024-01-15."
}
```

**Success Response (200):**
```json
{
  "id": "note_123",
  "note_text": "Good candidate. Strong Python skills...",
  "created_at": "2024-01-15T10:30:00Z",
  "created_by": "Jane Smith"
}
```

---

### 13.4 Add Candidate Followup

**Endpoint:** `POST /candidates/{candidate_id}/followup/`
**Authentication:** Required

**Request:**
```json
{
  "followup_date": "2024-01-25T10:00:00Z",
  "notes": "Schedule second round interview",
  "is_completed": false
}
```

**Success Response (200):**
```json
{
  "id": "followup_123",
  "followup_date": "2024-01-25T10:00:00Z",
  "notes": "Schedule second round interview",
  "is_completed": false,
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### 13.5 Get Notes & Followups

**Endpoint:** `GET /candidates/{candidate_id}/notes-followups/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "notes": [
    {
      "id": "note_123",
      "note_text": "Good candidate",
      "created_at": "2024-01-15T10:30:00Z",
      "created_by": "Jane Smith"
    }
  ],
  "followups": [
    {
      "id": "followup_123",
      "followup_date": "2024-01-25T10:00:00Z",
      "notes": "Schedule interview",
      "is_completed": false,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

---

### 13.6 Delete Note/Followup

**Delete Note:**
`DELETE /candidates/{candidate_id}/note/{note_id}/`

**Delete Followup:**
`DELETE /candidates/{candidate_id}/followup/{followup_id}/`

**Success Response (200):**
```json
{
  "success": true
}
```

---

## 14. Wallet APIs

### 14.1 Get Wallet Balance

**Endpoint:** `GET /wallet/balance/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "wallet": {
    "id": "wallet_123",
    "balance": 100,
    "total_spent": 50,
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

---

### 14.2 Recharge Wallet

**Endpoint:** `POST /wallet/recharge/`
**Authentication:** Required

**Request:**
```json
{
  "credits": 100,
  "payment_reference": "TXN123456789"
}
```

**Success Response (200):**
```json
{
  "message": "Wallet recharged successfully",
  "new_balance": 200,
  "transaction_id": "trans_123"
}
```

---

### 14.3 Get Wallet Transactions

**Endpoint:** `GET /wallet/transactions/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "transactions": [
    {
      "id": "trans_123",
      "type": "CREDIT",
      "amount": 100,
      "description": "Wallet recharge",
      "payment_reference": "TXN123456789",
      "balance_after": 200,
      "created_at": "2024-01-15T10:00:00Z"
    },
    {
      "id": "trans_124",
      "type": "DEBIT",
      "amount": 10,
      "description": "Unlocked candidate: John Doe",
      "balance_after": 190,
      "created_at": "2024-01-15T14:30:00Z"
    }
  ]
}
```

**Transaction Types:**
- `CREDIT`: Credits added (recharge)
- `DEBIT`: Credits deducted (unlock)

---

## 15. Subscription APIs

### 15.1 Get Subscription Plans

**Endpoint:** `GET /subscriptions/plans/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "plans": [
    {
      "id": "plan_1",
      "name": "Basic Plan",
      "description": "Perfect for small teams",
      "plan_type": "MONTHLY",
      "duration_days": 30,
      "price": "999.00",
      "is_unlimited": false,
      "credits_limit": 50,
      "features": ["50 unlocks", "Email support"]
    },
    {
      "id": "plan_2",
      "name": "Enterprise Plan",
      "plan_type": "YEARLY",
      "duration_days": 365,
      "price": "9999.00",
      "is_unlimited": true,
      "credits_limit": null,
      "features": ["Unlimited unlocks", "Priority support"]
    }
  ]
}
```

---

### 15.2 Get Current Subscription

**Endpoint:** `GET /subscriptions/subscriptions/current/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "id": "sub_123",
  "plan": {
    "name": "Basic Plan",
    "plan_type": "MONTHLY",
    "price": "999.00",
    "is_unlimited": false,
    "credits_limit": 50
  },
  "status": "ACTIVE",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "days_remaining": 15,
  "warning_level": null,
  "credits_used": 25,
  "credits_remaining": 25
}
```

**Subscription Statuses:**
- `PENDING` - Awaiting approval
- `ACTIVE` - Currently active
- `EXPIRED` - Past end date
- `CANCELLED` - Manually cancelled

**Warning Levels:**
- `null` - More than 7 days remaining
- `"warning"` - 3-7 days remaining
- `"critical"` - Less than 3 days

---

### 15.3 Get Subscription Status (Lightweight)

**Endpoint:** `GET /subscriptions/subscriptions/status/`
**Authentication:** Required

**With Active Subscription:**
```json
{
  "has_subscription": true,
  "status": "ACTIVE",
  "plan": "Basic Plan",
  "expires_at": "2024-01-31T23:59:59Z",
  "days_remaining": 15,
  "credits_used": 25,
  "credits_limit": 50
}
```

**Without Subscription:**
```json
{
  "has_subscription": false,
  "status": null,
  "plan": null
}
```

---

### 15.4 Get Subscription History

**Endpoint:** `GET /subscriptions/subscriptions/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "subscriptions": [
    {
      "id": "sub_123",
      "plan": {"name": "Basic Plan", "plan_type": "MONTHLY"},
      "status": "ACTIVE",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-01-31T23:59:59Z",
      "credits_used": 25
    },
    {
      "id": "sub_122",
      "plan": {"name": "Basic Plan", "plan_type": "MONTHLY"},
      "status": "EXPIRED",
      "start_date": "2023-12-01T00:00:00Z",
      "end_date": "2023-12-31T23:59:59Z",
      "credits_used": 50
    }
  ]
}
```

---

## 16. Notification APIs

### 16.1 Get User Notifications

**Endpoint:** `GET /notifications/?page={page}`
**Authentication:** Required

**Success Response (200):**
```json
[
  {
    "id": "notif_123",
    "title": "Candidate Unlocked",
    "body": "You unlocked John Doe's profile",
    "type": "CANDIDATE_UNLOCK",
    "is_read": false,
    "data": {"candidate_id": "456"},
    "created_at": "2024-01-15T10:30:00Z"
  }
]
```

**Notification Types:**
- `CANDIDATE_UNLOCK`
- `SUBSCRIPTION_WARNING`
- `SUBSCRIPTION_EXPIRED`
- `WALLET_RECHARGE`
- `GENERAL`

---

### 16.2 Get Notification Count

**Endpoint:** `GET /notifications/count/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "unread_count": 5,
  "total_count": 25
}
```

---

### 16.3 Mark Notification as Read

**Endpoint:** `POST /notifications/{notification_id}/read/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "message": "Notification marked as read"
}
```

---

### 16.4 Mark All as Read

**Endpoint:** `POST /notifications/mark-all-read/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "message": "All notifications marked as read",
  "count": 5
}
```

---

### 16.5 Send Test Notification

**Endpoint:** `POST /notifications/test/`
**Authentication:** Required

**Request:**
```json
{
  "title": "Test Notification",
  "body": "This is a test"
}
```

**Success Response (200):**
```json
{
  "message": "Test notification sent successfully"
}
```

---

## 17. Miscellaneous APIs

### 17.1 Get Active Banner

**Endpoint:** `GET /banner/active/`
**Authentication:** Required

**Success Response (200):**
```json
{
  "id": "banner_1",
  "title": "New Year Offer!",
  "button_text": "Get 50% Off",
  "image": "http://localhost:8000/media/banners/newyear.jpg",
  "link": "https://workfina.com/offers"
}
```

---

### 17.2 Check App Version

**Endpoint:** `POST /app-version/check/`
**Authentication:** Not required

**Request:**
```json
{
  "current_version": "1.0.0",
  "platform": "android"
}
```

**Platforms:** `android`, `ios`

**Update Required:**
```json
{
  "update_required": true,
  "force_update": false,
  "latest_version": "1.2.0",
  "message": "New version available",
  "download_url": "https://play.google.com/store/..."
}
```

**No Update:**
```json
{
  "update_required": false,
  "latest_version": "1.0.0",
  "message": "You're on latest version"
}
```

---

# Part 3: Frontend Architecture

## 18. Authentication Flow

### User Flow

```
App Launch
    │
    ├─→ Has valid token? ─→ Yes ─→ Home (based on role)
    │
    └─→ No
        │
        ├─→ Email Screen
        │       ├─→ Has account? → Login
        │       └─→ New user? → Send OTP
        │
        ├─→ OTP Screen → Verify OTP
        │
        ├─→ Create Account → Set credentials
        │
        └─→ Role Selection
                ├─→ CANDIDATE → Setup
                └─→ RECRUITER → Setup
```

### Auth Controller

**File:** `lib/controllers/auth_controller.dart`

```dart
class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<UserModel>();
  var errorMessage = ''.obs;

  Future<void> sendOTP(String email);
  Future<void> verifyOTP(String email, String otp);
  Future<void> createAccount(String email, String username, String password);
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> updateRole(String role);
}
```

### Key Features

1. **JWT Management:** Auto-refresh with 30s buffer
2. **Session Persistence:** SharedPreferences storage
3. **Error Handling:** User-friendly messages
4. **FCM Integration:** Token upload after login

---

## 19. Candidate Features

### Candidate Setup (Multi-Step)

**File:** `lib/views/screens/candidates/candidate_setup_screen.dart`

**Steps:**
1. Personal Information
2. Location & Contact
3. Experience & Skills
4. Education
5. Resume & Media Upload
6. Review & Submit

**Progressive Saving:** Each step saved via API

### Candidate Dashboard

**File:** `lib/views/screens/candidates/candidate_dashboard.dart`

**Components:**

```
┌────────────────────────────────────────┐
│  Profile Completeness: 85%             │
│  ██████████████████░░░░░               │
├────────────────────────────────────────┤
│  Stats:                                │
│  ┌──────────┐ ┌──────────┐            │
│  │ 3 years  │ │ 15 skills│            │
│  │   exp    │ │          │            │
│  └──────────┘ └──────────┘            │
├────────────────────────────────────────┤
│  Quick Actions:                        │
│  • Edit Profile                        │
│  • Update Resume                       │
│  • Update Availability                 │
├────────────────────────────────────────┤
│  Hiring Status:                        │
│  ○ Available  ● Not Available          │
└────────────────────────────────────────┘
```

### Candidate Profile

**Sections:**
- Header (photo, name, role)
- Contact Information
- Experience Timeline
- Education History
- Skills (chips)
- Documents (resume, video)
- Career Objective

### Candidate Controller

```dart
class CandidateController extends GetxController {
  var candidate = Rxn<CandidateModel>();
  var isAvailableForHiring = true.obs;

  Future<void> registerCandidate(Map data);
  Future<void> getCandidateProfile();
  Future<void> updateProfile(Map data);
  Future<void> toggleAvailability();
}
```

---

## 20. Recruiter Features

### Recruiter Dashboard

**File:** `lib/views/screens/recuriters/recruiter_dashboard.dart`

**Layout:**

```
┌──────────────────────────────────────────┐
│  [Search Bar]      [Notification Bell]   │
├──────────────────────────────────────────┤
│  [Engineering] [Marketing] [Sales]       │
├──────────────────────────────────────────┤
│  Stats:                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐             │
│  │ 100  │ │  25  │ │ ₹500 │             │
│  │Credits│ │Unlocked│ Spent │            │
│  └──────┘ └──────┘ └──────┘             │
├──────────────────────────────────────────┤
│  Categories (Bento Grid):                │
│  ┌──────────┐ ┌──────────┐              │
│  │Technology│ │Marketing │              │
│  │ 150      │ │  75      │              │
│  └──────────┘ └──────────┘              │
├──────────────────────────────────────────┤
│  Recent Activity:                        │
│  • Unlocked John Doe (2h ago)           │
│  • Unlocked Jane Smith (1d ago)         │
└──────────────────────────────────────────┘
```

### Candidate Discovery

#### Candidate Screen

**File:** `lib/views/screens/recuriters/recruiter_candidate_screen.dart`

**Tabs:**
1. **Available (Locked)**
   - Masked info (J*** D***)
   - Lock icon
   - 10 credits to unlock

2. **Unlocked**
   - Full contact details
   - Resume access
   - Notes & followups

### Candidate Details

**Locked View:**
```
┌──────────────────────────────────┐
│  J*** D***                       │
│  Software Engineer               │
├──────────────────────────────────┤
│  Experience: 3 years             │
│  Location: Mumbai                │
│  Skills: Python, Django          │
├──────────────────────────────────┤
│  [🔒 Unlock - 10 Credits]        │
└──────────────────────────────────┘
```

**Unlocked View:**
```
┌──────────────────────────────────┐
│  John Doe                        │
│  📧 john@example.com             │
│  📱 +91 9876543210               │
├──────────────────────────────────┤
│  [Download Resume] [Video]       │
├──────────────────────────────────┤
│  Notes & Follow-ups:             │
│  [Add Note] [Add Follow-up]      │
│                                  │
│  📝 Good technical skills        │
│  📅 Interview on Jan 25          │
└──────────────────────────────────┘
```

### Filtering

**File:** `lib/views/screens/recuriters/recruiter_filter_screen.dart`

**Filters:**
- Department/Role
- Religion
- State/City
- Experience (0-1, 2-5, 5+ years)
- Education
- Skills (multi-select)
- CTC Range (current & expected)

### Recruiter Controller

```dart
class RecruiterController extends GetxController {
  var recruiter = Rxn<RecruiterModel>();
  var candidates = <CandidateModel>[].obs;
  var unlockedCandidates = <CandidateModel>[].obs;

  Future<void> getCandidates(Map filters);
  Future<void> unlockCandidate(String id);
  Future<void> addNote(String id, String note);
  Future<void> addFollowup(String id, Map data);
}
```

---

## 21. Wallet & Payment System

### Wallet Screen

**File:** `lib/views/screens/recuriters/recruiter_wallet_screen.dart`

```
┌──────────────────────────────────┐
│  Wallet Balance                  │
│  💰 100 Credits                  │
│  [Recharge Wallet]               │
├──────────────────────────────────┤
│  Credit Info:                    │
│  • Wallet: 100                   │
│  • Subscription: 25              │
│  • Total: 125                    │
├──────────────────────────────────┤
│  Total Spent: ₹5,000             │
├──────────────────────────────────┤
│  Transactions:                   │
│  + ₹1,000 Recharge (Jan 15)      │
│  - 10 credits Unlock John Doe    │
│  - 10 credits Unlock Jane Smith  │
└──────────────────────────────────┘
```

### Credit Deduction Logic

**Priority:**
1. Active subscription credits
2. Wallet credits
3. Error if both insufficient

```dart
Future<void> unlockCandidate(String id) async {
  const cost = 10;

  if (hasActiveSubscription && subscriptionCredits >= cost) {
    await _unlockWithSubscription(id);
  } else if (walletBalance >= cost) {
    await _unlockWithWallet(id);
  } else {
    throw Exception('Insufficient credits');
  }
}
```

### Wallet Controller

```dart
class WalletController extends GetxController {
  var wallet = Rxn<WalletModel>();
  var transactions = <TransactionModel>[].obs;

  Future<void> getBalance();
  Future<void> recharge(int credits, String ref);
  Future<void> getTransactions();
}
```

---

## 22. Subscription System

### Subscription Screens

#### Main Screen

**File:** `lib/views/screens/recuriters/subscription_main_screen.dart`

```
┌──────────────────────────────────┐
│  Current Subscription            │
│  ✅ Basic Plan - Active          │
│  Expires: Jan 31 (15 days)       │
│  Credits: 25/50 used             │
├──────────────────────────────────┤
│  [View Plans] [Upgrade]          │
└──────────────────────────────────┘
```

#### Plans Screen

**File:** `lib/views/screens/recuriters/subscription_plans_screen.dart`

```
┌──────────────────────────────────┐
│  Basic Plan - ₹999/month         │
│  • 50 unlocks                    │
│  • Email support                 │
│  [Select Plan]                   │
├──────────────────────────────────┤
│  Professional - ₹2,499/quarter   │
│  • 150 unlocks                   │
│  • Priority support              │
│  [Select Plan] [POPULAR 🔥]      │
├──────────────────────────────────┤
│  Enterprise - ₹9,999/year        │
│  • Unlimited unlocks             │
│  • Dedicated manager             │
│  [Select Plan]                   │
└──────────────────────────────────┘
```

#### History Screen

**File:** `lib/views/screens/recuriters/subscription_history_screen.dart`

Shows all past and current subscriptions with status.

### Subscription Components

**Status Banner:**
`lib/views/screens/widgets/subscription_status_banner.dart`

**Expiry Dialog:**
`lib/views/screens/widgets/subscription_expiry_dialog.dart`

---

## 23. Search & Filtering System

### Global Search

**File:** `lib/views/screens/widgets/search_bar.dart`

**Features:**
- Real-time search
- Debounced (500ms)
- Search by name, role, skills, city
- Clear button
- Loading indicator

```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(Duration(milliseconds: 500), () {
    widget.onSearch(query);
  });
}
```

### Category Filtering

**Horizontal Tabs:**
`lib/views/screens/widgets/horizontal_category_tabs.dart`

```
[ Engineering (150) ] [ Marketing (75) ] [ Sales (60) ]
```

**Category Cards:**
`lib/views/screens/widgets/category_card_widget.dart`

### Advanced Filters

**Filter State:**
```dart
var selectedFilters = {
  'role': null,
  'city': null,
  'min_experience': null,
  'max_experience': null,
  'skills': [],
  'min_ctc': null,
  'max_ctc': null,
}.obs;
```

### Pagination

```dart
class PaginationModel {
  int count;
  int page;
  int pageSize;
  int totalPages;
  String? next;
  String? previous;
}
```

**Infinite Scroll:**
```dart
_scrollController.addListener(() {
  if (_scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent) {
    controller.loadMore();
  }
});
```

---

## 24. State Management

### GetX Pattern

**Why GetX?**
- Reactive programming
- Minimal boilerplate
- Built-in dependency injection
- Performance optimized

**Example Controller:**

```dart
class AuthController extends GetxController {
  // Observable state
  var isLoading = false.obs;
  var user = Rxn<UserModel>();

  // Methods
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _apiService.login(email, password);
      user.value = response.user;
      Get.offAll(() => HomeScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
```

**Usage in UI:**

```dart
class LoginScreen extends StatelessWidget {
  final controller = Get.put(AuthController());

  Widget build(BuildContext context) {
    return Obx(() => controller.isLoading.value
      ? CircularProgressIndicator()
      : ElevatedButton(
          onPressed: () => controller.login(email, password),
          child: Text('Login'),
        )
    );
  }
}
```

### Dependency Injection

```dart
void main() {
  Get.put(ApiService());
  Get.put(AuthController());
  Get.lazyPut(() => CandidateController());
  Get.lazyPut(() => RecruiterController());

  runApp(MyApp());
}
```

---

## 25. Routing & Navigation

### Named Routes

```dart
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const candidateHome = '/candidate-home';
  static const recruiterHome = '/recruiter-home';
}
```

### Navigation Methods

```dart
// Navigate to new screen
Get.to(() => DetailsScreen());

// Navigate with named route
Get.toNamed(AppRoutes.candidateHome);

// Replace current screen
Get.off(() => HomeScreen());

// Clear stack and navigate
Get.offAll(() => LoginScreen());

// Go back
Get.back();

// Pass arguments
Get.to(() => DetailsScreen(), arguments: {'id': '123'});
```

### Bottom Navigation

**Candidate Home (4 tabs):**
- Home
- Jobs
- Applications
- Profile

**Recruiter Home (5 tabs):**
- Home
- Unlocked
- Wallet
- Plans
- Profile

---

# Part 4: Notification System

## 26. Firebase Cloud Messaging Setup

### Architecture

```
FCM Message Arrives
    ↓
Foreground? → Local Notification
Background? → Background Handler
Terminated? → Background Handler
    ↓
User Taps Notification
    ↓
onMessageOpenedApp → Handle Navigation
```

### Initialization

**File:** `lib/services/notification_service.dart`

```dart
static Future<void> initialize() async {
  // 1. Set foreground options
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 2. Initialize Firebase
  await Firebase.initializeApp();

  // 3. Register background handler
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler
  );

  // 4. Initialize local notifications
  await _initializeLocalNotifications();

  // 5. Create notification channel
  await _createNotificationChannel();

  // 6. Request permissions
  await requestPermissions();

  // 7. Setup message handlers
  _setupMessageHandlers();
}
```

### Background Handler

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message
) async {
  await Firebase.initializeApp();

  print('Background: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}
```

**Requirements:**
- Top-level function (not inside class)
- `@pragma('vm:entry-point')` annotation
- Initialize Firebase first

---

## 27. Notification Handlers

### Message Handlers Setup

```dart
static void _setupMessageHandlers() {
  // Foreground messages
  FirebaseMessaging.onMessage.listen(
    _handleForegroundMessage
  );

  // Background/terminated click
  FirebaseMessaging.onMessageOpenedApp.listen(
    _handleMessageClick
  );
}
```

### Foreground Handler

```dart
static Future<void> _handleForegroundMessage(
  RemoteMessage message
) async {
  print('Foreground: ${message.messageId}');
  await _showLocalNotification(message);
}
```

### Click Handler

```dart
static void _handleMessageClick(RemoteMessage message) {
  print('Clicked: ${message.data}');

  // TODO: Navigate based on type
  // switch (message.data['type']) {
  //   case 'CANDIDATE_UNLOCK':
  //     navigateToCandidate(message.data['candidate_id']);
  //   case 'SUBSCRIPTION_WARNING':
  //     navigateToPlans();
  // }
}
```

### Local Notification

```dart
static Future<void> _showLocalNotification(
  RemoteMessage message
) async {
  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'Workfina',
    message.notification?.body ?? 'New notification',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}
```

---

## 28. Platform-Specific Configuration

### Android Configuration

**File:** `android/app/src/main/AndroidManifest.xml`

**Permissions:**
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

**FCM Service:**
```xml
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

**Metadata:**
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
```

**Notification Channel:**
```dart
const channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);
```

---

### iOS Configuration

**File:** `ios/Runner/AppDelegate.swift`

**Setup:**
```swift
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [...]
) -> Bool {
    Messaging.messaging().delegate = self

    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [
        .alert, .badge, .sound, .provisional
    ]
    UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
    )

    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

**APNS Token:**
```swift
override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    Messaging.messaging().apnsToken = deviceToken
}
```

**Foreground Presentation:**
```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
    if #available(iOS 14.0, *) {
        completionHandler([[.banner, .sound, .badge]])
    } else {
        completionHandler([[.alert, .sound, .badge]])
    }
}
```

**Entitlements:**
```xml
<key>aps-environment</key>
<string>development</string>
```

**⚠️ IMPORTANT:** Change to `production` for release!

---

## 29. FCM Token Management

### Get Token

```dart
static Future<String?> getToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      print('FCM Token: $token');
      await _saveTokenToPrefs(token);
    }

    return token;
  } catch (e) {
    print('Error getting FCM token: $e');
    return null;
  }
}
```

### Save Token

```dart
static Future<void> _saveTokenToPrefs(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fcm_token', token);
}
```

### Upload to Server

```dart
// In ApiService
Future<void> uploadFCMToken(String token) async {
  await dio.post(
    '$baseUrl/auth/update-fcm-token/',
    data: {'token': token},
  );
}

// After login
final token = await NotificationService.getToken();
if (token != null) {
  await ApiService().uploadFCMToken(token);
}
```

---

## 30. Notification Flow by App State

### Foreground (App Active)

```
FCM Message
    ↓
FirebaseMessaging.onMessage
    ↓
_handleForegroundMessage()
    ↓
_showLocalNotification()
    ↓
User sees banner + sound + badge
```

---

### Background (App Inactive)

```
FCM Message
    ↓
_firebaseMessagingBackgroundHandler()
    ↓
Log message (debug)
    ↓
FCM displays in system tray
    ↓
User taps notification
    ↓
onMessageOpenedApp triggered
```

---

### Terminated (App Closed)

```
FCM Message
    ↓
_firebaseMessagingBackgroundHandler()
    ↓
FCM displays in system tray
    ↓
User taps notification
    ↓
App launches
    ↓
onMessageOpenedApp triggered
```

---

### Permission Request

```dart
static Future<void> requestPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  print('Permission: ${settings.authorizationStatus}');
}
```

**Authorization Status:**
- `authorized` - Permission granted
- `denied` - Permission denied
- `notDetermined` - Not asked yet
- `provisional` - Provisional (iOS 12+)

**Platform Behavior:**
- **Android:** Auto-granted
- **iOS:** Requires user approval

---

### Topic Subscription

```dart
// Subscribe
static Future<void> subscribeToTopic(String topic) async {
  await FirebaseMessaging.instance.subscribeToTopic(topic);
  print('Subscribed to: $topic');
}

// Unsubscribe
static Future<void> unsubscribeFromTopic(String topic) async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  print('Unsubscribed from: $topic');
}
```

**Use Cases:**
- "recruiter_updates"
- "candidate_updates"
- "promotional_offers"

---

# Part 5: Data Models & Components

## 31. Data Models

### User Model

```dart
class UserModel {
  String id;
  String email;
  String username;
  String? role; // CANDIDATE | RECRUITER | null
  DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

### Candidate Model

```dart
class CandidateModel {
  String id;
  String fullName;
  String? maskedName;
  String phone;
  String email;
  int age;
  String role;
  int experienceYears;
  double? currentCtc;
  double? expectedCtc;
  String state;
  String city;
  String education;
  String skills;
  String? resumeUrl;
  String? videoIntroUrl;
  String? profileImageUrl;
  bool isUnlocked;
  bool isAvailableForHiring;
  DateTime createdAt;

  factory CandidateModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

### Recruiter Model

```dart
class RecruiterModel {
  String id;
  String fullName;
  String companyName;
  String designation;
  String phone;
  String? companyWebsite;
  String companySize;
  int totalSpent;
  bool isVerified;
  DateTime createdAt;

  factory RecruiterModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

### Wallet Model

```dart
class WalletModel {
  String id;
  int balance;
  int totalSpent;
  DateTime createdAt;
  DateTime updatedAt;

  factory WalletModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

### Transaction Model

```dart
class TransactionModel {
  String id;
  String type; // CREDIT | DEBIT
  int amount;
  String description;
  String? paymentReference;
  int balanceAfter;
  DateTime createdAt;

  factory TransactionModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

### Subscription Models

**Subscription Plan:**
```dart
class SubscriptionPlan {
  String id;
  String name;
  String description;
  String planType; // MONTHLY | QUARTERLY | YEARLY
  int durationDays;
  String price;
  bool isUnlimited;
  int? creditsLimit;
  List<String> features;
  bool isActive;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json);
}
```

**Subscription:**
```dart
class Subscription {
  String id;
  SubscriptionPlan plan;
  String status; // PENDING | ACTIVE | EXPIRED | CANCELLED
  DateTime startDate;
  DateTime endDate;
  int daysRemaining;
  int creditsUsed;
  int? creditsLimit;
  String paymentReference;

  factory Subscription.fromJson(Map<String, dynamic> json);
}
```

---

### Pagination Model

```dart
class PaginationModel {
  int count;
  int page;
  int pageSize;
  int totalPages;
  String? next;
  String? previous;

  factory PaginationModel.fromJson(Map<String, dynamic> json);
}
```

---

## 32. UI Components

### Candidate Card

**File:** `lib/views/screens/widgets/candidate_card_widget.dart`

```dart
class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: candidate.profileImageUrl != null
            ? NetworkImage(candidate.profileImageUrl!)
            : null,
          child: candidate.profileImageUrl == null
            ? Text(candidate.fullName[0])
            : null,
        ),
        title: Text(
          candidate.isUnlocked
            ? candidate.fullName
            : candidate.maskedName ?? 'Hidden',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${candidate.experienceYears} years'),
            Text('${candidate.city}, ${candidate.state}'),
          ],
        ),
        trailing: candidate.isUnlocked
          ? Icon(Icons.lock_open, color: Colors.green)
          : Column(
              children: [
                Icon(Icons.lock),
                Text('10 credits', style: TextStyle(fontSize: 10)),
              ],
            ),
        onTap: onTap,
      ),
    );
  }
}
```

---

### Category Card

**File:** `lib/views/screens/widgets/category_card_widget.dart`

```dart
class CategoryCard extends StatelessWidget {
  final String name;
  final int count;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('$count profiles', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Search Bar

**File:** `lib/views/screens/widgets/search_bar.dart`

```dart
class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;

  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
      ),
      onChanged: _onSearchChanged,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }
}
```

---

### Subscription Status Banner

**File:** `lib/views/screens/widgets/subscription_status_banner.dart`

```dart
class SubscriptionStatusBanner extends StatelessWidget {
  final Subscription subscription;

  Widget build(BuildContext context) {
    Color color;
    String message;

    if (subscription.daysRemaining > 7) {
      color = Colors.green;
      message = 'Active';
    } else if (subscription.daysRemaining > 3) {
      color = Colors.orange;
      message = 'Expiring Soon';
    } else {
      color = Colors.red;
      message = 'Critical';
    }

    return Container(
      color: color,
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.white),
          SizedBox(width: 8),
          Text(
            '${subscription.plan.name} - $message (${subscription.daysRemaining} days)',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
```

---

### Refresh Indicator Wrapper

**File:** `lib/views/screens/widgets/refresh_indicator_wrapper.dart`

```dart
class RefreshIndicatorWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
```

---

## 33. Theme & Styling

### Theme Controller

**File:** `lib/controllers/theme_controller.dart`

```dart
class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light
    );
    _saveTheme();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
  }
}
```

---

### Theme Data

```dart
class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color(0xFF121212),
  );
}
```

---

### Usage

```dart
GetMaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

---

## 34. Error Handling

### Error Handler

```dart
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
          return 'Connection timeout. Please try again.';

        case DioErrorType.response:
          return _handleResponse(error.response);

        default:
          return 'Network error. Check your connection.';
      }
    }

    return error.toString();
  }

  static String _handleResponse(Response? response) {
    if (response == null) return 'Unknown error';

    final data = response.data;
    if (data is Map) {
      if (data['non_field_errors'] != null) {
        return data['non_field_errors'][0];
      }
      if (data['message'] != null) return data['message'];
      if (data['error'] != null) return data['error'];
      if (data['detail'] != null) return data['detail'];
    }

    return 'Error: ${response.statusCode}';
  }
}
```

---

### User-Friendly Messages

| Server Error | User Message |
|--------------|--------------|
| "username already exists" | "Username taken. Choose another." |
| "email already registered" | "Email registered. Please login." |
| "invalid credentials" | "Invalid email or password." |
| "otp expired" | "OTP expired. Request a new one." |
| Network error | "Connection failed. Check internet." |

---

### Usage in Controllers

```dart
try {
  await _apiService.login(email, password);
} catch (e) {
  String message = ErrorHandler.getErrorMessage(e);
  Get.snackbar('Error', message);
}
```

---

# Part 6: Testing & Deployment

## 35. Testing Notifications

### Test Direct Notification

```dart
static Future<void> testDirectNotification() async {
  RemoteMessage testMessage = RemoteMessage(
    notification: RemoteNotification(
      title: 'Test Notification',
      body: 'This is a test from Workfina',
    ),
    data: {
      'type': 'TEST',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  await _showLocalNotification(testMessage);
  print('Test notification sent');
}
```

---

### Debug FCM Token

Token printed in console during development:

```
[log] FCM Token: fL3Ck8xRQvG-9qY...
```

**Use for:**
- Firebase Console testing
- Postman testing
- Server debugging

---

### Firebase Console Testing

1. Go to Firebase Console
2. Select project
3. Navigate to Cloud Messaging
4. Click "Send test message"
5. Enter FCM token from logs
6. Enter title and body
7. Send notification

---

## 36. Troubleshooting

### Notifications Not Received

**Checklist:**
- ✅ FCM token generated?
- ✅ Token uploaded to server?
- ✅ Permissions granted?
- ✅ Firebase initialized?
- ✅ Background handler registered?
- ✅ Internet connection active?

---

### iOS Notifications Not Working

**Checklist:**
- ✅ APNS certificate in Firebase Console
- ✅ Push Notifications capability enabled
- ✅ Correct bundle ID
- ✅ Entitlements set to `production` for release
- ✅ Using real device (simulator doesn't support)

---

### Android Notifications Not Showing

**Checklist:**
- ✅ Notification channel created
- ✅ `google-services.json` present
- ✅ Firebase dependencies in build.gradle
- ✅ Permissions in AndroidManifest
- ✅ Battery optimization disabled
- ✅ Channel not manually disabled

---

### Foreground Notifications Not Displaying

**Checklist:**
- ✅ `onMessage` listener registered
- ✅ `_handleForegroundMessage()` called
- ✅ Local notifications initialized
- ✅ Permissions granted

---

### Background Handler Not Called

**Checklist:**
- ✅ Function is top-level
- ✅ `@pragma('vm:entry-point')` present
- ✅ Firebase initialized in handler
- ✅ Handler registered before `runApp()`

---

### Token Not Uploading

**Checklist:**
- ✅ API endpoint exists
- ✅ User authenticated
- ✅ `uploadFCMToken()` called after login
- ✅ Network connectivity
- ✅ Check API logs

---

## 37. Best Practices

### 1. Permission Timing
✅ Request after showing value
✅ Don't request on app launch
❌ Don't spam requests

### 2. Token Management
✅ Upload immediately after login
✅ Store locally for comparison
✅ Re-upload on token refresh
❌ Don't upload on every launch

### 3. Notification Handling
✅ Show local for foreground
✅ Handle all app states
✅ Implement click navigation
❌ Don't ignore data payload

### 4. User Experience
✅ Clear notification titles
✅ Actionable bodies
✅ Proper grouping
❌ Don't spam users

### 5. Testing
✅ Test on real devices
✅ Test all app states
✅ Test permission flows
✅ Test token refresh

---

## 38. Quick Reference

### API Base URL
```
Development: http://192.168.0.130:8000/api
Production: [UPDATE FOR PRODUCTION]
```

### Authentication Header
```
Authorization: Bearer {access_token}
```

### Common Headers
```json
{
  "Content-Type": "application/json",
  "Accept": "application/json"
}
```

### Total API Endpoints: 50+

**Categories:**
- Authentication: 8
- Candidates: 6
- Recruiters: 3
- Location: 2
- Search & Filter: 6
- Management: 7
- Wallet: 3
- Subscriptions: 5
- Notifications: 5
- Miscellaneous: 2

---

### Key Technologies

**Frontend:**
- Flutter 3.x
- Dart 3.x
- GetX (State Management)
- Dio (HTTP Client)

**Backend:**
- RESTful APIs
- JWT Authentication
- Django (assumed)

**Notifications:**
- Firebase Cloud Messaging
- flutter_local_notifications

---

### File Locations

**Controllers:** `lib/controllers/`
**Models:** `lib/models/`
**Services:** `lib/services/`
**Screens:** `lib/views/screens/`
**Widgets:** `lib/views/screens/widgets/`

---

### Common Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 500 | Server Error |

---

### Token Refresh
- **Buffer:** 30 seconds before expiry
- **Auto-refresh:** On every request
- **Fallback:** On 401 error
- **Logout:** If refresh fails

---

### Credit System
- **Unlock Cost:** 10 credits
- **Priority:** Subscription → Wallet
- **Insufficient:** Error + Recharge prompt

---

### Subscription Plans
- **Basic:** ₹999/month (50 unlocks)
- **Professional:** ₹2,499/quarter (150 unlocks)
- **Enterprise:** ₹9,999/year (Unlimited)

---

## Summary

This documentation covers:

✅ **Complete API Reference** - All 50+ endpoints with examples
✅ **Frontend Architecture** - Controllers, models, screens
✅ **Notification System** - FCM setup, handlers, platform configs
✅ **Authentication Flow** - JWT, token management
✅ **Feature Documentation** - Candidate, recruiter, wallet, subscription
✅ **State Management** - GetX patterns
✅ **UI Components** - Reusable widgets
✅ **Error Handling** - User-friendly messages
✅ **Testing Guide** - Notification testing
✅ **Troubleshooting** - Common issues & fixes
✅ **Best Practices** - Development guidelines

---

**Version:** 1.0.0
**Last Updated:** January 2026
**Maintained By:** Workfina Development Team

---

## Support

For questions or issues:
- **Documentation:** This file
- **Bug Reports:** Contact development team
- **Feature Requests:** Contact product team

---

**End of Documentation**
