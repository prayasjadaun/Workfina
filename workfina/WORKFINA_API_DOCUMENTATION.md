# WORKFINA - Complete API Documentation

> **Version:** 1.0.0
> **Last Updated:** January 2026
> **Platform:** Flutter (Android & iOS)

---

## Table of Contents

1. [API Configuration](#1-api-configuration)
2. [Authentication & Token Management](#2-authentication--token-management)
3. [Authentication APIs](#3-authentication-apis)
4. [Candidate APIs](#4-candidate-apis)
5. [Location APIs](#5-location-apis)
6. [Recruiter APIs](#6-recruiter-apis)
7. [Candidate Search & Filtering APIs](#7-candidate-search--filtering-apis)
8. [Candidate Unlock & Management APIs](#8-candidate-unlock--management-apis)
9. [Wallet APIs](#9-wallet-apis)
10. [Subscription APIs](#10-subscription-apis)
11. [Notification APIs](#11-notification-apis)
12. [Miscellaneous APIs](#12-miscellaneous-apis)
13. [Request/Response Structures](#13-requestresponse-structures)
14. [Error Handling](#14-error-handling)
15. [Status Codes Reference](#15-status-codes-reference)

---

## 1. API Configuration

### Base URLs

**Development Environment:**
```
Real Device:    http://192.168.0.130:8000/api
Simulator/Mac:  http://localhost:8000/api
```

**Production Environment:**
```
Production:     http://localhost:8000/api (UPDATE THIS FOR PRODUCTION)
```

**Media Base URLs:**
```
Real Device:    http://192.168.0.130:8000
Simulator/Mac:  http://localhost:8000
```

### HTTP Client Setup

**Library Used:** Dio (HTTP client for Dart)

**Timeouts:**
- Connect Timeout: 60 seconds
- Receive Timeout: 60 seconds
- Send Timeout: 60 seconds

### Default Request Headers

```json
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "Authorization": "Bearer {access_token}"
}
```

**For File Uploads (Multipart):**
```json
{
  "Authorization": "Bearer {access_token}",
  "Content-Type": "multipart/form-data"
}
```

---

## 2. Authentication & Token Management

### JWT Token System

Workfina uses **JWT (JSON Web Tokens)** for authentication with access and refresh tokens.

**Token Storage Location:**
- **Access Token:** SharedPreferences key: `access_token`
- **Refresh Token:** SharedPreferences key: `refresh_token`
- **User Data:** SharedPreferences key: `user_data` (JSON string)

### Token Lifecycle

1. **Login/Signup** → Server returns access + refresh tokens
2. **Store tokens** in SharedPreferences
3. **Every API request** → Add access token to Authorization header
4. **Before each request** → Check token expiry (30-second buffer)
5. **If expiring soon** → Refresh token automatically
6. **On 401 error** → Attempt token refresh → Retry request
7. **If refresh fails** → Logout user

### Automatic Token Refresh Flow

```
Request Interceptor:
├── Check access token expiry
├── If expires in < 30 seconds:
│   ├── Call /auth/refresh/ with refresh token
│   ├── Get new access token
│   ├── Update stored token
│   └── Continue with original request
└── Add Bearer token to Authorization header

Response Error Interceptor:
├── If 401 Unauthorized:
│   ├── Attempt token refresh
│   ├── If successful → Retry original request
│   └── If failed → Logout user
```

### Token Validation

**Access Token Expiry Check:**
```dart
// Decodes JWT payload
// Checks 'exp' claim
// Returns true if token expires in < 30 seconds
```

**Buffer Time:** 30 seconds before actual expiry to prevent race conditions

---

## 3. Authentication APIs

### 3.1 Send OTP

**Endpoint:** `POST /auth/send-otp/`
**Authentication Required:** No
**Headers:** Default JSON headers

**Description:**
Sends a One-Time Password (OTP) to the user's email for verification during signup.

**Request Body:**
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

*Email Already Exists:*
```json
{
  "error": "Email already exists"
}
```

*Validation Error:*
```json
{
  "non_field_errors": ["Invalid email format"]
}
```

**Status Codes:**
- `200` - OTP sent successfully
- `400` - Validation error
- `500` - Server error

---

### 3.2 Verify OTP

**Endpoint:** `POST /auth/verify-otp/`
**Authentication Required:** No
**Headers:** Default JSON headers

**Description:**
Verifies the OTP sent to user's email. Does not create account, only validates OTP.

**Request Body:**
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

*Invalid OTP:*
```json
{
  "error": "Invalid OTP"
}
```

*OTP Expired:*
```json
{
  "non_field_errors": ["OTP expired. Please request a new one."]
}
```

**Status Codes:**
- `200` - OTP valid
- `400` - Invalid or expired OTP

---

### 3.3 Create Account

**Endpoint:** `POST /auth/create-account/`
**Authentication Required:** No
**Headers:** Default JSON headers

**Description:**
Creates a new user account after OTP verification. Returns access and refresh tokens.

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "SecurePassword123!",
  "confirm_password": "SecurePassword123!"
}
```

**Validation Rules:**
- Email: Must be valid and verified with OTP
- Username: 3-150 characters, unique, alphanumeric + underscores
- Password: Minimum 8 characters
- Confirm Password: Must match password

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

*Username Taken:*
```json
{
  "username": ["This username is already taken"]
}
```

*Email Already Registered:*
```json
{
  "email": ["This email is already registered"]
}
```

*Passwords Don't Match:*
```json
{
  "non_field_errors": ["Passwords do not match"]
}
```

**Status Codes:**
- `200` - Account created successfully
- `400` - Validation error

---

### 3.4 Login

**Endpoint:** `POST /auth/login/`
**Authentication Required:** No
**Headers:** Default JSON headers

**Description:**
Authenticates existing user with email and password. Returns tokens and user data.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
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

**Error Responses:**

*Invalid Credentials:*
```json
{
  "error": "Invalid credentials"
}
```

*Account Not Found:*
```json
{
  "email": ["No account found with this email"]
}
```

*Incorrect Password:*
```json
{
  "password": ["Incorrect password"]
}
```

**Status Codes:**
- `200` - Login successful
- `400` - Validation error
- `401` - Invalid credentials

---

### 3.5 Refresh Token

**Endpoint:** `POST /auth/refresh/`
**Authentication Required:** No (uses refresh token)
**Headers:** Default JSON headers

**Description:**
Generates a new access token using the refresh token. Called automatically by the app when access token expires.

**Request Body:**
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

**Error Responses:**

*Invalid Refresh Token:*
```json
{
  "error": "Token refresh failed"
}
```

**Status Codes:**
- `200` - New access token generated
- `401` - Invalid refresh token (requires re-login)

**Note:** If refresh fails, user is automatically logged out by the app.

---

### 3.6 Logout

**Endpoint:** `POST /auth/logout/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Invalidates the user's refresh token on the server. Client should also clear local tokens.

**Request Body:**
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

**Status Codes:**
- `200` - Logout successful
- `401` - Invalid token

---

### 3.7 Update User Role

**Endpoint:** `PATCH /auth/update-role/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Updates the user's role (CANDIDATE or RECRUITER). This is done after initial account creation during role selection.

**Request Body:**
```json
{
  "role": "RECRUITER"
}
```

**Valid Roles:**
- `CANDIDATE`
- `RECRUITER`

**Success Response (200):**
```json
{
  "message": "Role updated successfully"
}
```

**Error Responses:**

*Invalid Role:*
```json
{
  "role": ["Invalid role. Must be CANDIDATE or RECRUITER"]
}
```

**Status Codes:**
- `200` - Role updated
- `400` - Invalid role value

---

### 3.8 Update FCM Token

**Endpoint:** `POST /auth/update-fcm-token/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Uploads the device's Firebase Cloud Messaging token to enable push notifications.

**Request Body:**
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

**Status Codes:**
- `200` - Token updated successfully
- `401` - Unauthorized

**Note:** This is called automatically after login in the app.

---

## 4. Candidate APIs

### 4.1 Register Candidate

**Endpoint:** `POST /candidates/register/`
**Authentication Required:** Yes
**Headers:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "multipart/form-data"
}
```

**Description:**
Creates a complete candidate profile with personal details, resume, and optional video introduction.

**Request Body (FormData):**

```
full_name: "John Doe"
phone: "+919876543210"
age: 25
role: "Software Engineer"
experience_years: 3
current_ctc: 500000.00
expected_ctc: 800000.00
religion: "Hindu"
country: "India"
state: "Maharashtra"
city: "Mumbai"
education: "B.Tech: Computer Science, XYZ University (2019) - 85%"
skills: "Python, Django, React, PostgreSQL"
languages: "English, Hindi, Marathi"
street_address: "123 Main Street, Andheri West"
willing_to_relocate: true
work_experience: "Worked at ABC Corp as Software Engineer for 3 years. Developed web applications using Django and React."
career_objective: "Looking for senior software engineer role with focus on backend development"
resume: File (PDF file)
video_intro: File (Video file - optional)
profile_image: File (Image file - optional)
```

**Field Details:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| full_name | String | Yes | Full name |
| phone | String | Yes | Phone with country code |
| age | Integer | Yes | Age in years |
| role | String | Yes | Job role/title |
| experience_years | Integer | Yes | Years of experience |
| current_ctc | Decimal | No | Current salary (annual) |
| expected_ctc | Decimal | No | Expected salary (annual) |
| religion | String | No | Religion |
| country | String | Yes | Country name |
| state | String | Yes | State name |
| city | String | Yes | City name |
| education | String | Yes | Education history |
| skills | String | Yes | Comma-separated skills |
| languages | String | No | Known languages |
| street_address | String | No | Full address |
| willing_to_relocate | Boolean | No | Relocation willingness |
| work_experience | String | Yes | Work experience details |
| career_objective | String | No | Career goals |
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
  "current_ctc": 500000.00,
  "expected_ctc": 800000.00,
  "state": "Maharashtra",
  "city": "Mumbai",
  "education": "B.Tech: Computer Science, XYZ University (2019) - 85%",
  "skills": "Python, Django, React, PostgreSQL",
  "resume_url": "http://localhost:8000/media/resumes/john_doe_resume.pdf",
  "video_intro_url": "http://localhost:8000/media/videos/john_doe_intro.mp4",
  "profile_image_url": "http://localhost:8000/media/images/john_doe.jpg",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Error Responses:**

*Validation Error:*
```json
{
  "error": "Registration failed",
  "message": "Validation error",
  "phone": ["Invalid phone number format"]
}
```

**Status Codes:**
- `200` - Registration successful
- `400` - Validation error
- `401` - Unauthorized

---

### 4.2 Get Candidate Profile

**Endpoint:** `GET /candidates/profile/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Retrieves the authenticated candidate's complete profile information.

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
  "religion": "Hindu",
  "country": "India",
  "state": "Maharashtra",
  "city": "Mumbai",
  "education": "B.Tech: Computer Science, XYZ University (2019) - 85%",
  "skills": "Python, Django, React, PostgreSQL",
  "languages": "English, Hindi, Marathi",
  "street_address": "123 Main Street, Andheri West",
  "willing_to_relocate": true,
  "work_experience": "Worked at ABC Corp as Software Engineer for 3 years...",
  "career_objective": "Looking for senior software engineer role...",
  "resume_url": "http://localhost:8000/media/resumes/john_doe_resume.pdf",
  "video_intro_url": "http://localhost:8000/media/videos/john_doe_intro.mp4",
  "profile_image_url": "http://localhost:8000/media/images/john_doe.jpg",
  "is_available_for_hiring": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T00:00:00Z"
}
```

**Status Codes:**
- `200` - Profile retrieved
- `401` - Unauthorized
- `404` - Profile not found

---

### 4.3 Update Candidate Profile

**Endpoint:** `PUT /candidates/profile/update/`
**Authentication Required:** Yes
**Headers:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "multipart/form-data"
}
```

**Description:**
Updates the candidate's profile. All fields are optional - only send fields that need to be updated.

**Request Body (FormData):**
Same fields as registration, all optional. Include files only if updating them.

**Success Response (200):**
```json
{
  "profile": {
    "id": "456",
    "full_name": "John Doe Updated",
    "phone": "+919876543210",
    ...
  }
}
```

**Status Codes:**
- `200` - Profile updated
- `400` - Validation error
- `401` - Unauthorized

---

### 4.4 Get Candidate Availability

**Endpoint:** `GET /candidates/availability/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Checks if candidate is currently available for hiring (visible to recruiters).

**Success Response (200):**
```json
{
  "is_available_for_hiring": true
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 4.5 Update Candidate Availability

**Endpoint:** `POST /candidates/availability/update/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Toggles candidate's hiring availability. When false, profile is hidden from recruiters.

**Request Body:**
```json
{
  "is_available_for_hiring": false
}
```

**Success Response (200):**
```json
{
  "message": "Availability updated successfully",
  "is_available_for_hiring": false
}
```

**Status Codes:**
- `200` - Updated successfully
- `401` - Unauthorized

---

### 4.6 Save Candidate Step

**Endpoint:** `POST /candidates/save-step/`
**Authentication Required:** Yes
**Headers:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "multipart/form-data"
}
```

**Description:**
Saves candidate profile data step-by-step during multi-step registration flow.

**Request Body:**
```
step: 1
full_name: "John Doe"
phone: "+919876543210"
... (other fields for this step)
```

**Success Response (200):**
```json
{
  "message": "Step saved successfully"
}
```

**Status Codes:**
- `200` - Step saved
- `400` - Validation error
- `401` - Unauthorized

**Note:** Used in the multi-step candidate setup screen.

---

## 5. Location APIs

### 5.1 Get States

**Endpoint:** `GET /candidates/locations/states/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns list of all available states for candidate location selection.

**Success Response (200):**
```json
{
  "states": [
    {
      "name": "Maharashtra",
      "slug": "maharashtra"
    },
    {
      "name": "Delhi",
      "slug": "delhi"
    },
    {
      "name": "Karnataka",
      "slug": "karnataka"
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 5.2 Get Cities

**Endpoint:** `GET /candidates/locations/cities/?state={state_slug}`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns list of cities for a specific state.

**Query Parameters:**
- `state` (required): State slug (e.g., "maharashtra")

**Example Request:**
```
GET /candidates/locations/cities/?state=maharashtra
```

**Success Response (200):**
```json
{
  "cities": [
    {
      "name": "Mumbai",
      "slug": "mumbai"
    },
    {
      "name": "Pune",
      "slug": "pune"
    },
    {
      "name": "Nagpur",
      "slug": "nagpur"
    }
  ]
}
```

**Error Responses:**

*Missing State Parameter:*
```json
{
  "error": "State parameter is required"
}
```

**Status Codes:**
- `200` - Success
- `400` - Missing parameter
- `401` - Unauthorized

---

## 6. Recruiter APIs

### 6.1 Register Recruiter

**Endpoint:** `POST /recruiters/register/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Creates a recruiter profile with company information. User must have RECRUITER role.

**Request Body:**
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

**Field Details:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| full_name | String | Yes | Recruiter's full name |
| company_name | String | Yes | Company name |
| designation | String | Yes | Job title/designation |
| phone | String | Yes | Phone with country code |
| company_website | String | No | Company website URL |
| company_size | String | Yes | Employee count range |

**Company Size Options:**
- "1-10"
- "10-50"
- "50-100"
- "100-500"
- "500+"

**Success Response (200):**
```json
{
  "id": "789",
  "full_name": "Jane Smith",
  "company_name": "Tech Corp Pvt Ltd",
  "designation": "HR Manager",
  "phone": "+919876543210",
  "company_website": "https://techcorp.com",
  "company_size": "50-100",
  "total_spent": 0,
  "is_verified": false,
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Status Codes:**
- `200` - Registration successful
- `400` - Validation error
- `401` - Unauthorized

**Note:** `is_verified` will be false initially. Admin verification required before accessing candidates.

---

### 6.2 Get Recruiter Profile

**Endpoint:** `GET /recruiters/profile/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Retrieves the authenticated recruiter's profile information.

**Success Response (200):**
```json
{
  "id": "789",
  "full_name": "Jane Smith",
  "company_name": "Tech Corp Pvt Ltd",
  "designation": "HR Manager",
  "phone": "+919876543210",
  "company_website": "https://techcorp.com",
  "company_size": "50-100",
  "total_spent": 150,
  "is_verified": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T00:00:00Z"
}
```

**Status Codes:**
- `200` - Profile retrieved
- `401` - Unauthorized
- `404` - Profile not found

---

### 6.3 Update Recruiter Profile

**Endpoint:** `PATCH /recruiters/profile/update/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Updates recruiter profile information. All fields are optional.

**Request Body:**
```json
{
  "full_name": "Jane Smith Updated",
  "company_name": "Tech Corp Ltd",
  "designation": "Senior HR Manager",
  "phone": "+919876543210",
  "company_website": "https://techcorp.com",
  "company_size": "100-500"
}
```

**Success Response (200):**
```json
{
  "id": "789",
  "full_name": "Jane Smith Updated",
  "company_name": "Tech Corp Ltd",
  ...
}
```

**Status Codes:**
- `200` - Profile updated
- `400` - Validation error
- `401` - Unauthorized

---

## 7. Candidate Search & Filtering APIs

### 7.1 Get Filter Options

**Endpoint:** `GET /candidates/filter-options/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns all available filter options for candidate search (roles, cities, states, skills, etc.).

**Success Response (200):**
```json
{
  "roles": [
    "Software Engineer",
    "Data Scientist",
    "DevOps Engineer",
    "Product Manager"
  ],
  "cities": [
    "Mumbai",
    "Pune",
    "Bangalore",
    "Delhi"
  ],
  "states": [
    "Maharashtra",
    "Karnataka",
    "Delhi"
  ],
  "countries": [
    "India"
  ],
  "religions": [
    "Hindu",
    "Muslim",
    "Christian",
    "Sikh",
    "Buddhist"
  ],
  "educations": [
    "B.Tech",
    "M.Tech",
    "MBA",
    "BCA",
    "MCA"
  ],
  "skills": [
    "Python",
    "Java",
    "React",
    "Angular",
    "Node.js"
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 7.2 Get Specific Filter Options (Paginated)

**Endpoint:** `GET /candidates/filter-options/?type={type}&page={page}&page_size={size}&search={query}`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns paginated filter options for a specific type with optional search.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| type | Yes | Filter type (roles, cities, states, skills, etc.) |
| page | No | Page number (default: 1) |
| page_size | No | Results per page (default: 20) |
| search | No | Search query |

**Example Request:**
```
GET /candidates/filter-options/?type=skills&page=1&page_size=20&search=python
```

**Success Response (200):**
```json
{
  "results": [
    "Python",
    "Python Django",
    "Python Flask"
  ],
  "count": 3,
  "next": null,
  "previous": null
}
```

**Status Codes:**
- `200` - Success
- `400` - Invalid type parameter
- `401` - Unauthorized

---

### 7.3 Get Filter Categories

**Endpoint:** `GET /candidates/filter-categories/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns main job categories with candidate counts.

**Success Response (200):**
```json
{
  "categories": [
    {
      "name": "Technology",
      "slug": "technology",
      "count": 150
    },
    {
      "name": "Marketing",
      "slug": "marketing",
      "count": 75
    },
    {
      "name": "Sales",
      "slug": "sales",
      "count": 60
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 7.4 Get Category Subcategories

**Endpoint:** `GET /candidates/filter-options/?category={category_slug}`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns subcategories for a specific main category.

**Query Parameters:**
- `category` (required): Category slug

**Example Request:**
```
GET /candidates/filter-options/?category=technology
```

**Success Response (200):**
```json
{
  "subcategories": [
    {
      "name": "Software Development",
      "slug": "software-development",
      "count": 100
    },
    {
      "name": "Data Science",
      "slug": "data-science",
      "count": 50
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `400` - Invalid category
- `401` - Unauthorized

---

### 7.5 Get Departments and Religions

**Endpoint:** `GET /candidates/public/filter-options/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns list of departments and religions for filtering.

**Success Response (200):**
```json
{
  "departments": [
    "Engineering",
    "Marketing",
    "Sales",
    "Finance",
    "Operations"
  ],
  "religions": [
    "Hindu",
    "Muslim",
    "Christian",
    "Sikh",
    "Buddhist",
    "Jain"
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 7.6 Get Filtered Candidates

**Endpoint:** `GET /recruiters/candidates/filter/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns paginated list of candidates matching filter criteria. Locked candidates show masked information.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| role | String | Job role filter |
| min_experience | Integer | Minimum years of experience |
| max_experience | Integer | Maximum years of experience |
| min_age | Integer | Minimum age |
| max_age | Integer | Maximum age |
| city | String | City name |
| state | String | State name |
| country | String | Country name |
| religion | String | Religion filter |
| education | String | Education level |
| skills | String | Comma-separated skills |
| min_ctc | Decimal | Minimum current CTC |
| max_ctc | Decimal | Maximum current CTC |
| page | Integer | Page number (default: 1) |
| page_size | Integer | Results per page (default: 20) |

**Example Request:**
```
GET /recruiters/candidates/filter/?role=Software%20Engineer&min_experience=2&max_experience=5&city=Mumbai&page=1
```

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
      "current_ctc": 500000.00,
      "expected_ctc": 800000.00,
      "state": "Maharashtra",
      "city": "Mumbai",
      "skills": "Python, Django, React",
      "profile_image_url": "http://localhost:8000/media/images/john_doe.jpg",
      "is_unlocked": false,
      "unlock_cost": 10,
      "created_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": "457",
      "full_name": "Jane Williams",
      "masked_name": null,
      "phone": "+919876543210",
      "email": "jane@example.com",
      "age": 28,
      "role": "Software Engineer",
      "experience_years": 5,
      "current_ctc": 800000.00,
      "expected_ctc": 1200000.00,
      "state": "Maharashtra",
      "city": "Mumbai",
      "skills": "Java, Spring Boot, Microservices",
      "profile_image_url": "http://localhost:8000/media/images/jane.jpg",
      "resume_url": "http://localhost:8000/media/resumes/jane_resume.pdf",
      "is_unlocked": true,
      "unlock_cost": 0,
      "unlocked_at": "2024-01-10T00:00:00Z",
      "created_at": "2024-01-05T00:00:00Z"
    }
  ],
  "pagination": {
    "count": 150,
    "page": 1,
    "page_size": 20,
    "total_pages": 8,
    "next": "http://localhost:8000/api/recruiters/candidates/filter/?page=2",
    "previous": null
  }
}
```

**Locked vs Unlocked Candidates:**

**Locked (is_unlocked: false):**
- `masked_name`: "J*** D**"
- `phone`: "******3210"
- `email`: "j***@example.com"
- `resume_url`: Not included
- `video_intro_url`: Not included

**Unlocked (is_unlocked: true):**
- `masked_name`: null
- Full contact information visible
- Resume and video URLs included
- `unlocked_at`: Timestamp of unlock

**Status Codes:**
- `200` - Success
- `400` - Invalid filter parameters
- `401` - Unauthorized

---

## 8. Candidate Unlock & Management APIs

### 8.1 Unlock Candidate

**Endpoint:** `POST /candidates/{candidate_id}/unlock/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Unlocks a candidate's full profile for the recruiter. Costs 10 credits. Deducts from subscription first (if active), then wallet.

**URL Parameters:**
- `candidate_id`: Candidate's unique ID

**Example Request:**
```
POST /candidates/456/unlock/
```

**Success Response (200):**

*First Time Unlock:*
```json
{
  "message": "Candidate unlocked successfully",
  "candidate": {
    "id": "456",
    "full_name": "John Doe",
    "phone": "+919876543210",
    "email": "john@example.com",
    "age": 25,
    "role": "Software Engineer",
    "experience_years": 3,
    "current_ctc": 500000.00,
    "expected_ctc": 800000.00,
    "resume_url": "http://localhost:8000/media/resumes/john_resume.pdf",
    "video_intro_url": "http://localhost:8000/media/videos/john_intro.mp4",
    ...
  },
  "credits_used": 10,
  "remaining_balance": 90,
  "already_unlocked": false
}
```

*Already Unlocked:*
```json
{
  "message": "Candidate already unlocked",
  "candidate": { ... },
  "credits_used": 0,
  "remaining_balance": 90,
  "already_unlocked": true
}
```

**Error Responses:**

*Insufficient Credits:*
```json
{
  "error": "Insufficient credits",
  "detail": "You need 10 credits to unlock this candidate. Current balance: 5 credits."
}
```

*No Active Subscription or Wallet Balance:*
```json
{
  "error": "No active subscription or wallet balance",
  "detail": "Please recharge your wallet or subscribe to a plan"
}
```

**Credit Deduction Priority:**
1. Check for active subscription with remaining credits
2. If available, deduct from subscription
3. If not, deduct from wallet balance
4. If both insufficient, return error

**Status Codes:**
- `200` - Unlock successful
- `400` - Insufficient credits
- `401` - Unauthorized
- `404` - Candidate not found

---

### 8.2 Get Unlocked Candidates

**Endpoint:** `GET /candidates/unlocked/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns list of all candidates previously unlocked by the recruiter.

**Success Response (200):**
```json
{
  "unlocked_candidates": [
    {
      "id": "456",
      "full_name": "John Doe",
      "phone": "+919876543210",
      "email": "john@example.com",
      "role": "Software Engineer",
      "experience_years": 3,
      "current_ctc": 500000.00,
      "expected_ctc": 800000.00,
      "state": "Maharashtra",
      "city": "Mumbai",
      "skills": "Python, Django, React",
      "resume_url": "http://localhost:8000/media/resumes/john_resume.pdf",
      "video_intro_url": "http://localhost:8000/media/videos/john_intro.mp4",
      "profile_image_url": "http://localhost:8000/media/images/john.jpg",
      "unlocked_at": "2024-01-01T00:00:00Z",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 8.3 Add Candidate Note

**Endpoint:** `POST /candidates/{candidate_id}/note/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Adds a private note about a candidate (only visible to the recruiter who created it).

**URL Parameters:**
- `candidate_id`: Candidate's unique ID

**Request Body:**
```json
{
  "note_text": "Good candidate. Interviewed on 2024-01-15. Strong Python skills. Available for immediate joining."
}
```

**Success Response (200):**
```json
{
  "id": "note_123",
  "note_text": "Good candidate. Interviewed on 2024-01-15...",
  "created_at": "2024-01-15T10:30:00Z",
  "created_by": "Jane Smith"
}
```

**Status Codes:**
- `200` - Note added
- `400` - Validation error
- `401` - Unauthorized
- `404` - Candidate not found

---

### 8.4 Add Candidate Followup

**Endpoint:** `POST /candidates/{candidate_id}/followup/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Creates a follow-up reminder for a candidate with date and notes.

**URL Parameters:**
- `candidate_id`: Candidate's unique ID

**Request Body:**
```json
{
  "followup_date": "2024-01-25T10:00:00Z",
  "notes": "Schedule second round interview. Discuss salary expectations.",
  "is_completed": false
}
```

**Success Response (200):**
```json
{
  "id": "followup_123",
  "followup_date": "2024-01-25T10:00:00Z",
  "notes": "Schedule second round interview. Discuss salary expectations.",
  "is_completed": false,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Status Codes:**
- `200` - Follow-up created
- `400` - Validation error
- `401` - Unauthorized
- `404` - Candidate not found

---

### 8.5 Get Candidate Notes & Followups

**Endpoint:** `GET /candidates/{candidate_id}/notes-followups/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Retrieves all notes and follow-ups for a specific candidate.

**URL Parameters:**
- `candidate_id`: Candidate's unique ID

**Success Response (200):**
```json
{
  "notes": [
    {
      "id": "note_123",
      "note_text": "Good candidate. Strong technical skills.",
      "created_at": "2024-01-15T10:30:00Z",
      "created_by": "Jane Smith"
    },
    {
      "id": "note_124",
      "note_text": "Completed first round. Moving to technical interview.",
      "created_at": "2024-01-16T14:00:00Z",
      "created_by": "Jane Smith"
    }
  ],
  "followups": [
    {
      "id": "followup_123",
      "followup_date": "2024-01-25T10:00:00Z",
      "notes": "Schedule second round interview",
      "is_completed": false,
      "created_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": "followup_124",
      "followup_date": "2024-01-20T15:00:00Z",
      "notes": "Send offer letter",
      "is_completed": true,
      "created_at": "2024-01-18T09:00:00Z"
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized
- `404` - Candidate not found

---

### 8.6 Delete Candidate Note

**Endpoint:** `DELETE /candidates/{candidate_id}/note/{note_id}/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Deletes a specific note for a candidate.

**URL Parameters:**
- `candidate_id`: Candidate's unique ID
- `note_id`: Note's unique ID

**Success Response (200):**
```json
{
  "success": true
}
```

**Status Codes:**
- `200` - Note deleted
- `401` - Unauthorized
- `404` - Note not found

---

### 8.7 Delete Candidate Followup

**Endpoint:** `DELETE /candidates/{candidate_id}/followup/{followup_id}/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Deletes a specific follow-up reminder for a candidate.

**URL Parameters:**
- `candidate_id`: Candidate's unique ID
- `followup_id`: Follow-up's unique ID

**Success Response (200):**
```json
{
  "success": true
}
```

**Status Codes:**
- `200` - Follow-up deleted
- `401` - Unauthorized
- `404` - Follow-up not found

---

## 9. Wallet APIs

### 9.1 Get Wallet Balance

**Endpoint:** `GET /wallet/balance/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Retrieves the recruiter's current wallet balance and total spending.

**Success Response (200):**
```json
{
  "wallet": {
    "id": "wallet_123",
    "balance": 100,
    "total_spent": 50,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T00:00:00Z"
  }
}
```

**Field Descriptions:**
- `balance`: Current available credits
- `total_spent`: Total credits spent (all-time)

**Status Codes:**
- `200` - Success
- `401` - Unauthorized
- `404` - Wallet not found

---

### 9.2 Recharge Wallet

**Endpoint:** `POST /wallet/recharge/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Adds credits to the recruiter's wallet after payment confirmation.

**Request Body:**
```json
{
  "credits": 100,
  "payment_reference": "TXN123456789"
}
```

**Field Descriptions:**
- `credits`: Number of credits to add
- `payment_reference`: Payment gateway transaction ID

**Success Response (200):**
```json
{
  "message": "Wallet recharged successfully",
  "new_balance": 200,
  "transaction_id": "trans_123"
}
```

**Status Codes:**
- `200` - Recharge successful
- `400` - Invalid request
- `401` - Unauthorized

---

### 9.3 Get Wallet Transactions

**Endpoint:** `GET /wallet/transactions/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Retrieves complete transaction history for the recruiter's wallet.

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
      "payment_reference": null,
      "balance_after": 190,
      "created_at": "2024-01-15T14:30:00Z"
    },
    {
      "id": "trans_125",
      "type": "DEBIT",
      "amount": 10,
      "description": "Unlocked candidate: Jane Williams",
      "payment_reference": null,
      "balance_after": 180,
      "created_at": "2024-01-16T09:15:00Z"
    }
  ]
}
```

**Transaction Types:**
- `CREDIT`: Credits added (recharge)
- `DEBIT`: Credits deducted (candidate unlock)

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

## 10. Subscription APIs

### 10.1 Get Subscription Plans

**Endpoint:** `GET /subscriptions/plans/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns all available subscription plans for recruiters.

**Success Response (200):**
```json
{
  "plans": [
    {
      "id": "plan_1",
      "name": "Basic Plan",
      "description": "Perfect for small teams. Access 50 candidates per month.",
      "plan_type": "MONTHLY",
      "plan_type_display": "Monthly",
      "duration_days": 30,
      "price": "999.00",
      "is_unlimited": false,
      "credits_limit": 50,
      "is_active": true,
      "features": [
        "Access to 50 candidates",
        "Email support",
        "Basic filters"
      ],
      "created_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": "plan_2",
      "name": "Professional Plan",
      "description": "Best for growing companies. 150 candidates per month.",
      "plan_type": "QUARTERLY",
      "plan_type_display": "Quarterly",
      "duration_days": 90,
      "price": "2499.00",
      "is_unlimited": false,
      "credits_limit": 150,
      "is_active": true,
      "features": [
        "Access to 150 candidates",
        "Priority support",
        "Advanced filters",
        "Analytics dashboard"
      ],
      "created_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": "plan_3",
      "name": "Enterprise Plan",
      "description": "Unlimited access for large organizations.",
      "plan_type": "YEARLY",
      "plan_type_display": "Yearly",
      "duration_days": 365,
      "price": "9999.00",
      "is_unlimited": true,
      "credits_limit": null,
      "is_active": true,
      "features": [
        "Unlimited candidate access",
        "Dedicated account manager",
        "API access",
        "Custom integrations",
        "Priority support"
      ],
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

**Plan Types:**
- `MONTHLY` - 30 days duration
- `QUARTERLY` - 90 days duration
- `YEARLY` - 365 days duration

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 10.2 Get Current Subscription

**Endpoint:** `GET /subscriptions/subscriptions/current/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns the recruiter's currently active subscription with full details.

**Success Response (200):**
```json
{
  "id": "sub_123",
  "hr_profile": "789",
  "company_name": "Tech Corp Pvt Ltd",
  "company_email": "hr@techcorp.com",
  "plan": {
    "id": "plan_1",
    "name": "Basic Plan",
    "plan_type": "MONTHLY",
    "plan_type_display": "Monthly",
    "price": "999.00",
    "is_unlimited": false,
    "credits_limit": 50
  },
  "status": "ACTIVE",
  "status_display": "Active",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "days_remaining": 15,
  "warning_level": null,
  "is_currently_active": true,
  "has_unlimited": false,
  "credits_used": 25,
  "credits_remaining": 25,
  "payment_reference": "PAY123456",
  "approved_by": "admin_1",
  "approved_by_name": "Admin User",
  "approved_at": "2024-01-01T10:00:00Z",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T00:00:00Z"
}
```

**Subscription Statuses:**
- `PENDING` - Awaiting admin approval
- `ACTIVE` - Currently active
- `EXPIRED` - Past end date
- `CANCELLED` - Manually cancelled

**Warning Levels (based on days_remaining):**
- `null` - More than 7 days remaining
- `"warning"` - 3-7 days remaining
- `"critical"` - Less than 3 days remaining

**Error Response (404):**
```json
{
  "error": "No active subscription found",
  "status_code": 404
}
```

**Status Codes:**
- `200` - Active subscription found
- `401` - Unauthorized
- `404` - No active subscription

---

### 10.3 Get Subscription Status (Lightweight)

**Endpoint:** `GET /subscriptions/subscriptions/status/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns lightweight subscription status for quick checks (used in UI banners, dashboards).

**Success Response (200):**

*With Active Subscription:*
```json
{
  "has_subscription": true,
  "status": "ACTIVE",
  "plan": "Basic Plan",
  "plan_type": "MONTHLY",
  "expires_at": "2024-01-31T23:59:59Z",
  "days_remaining": 15,
  "is_unlimited": false,
  "credits_used": 25,
  "credits_limit": 50,
  "credits_remaining": 25,
  "warning_level": null
}
```

*Without Subscription:*
```json
{
  "has_subscription": false,
  "status": null,
  "plan": null,
  "plan_type": null,
  "expires_at": null,
  "days_remaining": null,
  "is_unlimited": false,
  "credits_used": 0,
  "credits_limit": null,
  "credits_remaining": null,
  "warning_level": null
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 10.4 Get All Subscriptions (History)

**Endpoint:** `GET /subscriptions/subscriptions/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns complete subscription history for the recruiter.

**Success Response (200):**
```json
{
  "subscriptions": [
    {
      "id": "sub_123",
      "plan": {
        "name": "Basic Plan",
        "plan_type": "MONTHLY",
        "plan_type_display": "Monthly"
      },
      "status": "ACTIVE",
      "status_display": "Active",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-01-31T23:59:59Z",
      "days_remaining": 15,
      "credits_used": 25,
      "created_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": "sub_122",
      "plan": {
        "name": "Basic Plan",
        "plan_type": "MONTHLY",
        "plan_type_display": "Monthly"
      },
      "status": "EXPIRED",
      "status_display": "Expired",
      "start_date": "2023-12-01T00:00:00Z",
      "end_date": "2023-12-31T23:59:59Z",
      "days_remaining": 0,
      "credits_used": 50,
      "created_at": "2023-12-01T00:00:00Z"
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 10.5 Get Subscription By ID

**Endpoint:** `GET /subscriptions/subscriptions/{subscription_id}/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns detailed information for a specific subscription.

**URL Parameters:**
- `subscription_id`: Subscription's unique ID

**Success Response (200):**
Same structure as "Get Current Subscription" (10.2)

**Status Codes:**
- `200` - Subscription found
- `401` - Unauthorized
- `404` - Subscription not found

---

## 11. Notification APIs

### 11.1 Get User Notifications

**Endpoint:** `GET /notifications/?page={page}`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns paginated list of notifications for the authenticated user.

**Query Parameters:**
- `page` (optional): Page number (default: 1)

**Success Response (200):**
```json
[
  {
    "id": "notif_123",
    "title": "Candidate Unlocked",
    "body": "You have successfully unlocked John Doe's profile",
    "type": "CANDIDATE_UNLOCK",
    "is_read": false,
    "data": {
      "candidate_id": "456",
      "candidate_name": "John Doe"
    },
    "created_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": "notif_124",
    "title": "Subscription Expiring Soon",
    "body": "Your subscription expires in 3 days",
    "type": "SUBSCRIPTION_WARNING",
    "is_read": true,
    "data": {
      "subscription_id": "sub_123",
      "days_remaining": 3
    },
    "created_at": "2024-01-14T09:00:00Z"
  },
  {
    "id": "notif_125",
    "title": "Welcome to Workfina",
    "body": "Thank you for joining Workfina. Complete your profile to get started.",
    "type": "GENERAL",
    "is_read": true,
    "data": null,
    "created_at": "2024-01-01T08:00:00Z"
  }
]
```

**Notification Types:**
- `CANDIDATE_UNLOCK` - Candidate unlocked
- `SUBSCRIPTION_WARNING` - Subscription expiry warning
- `SUBSCRIPTION_EXPIRED` - Subscription expired
- `WALLET_RECHARGE` - Wallet recharged
- `GENERAL` - General notifications

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 11.2 Get Notification Count

**Endpoint:** `GET /notifications/count/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns count of unread and total notifications.

**Success Response (200):**
```json
{
  "unread_count": 5,
  "total_count": 25
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 11.3 Mark Notification as Read

**Endpoint:** `POST /notifications/{notification_id}/read/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Marks a specific notification as read.

**URL Parameters:**
- `notification_id`: Notification's unique ID

**Success Response (200):**
```json
{
  "message": "Notification marked as read"
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized
- `404` - Notification not found

---

### 11.4 Mark All Notifications as Read

**Endpoint:** `POST /notifications/mark-all-read/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Marks all user's notifications as read.

**Success Response (200):**
```json
{
  "message": "All notifications marked as read",
  "count": 5
}
```

**Field Descriptions:**
- `count`: Number of notifications that were marked as read

**Status Codes:**
- `200` - Success
- `401` - Unauthorized

---

### 11.5 Send Test Notification

**Endpoint:** `POST /notifications/test/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Sends a test push notification to the user's device (for testing FCM integration).

**Request Body:**
```json
{
  "title": "Test Notification",
  "body": "This is a test notification from Workfina"
}
```

**Success Response (200):**
```json
{
  "message": "Test notification sent successfully"
}
```

**Status Codes:**
- `200` - Notification sent
- `400` - Invalid request
- `401` - Unauthorized

---

## 12. Miscellaneous APIs

### 12.1 Get Active Banner

**Endpoint:** `GET /banner/active/`
**Authentication Required:** Yes
**Headers:** Default + Bearer token

**Description:**
Returns the currently active promotional banner for display in the app.

**Success Response (200):**
```json
{
  "id": "banner_1",
  "title": "New Year Offer!",
  "button_text": "Get 50% Off",
  "image": "http://localhost:8000/media/banners/newyear_banner.jpg",
  "link": "https://workfina.com/offers/newyear",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

**No Active Banner:**
Returns `null` or `404`

**Status Codes:**
- `200` - Active banner found
- `401` - Unauthorized
- `404` - No active banner

---

### 12.2 Check App Version

**Endpoint:** `POST /app-version/check/`
**Authentication Required:** No
**Headers:** Default JSON headers

**Description:**
Checks if app update is required based on current version.

**Request Body:**
```json
{
  "current_version": "1.0.0",
  "platform": "android"
}
```

**Platforms:**
- `android`
- `ios`

**Success Response (200):**

*Update Required:*
```json
{
  "update_required": true,
  "force_update": false,
  "latest_version": "1.2.0",
  "message": "A new version is available with exciting features!",
  "download_url": "https://play.google.com/store/apps/details?id=com.workfina"
}
```

*No Update Required:*
```json
{
  "update_required": false,
  "force_update": false,
  "latest_version": "1.0.0",
  "message": "You're using the latest version",
  "download_url": null
}
```

**Field Descriptions:**
- `update_required`: Whether update is available
- `force_update`: If true, user must update to continue
- `latest_version`: Latest available version
- `message`: Message to show user
- `download_url`: App store/Play store URL

**Status Codes:**
- `200` - Version check successful
- `400` - Invalid request

---

## 13. Request/Response Structures

### Common Response Patterns

#### Success Response
```json
{
  "data_field": "value",
  "another_field": "value"
}
```

#### Error Response
```json
{
  "error": "User-friendly error message"
}
```

OR

```json
{
  "message": "Error description"
}
```

#### Validation Error Response
```json
{
  "field_name": ["Field-specific error message"],
  "non_field_errors": ["General validation error"]
}
```

#### Paginated Response
```json
{
  "results": [...],
  "count": 150,
  "page": 1,
  "page_size": 20,
  "total_pages": 8,
  "next": "http://localhost:8000/api/endpoint/?page=2",
  "previous": null
}
```

---

### Core Data Models

#### User Model
```json
{
  "id": "string",
  "email": "string",
  "username": "string",
  "role": "CANDIDATE | RECRUITER | null",
  "created_at": "ISO8601 datetime"
}
```

#### Candidate Model
```json
{
  "id": "string",
  "full_name": "string",
  "masked_name": "string | null",
  "phone": "string",
  "email": "string",
  "age": "integer",
  "role": "string",
  "experience_years": "integer",
  "current_ctc": "float | null",
  "expected_ctc": "float | null",
  "religion": "string | null",
  "country": "string",
  "state": "string",
  "city": "string",
  "education": "string",
  "skills": "string",
  "languages": "string | null",
  "resume_url": "string | null",
  "video_intro_url": "string | null",
  "profile_image_url": "string | null",
  "is_unlocked": "boolean",
  "is_available_for_hiring": "boolean",
  "created_at": "ISO8601 datetime"
}
```

#### Recruiter Model
```json
{
  "id": "string",
  "full_name": "string",
  "company_name": "string",
  "designation": "string",
  "phone": "string",
  "company_website": "string | null",
  "company_size": "string",
  "total_spent": "integer",
  "is_verified": "boolean",
  "created_at": "ISO8601 datetime"
}
```

#### Wallet Model
```json
{
  "id": "string",
  "balance": "integer",
  "total_spent": "integer",
  "created_at": "ISO8601 datetime",
  "updated_at": "ISO8601 datetime"
}
```

#### Transaction Model
```json
{
  "id": "string",
  "type": "CREDIT | DEBIT",
  "amount": "integer",
  "description": "string",
  "payment_reference": "string | null",
  "balance_after": "integer",
  "created_at": "ISO8601 datetime"
}
```

#### Subscription Plan Model
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "plan_type": "MONTHLY | QUARTERLY | YEARLY",
  "plan_type_display": "string",
  "duration_days": "integer",
  "price": "decimal string",
  "is_unlimited": "boolean",
  "credits_limit": "integer | null",
  "features": "array of strings",
  "is_active": "boolean",
  "created_at": "ISO8601 datetime"
}
```

#### Subscription Model
```json
{
  "id": "string",
  "plan": "Subscription Plan object",
  "status": "PENDING | ACTIVE | EXPIRED | CANCELLED",
  "status_display": "string",
  "start_date": "ISO8601 datetime",
  "end_date": "ISO8601 datetime",
  "days_remaining": "integer",
  "warning_level": "string | null",
  "is_currently_active": "boolean",
  "has_unlimited": "boolean",
  "credits_used": "integer",
  "credits_limit": "integer | null",
  "credits_remaining": "integer | null",
  "payment_reference": "string",
  "created_at": "ISO8601 datetime"
}
```

#### Notification Model
```json
{
  "id": "string",
  "title": "string",
  "body": "string",
  "type": "string",
  "is_read": "boolean",
  "data": "object | null",
  "created_at": "ISO8601 datetime"
}
```

---

## 14. Error Handling

### Error Response Priority

The app extracts errors in this order:

1. `non_field_errors` array
2. `message` field
3. `error` field
4. `detail` field
5. First field-specific error
6. Generic fallback message

### User-Friendly Error Messages

The app transforms server errors to readable messages:

| Server Error | User-Friendly Message |
|--------------|----------------------|
| "username already exists" | "This username is already taken. Please choose a different one." |
| "email already registered" | "This email is already registered. Please login instead." |
| "invalid credentials" | "Invalid email or password. Please check and try again." |
| "otp expired" | "OTP has expired. Please request a new one." |
| "otp invalid" | "Invalid OTP. Please check and try again." |
| Network error | "Unable to connect. Please check your internet connection and try again." |
| Server error (500) | "Something went wrong. Please try again later." |

### Automatic Error Handling

**401 Unauthorized:**
1. Intercepts 401 response
2. Attempts token refresh
3. If successful → Retries original request
4. If failed → Logs out user

**Network Errors:**
- Timeout after 60 seconds
- Shows connectivity error message
- Retry option available

**Validation Errors:**
- Displays field-specific errors
- Highlights invalid fields in UI
- Clear error messages

---

## 15. Status Codes Reference

### Success Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Request successful, response contains data |
| 201 | Created | Resource created successfully |

### Client Error Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 400 | Bad Request | Validation errors, malformed request |
| 401 | Unauthorized | Invalid/expired token (triggers auto-refresh) |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |

### Server Error Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 500 | Internal Server Error | Server-side error |

### Timeout Errors

- **Connection Timeout:** 60 seconds
- **Receive Timeout:** 60 seconds
- **Send Timeout:** 60 seconds

---

## Additional Features

### 1. Automatic Token Refresh
- Checks token expiry before each request
- Refreshes if less than 30 seconds remaining
- Automatic retry on 401 errors
- Logout if refresh fails

### 2. Request/Response Logging
All requests and responses are logged in debug mode:
```
[DEBUG] POST http://localhost:8000/api/auth/login/
[DEBUG] Request Headers: {Authorization: Bearer ...}
[DEBUG] Request Data: {email: ..., password: ...}
[DEBUG] Response Status: 200
[DEBUG] Response Data: {...}
```

### 3. File Upload Support
Multipart form data for:
- Candidate registration (resume, video, profile image)
- Profile updates with files
- Step-by-step form saving

**Supported File Types:**
- Resume: PDF
- Video: MP4, MOV
- Images: JPG, PNG

---

## Quick Reference

### Base URL
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

### Total Endpoints: 50+

**Categories:**
- Authentication: 8 endpoints
- Candidates: 6 endpoints
- Recruiters: 3 endpoints
- Location: 2 endpoints
- Search & Filter: 6 endpoints
- Candidate Management: 7 endpoints
- Wallet: 3 endpoints
- Subscriptions: 5 endpoints
- Notifications: 5 endpoints
- Miscellaneous: 2 endpoints

---

## Support & Documentation

For issues or questions about the API:
- **Documentation:** This file
- **Bug Reports:** Contact development team
- **Feature Requests:** Contact product team

---

**Last Updated:** January 2026
**Version:** 1.0.0
**Maintained By:** Workfina Development Team
