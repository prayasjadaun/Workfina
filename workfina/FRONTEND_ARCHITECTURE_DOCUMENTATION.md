# Workfina - Frontend Architecture & Features Documentation

> **Complete Guide to Workfina Flutter App Architecture**
> **Version:** 1.0.0
> **Last Updated:** January 2026

---

## Table of Contents

1. [App Overview](#1-app-overview)
2. [Architecture Pattern](#2-architecture-pattern)
3. [Project Structure](#3-project-structure)
4. [Authentication Flow](#4-authentication-flow)
5. [Candidate Features](#5-candidate-features)
6. [Recruiter Features](#6-recruiter-features)
7. [Wallet & Payment System](#7-wallet--payment-system)
8. [Subscription System](#8-subscription-system)
9. [Search & Filtering](#9-search--filtering)
10. [State Management](#10-state-management)
11. [Routing & Navigation](#11-routing--navigation)
12. [Data Models](#12-data-models)
13. [UI Components](#13-ui-components)
14. [Theme & Styling](#14-theme--styling)
15. [Storage & Caching](#15-storage--caching)
16. [Error Handling](#16-error-handling)

---

## 1. App Overview

**Workfina** is a two-sided recruitment marketplace connecting job candidates with HR recruiters.

### Key Stakeholders

1. **Candidates (Job Seekers)**
   - Create detailed profiles
   - Upload resumes and video introductions
   - Toggle hiring availability
   - Free to use

2. **Recruiters (HR Professionals)**
   - Browse and filter candidates
   - Unlock candidate contact details (10 credits)
   - Manage unlocked candidates
   - Purchase credits or subscribe to plans

### Business Model

- **Freemium:** Candidates free, recruiters pay
- **Credit System:** 10 credits per candidate unlock
- **Subscriptions:** Monthly/Quarterly/Yearly plans
- **Pay-as-you-go:** Wallet credit purchase

---

## 2. Architecture Pattern

### MVC-like Architecture with GetX

```
┌─────────────────────────────────────────────────────┐
│                      View Layer                      │
│    (Screens, Widgets, UI Components)                │
├─────────────────────────────────────────────────────┤
│                   Controller Layer                   │
│  (Business Logic, State Management with GetX)       │
├─────────────────────────────────────────────────────┤
│                    Service Layer                     │
│  (API Service, Notification Service, Storage)       │
├─────────────────────────────────────────────────────┤
│                     Model Layer                      │
│        (Data Models, DTOs, Entities)                │
└─────────────────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns:** View, Controller, Service, Model layers
2. **Reactive Programming:** GetX state management
3. **Single Responsibility:** Each controller manages specific domain
4. **Dependency Injection:** GetX dependency injection
5. **Clean Code:** Consistent naming, structure, documentation

---

## 3. Project Structure

```
lib/
├── main.dart                          # App entry point
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
│   ├── pagination_model.dart
│   ├── banner_model.dart
│   └── app_version_model.dart
│
├── services/                          # External services
│   ├── api_service.dart              # HTTP API client
│   └── notification_service.dart     # FCM notifications
│
├── views/                             # UI Layer
│   └── screens/                       # App screens
│       ├── splash_screen.dart
│       ├── auth/                      # Authentication screens
│       │   ├── email_screen.dart
│       │   ├── otp_screen.dart
│       │   ├── login_screen.dart
│       │   └── create_account_screen.dart
│       ├── role/                      # Role selection
│       │   └── role_selection_screen.dart
│       ├── home/                      # Home screens
│       │   ├── candidate_home_screen.dart
│       │   └── recuriter_home_screen.dart
│       ├── candidates/                # Candidate features
│       │   ├── candidate_setup_screen.dart
│       │   ├── candidate_dashboard.dart
│       │   ├── candidate_profile.dart
│       │   ├── candidate_edit_profile.dart
│       │   ├── candidate_education_screen.dart
│       │   └── candidate_experience_screen.dart
│       ├── recuriters/                # Recruiter features
│       │   ├── recuriter_setup_screen.dart
│       │   ├── recruiter_dashboard.dart
│       │   ├── recruiter_profile_screen.dart
│       │   ├── category_screen.dart
│       │   ├── sub_categories_screen.dart
│       │   ├── recruiter_candidate_screen.dart
│       │   ├── recruiter_candidate_details_screen.dart
│       │   ├── recruiter_filter_screen.dart
│       │   ├── filter_candidate_screen.dart
│       │   ├── recruiter_wallet_screen.dart
│       │   ├── subscription_main_screen.dart
│       │   ├── subscription_plans_screen.dart
│       │   └── subscription_history_screen.dart
│       ├── notification/              # Notifications
│       │   └── notification_screen.dart
│       ├── appVersion/                # Version management
│       │   └── app_version.dart
│       └── widgets/                   # Reusable components
│           ├── candidate_card_widget.dart
│           ├── category_card_widget.dart
│           ├── horizontal_category_tabs.dart
│           ├── search_bar.dart
│           ├── refresh_indicator_wrapper.dart
│           ├── hiring_availabile_widget.dart
│           ├── subscription_status_banner.dart
│           └── subscription_expiry_dialog.dart
│
└── utils/                             # Utilities (if any)
```

---

## 4. Authentication Flow

### Screens

1. **Splash Screen** (`splash_screen.dart`)
   - App initialization
   - Check login status
   - Navigate to appropriate screen

2. **Email Screen** (`email_screen.dart`)
   - Email input for signup
   - Send OTP button
   - Navigate to Login or OTP screen

3. **OTP Screen** (`otp_screen.dart`)
   - 6-digit OTP input
   - Verify OTP
   - Navigate to Create Account

4. **Login Screen** (`login_screen.dart`)
   - Email + Password login
   - Navigate to home (if role selected)
   - Navigate to role selection (if role not selected)

5. **Create Account Screen** (`create_account_screen.dart`)
   - Username + Password + Confirm Password
   - Create account
   - Navigate to role selection

6. **Role Selection Screen** (`role_selection_screen.dart`)
   - Choose CANDIDATE or RECRUITER
   - Update user role
   - Navigate to setup screen

### Authentication Controller

**File:** `lib/controllers/auth_controller.dart`

```dart
class AuthController extends GetxController {
  // Observable state
  var isLoading = false.obs;
  var user = Rxn<UserModel>();

  // API service
  final ApiService _apiService = ApiService();

  // Methods
  Future<void> sendOTP(String email);
  Future<void> verifyOTP(String email, String otp);
  Future<void> createAccount(String email, String username, String password);
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> updateRole(String role);
}
```

### Key Features

1. **JWT Token Management**
   - Access token + Refresh token
   - Automatic token refresh (30-second buffer)
   - Token stored in SharedPreferences

2. **Session Persistence**
   - User data cached locally
   - Auto-login on app restart
   - Secure token storage

3. **Error Handling**
   - User-friendly error messages
   - Field-specific validation errors
   - Network error handling

4. **FCM Integration**
   - Token uploaded after login
   - Push notification enablement

### User Flow Diagram

```
App Launch
    │
    ├─→ Has valid token? ─→ Yes ─→ Home Screen
    │                              (based on role)
    └─→ No
        │
        ├─→ Email Screen
        │       ├─→ Has account? ─→ Login Screen
        │       └─→ New user? ─→ Send OTP
        │
        ├─→ OTP Screen
        │       └─→ Verify OTP
        │
        ├─→ Create Account Screen
        │       └─→ Set username/password
        │
        └─→ Role Selection Screen
                ├─→ Select CANDIDATE ─→ Candidate Setup
                └─→ Select RECRUITER ─→ Recruiter Setup
```

---

## 5. Candidate Features

### Candidate Setup (Multi-Step Form)

**File:** `lib/views/screens/candidates/candidate_setup_screen.dart`

**Steps:**
1. Personal Information
2. Location & Contact
3. Experience & Skills
4. Education
5. Resume & Media Upload
6. Review & Submit

**Progressive Saving:**
- Each step saved individually via API
- User can exit and resume later
- Step completion tracked

### Candidate Dashboard

**File:** `lib/views/screens/candidates/candidate_dashboard.dart`

**Components:**

1. **Profile Completeness Card**
   ```dart
   - Circular progress indicator
   - Percentage completion (0-100%)
   - Missing fields highlighted
   ```

2. **Stats Cards**
   ```dart
   - Experience years
   - Skills count
   - Resume uploaded status
   ```

3. **Quick Actions**
   ```dart
   - Edit Profile
   - Update Resume
   - Update Availability
   ```

4. **Profile Tips**
   ```dart
   - Suggestions to improve profile
   - Complete missing sections
   ```

5. **Hiring Availability Toggle**
   ```dart
   - Make profile visible/hidden to recruiters
   - Real-time API update
   ```

### Candidate Profile

**File:** `lib/views/screens/candidates/candidate_profile.dart`

**Sections:**

1. **Header**
   - Profile image
   - Name
   - Role
   - Location

2. **Contact Information**
   - Email
   - Phone
   - Address

3. **Experience**
   - Work history
   - Duration calculation
   - Company names

4. **Education**
   - Degrees
   - Universities
   - Graduation years

5. **Skills**
   - Skill chips
   - Proficiency levels (if applicable)

6. **Documents**
   - Resume download/view
   - Video introduction
   - Certificates (if any)

7. **Career Objective**
   - Goals
   - Preferences

### Candidate Edit Profile

**File:** `lib/views/screens/candidates/candidate_edit_profile.dart`

**Features:**
- Pre-filled form with current data
- File upload for resume/video/image
- Form validation
- Save button with loading state

### Candidate Controller

**File:** `lib/controllers/candidate_controller.dart`

```dart
class CandidateController extends GetxController {
  var isLoading = false.obs;
  var candidate = Rxn<CandidateModel>();
  var isAvailableForHiring = true.obs;

  // Methods
  Future<void> registerCandidate(Map<String, dynamic> data);
  Future<void> getCandidateProfile();
  Future<void> updateCandidateProfile(Map<String, dynamic> data);
  Future<void> saveStep(int step, Map<String, dynamic> data);
  Future<void> toggleAvailability();
  Future<void> updateResume(File file);
}
```

---

## 6. Recruiter Features

### Recruiter Setup (3-Step Form)

**File:** `lib/views/screens/recuriters/recuriter_setup_screen.dart`

**Steps:**
1. **Company Information**
   - Company name
   - Designation
   - Company size

2. **Contact Details**
   - Phone number
   - Company website

3. **Review & Submit**
   - Verification pending notice
   - 24-48 hours approval time

### Recruiter Dashboard

**File:** `lib/views/screens/recuriters/recruiter_dashboard.dart`

**Layout:**

```
┌──────────────────────────────────────────────────────┐
│  [Search Bar]                    [Notification Bell] │
├──────────────────────────────────────────────────────┤
│  [Category Tabs: Engineering, Marketing, Sales...]   │
├──────────────────────────────────────────────────────┤
│  Stats Cards Row:                                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │ Credits  │ │ Unlocked │ │  Spent   │            │
│  │   100    │ │    25    │ │   500    │            │
│  └──────────┘ └──────────┘ └──────────┘            │
├──────────────────────────────────────────────────────┤
│  Category Grid (Bento Layout):                      │
│  ┌─────────────┐ ┌─────────────┐                   │
│  │ Technology  │ │  Marketing  │                   │
│  │  150 profiles│ │  75 profiles│                  │
│  └─────────────┘ └─────────────┘                   │
│  ┌─────────────┐ ┌─────────────┐                   │
│  │   Sales     │ │   Finance   │                   │
│  │  60 profiles│ │  40 profiles│                   │
│  └─────────────┘ └─────────────┘                   │
├──────────────────────────────────────────────────────┤
│  Recent Activity:                                    │
│  - Unlocked John Doe (2 hours ago)                  │
│  - Unlocked Jane Smith (1 day ago)                  │
└──────────────────────────────────────────────────────┘
```

**Features:**

1. **Global Search Bar**
   - Search by name, role, skills, city
   - Real-time search results

2. **Category Tabs**
   - Top 4 categories
   - Horizontal scroll
   - Candidate count badges

3. **Stats Cards**
   - Total wallet credits
   - Total unlocked profiles
   - Total amount spent
   - Total candidates available

4. **Bento Grid Categories**
   - Up to 5 main categories
   - Candidate count per category
   - Click to view category candidates

5. **Recent Activity**
   - Recently unlocked candidates
   - Timestamp
   - Quick access to candidate details

### Candidate Discovery

#### Category Screen

**File:** `lib/views/screens/recuriters/category_screen.dart`

**Features:**
- Browse candidates by category
- Subcategory navigation
- Candidate count per category

#### Subcategories Screen

**File:** `lib/views/screens/recuriters/sub_categories_screen.dart`

**Features:**
- Drill down into subcategories
- Filter within subcategory
- Candidate count

#### Recruiter Candidate Screen

**File:** `lib/views/screens/recuriters/recruiter_candidate_screen.dart`

**Layout:**

```
┌──────────────────────────────────────────┐
│  [Search Bar]          [Filter Button]   │
├──────────────────────────────────────────┤
│  Tabs: [ Available ] [ Unlocked ]        │
├──────────────────────────────────────────┤
│  Candidate List:                         │
│  ┌────────────────────────────────────┐ │
│  │  [Photo] John Doe     [🔒 Locked]  │ │
│  │  3 years exp                        │ │
│  │  Mumbai, Maharashtra                │ │
│  │  10 credits to unlock               │ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │  [Photo] J*** W***    [🔒 Locked]  │ │
│  │  5 years exp                        │ │
│  │  Pune, Maharashtra                  │ │
│  │  10 credits to unlock               │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

**Two Tabs:**

1. **Available Tab** (Locked Candidates)
   - Masked name (J*** D***)
   - Masked contact (******3210)
   - Basic info visible (role, experience, location)
   - Lock icon
   - Credit cost (10 credits)

2. **Unlocked Tab**
   - Full name
   - Full contact details
   - Resume access
   - Video introduction
   - Notes & follow-ups

### Candidate Details Screen

**File:** `lib/views/screens/recuriters/recruiter_candidate_details_screen.dart`

**For Locked Candidates:**
```
┌──────────────────────────────────────────┐
│  [Masked Photo]                          │
│  J*** D***                               │
│  Software Engineer                       │
├──────────────────────────────────────────┤
│  Experience: 3 years                     │
│  Location: Mumbai, Maharashtra           │
│  Skills: Python, Django, React           │
│  Current CTC: ₹5,00,000                  │
│  Expected CTC: ₹8,00,000                 │
├──────────────────────────────────────────┤
│  [🔒 Unlock Profile - 10 Credits]        │
└──────────────────────────────────────────┘
```

**For Unlocked Candidates:**
```
┌──────────────────────────────────────────┐
│  [Profile Photo]                         │
│  John Doe                                │
│  Software Engineer                       │
│  📧 john@example.com                     │
│  📱 +91 9876543210                       │
├──────────────────────────────────────────┤
│  [Download Resume] [Watch Video Intro]   │
├──────────────────────────────────────────┤
│  Experience:                             │
│  • ABC Corp (2021-2024) - 3 years       │
│    Software Engineer                     │
│    Developed web applications...         │
├──────────────────────────────────────────┤
│  Education:                              │
│  • B.Tech, Computer Science              │
│    XYZ University (2019) - 85%          │
├──────────────────────────────────────────┤
│  Skills: Python, Django, React, AWS      │
├──────────────────────────────────────────┤
│  Notes & Follow-ups:                     │
│  [Add Note] [Add Follow-up]              │
│                                          │
│  📝 Notes:                               │
│  - Good technical skills (Jan 15)        │
│  - Interviewed, moving to next round     │
│                                          │
│  📅 Follow-ups:                          │
│  - Schedule 2nd interview (Jan 25) ⏰    │
│  - Send offer letter (Jan 20) ✅         │
└──────────────────────────────────────────┘
```

**Features:**

1. **Unlock Functionality**
   - 10 credits deducted
   - Checks subscription first, then wallet
   - Shows full contact info after unlock
   - One-time unlock (permanent access)

2. **Notes System**
   - Add private notes
   - Timestamp
   - Edit/delete notes

3. **Follow-up System**
   - Set follow-up date & time
   - Add follow-up notes
   - Mark as completed
   - Delete follow-ups

4. **Contact Actions**
   - Call candidate
   - Email candidate
   - WhatsApp (if integrated)

### Filtering System

#### Recruiter Filter Screen

**File:** `lib/views/screens/recuriters/recruiter_filter_screen.dart`

**Filter Options:**

1. **Department/Role**
   - Software Engineer
   - Data Scientist
   - Product Manager
   - etc.

2. **Religion**
   - Hindu
   - Muslim
   - Christian
   - Sikh
   - Buddhist
   - Any

3. **Location**
   - State dropdown
   - City dropdown (based on state)

4. **Experience Range**
   - 0-1 years
   - 2-5 years
   - 5+ years
   - Custom range

5. **Education**
   - B.Tech
   - M.Tech
   - MBA
   - BCA
   - MCA
   - etc.

6. **Skills**
   - Multi-select
   - Search skills
   - Recently used skills

7. **CTC Range**
   - Current CTC (min-max)
   - Expected CTC (min-max)
   - Slider or input fields

**UI Layout:**
```
┌──────────────────────────────────────────┐
│  Filters                    [Clear All]   │
├──────────────────────────────────────────┤
│  Department:                             │
│  [ Select Department ▼ ]                 │
├──────────────────────────────────────────┤
│  Religion:                               │
│  [ Select Religion ▼ ]                   │
├──────────────────────────────────────────┤
│  State:                                  │
│  [ Select State ▼ ]                      │
│  City:                                   │
│  [ Select City ▼ ]                       │
├──────────────────────────────────────────┤
│  Experience:                             │
│  Min: [0] years  Max: [10] years         │
├──────────────────────────────────────────┤
│  Education:                              │
│  [ ] B.Tech  [ ] M.Tech  [ ] MBA         │
├──────────────────────────────────────────┤
│  Skills:                                 │
│  [Search Skills...]                      │
│  × Python  × Django  × React             │
├──────────────────────────────────────────┤
│  Current CTC:                            │
│  Min: [₹] 0  Max: [₹] 50,00,000          │
├──────────────────────────────────────────┤
│  Expected CTC:                           │
│  Min: [₹] 0  Max: [₹] 1,00,00,000        │
├──────────────────────────────────────────┤
│  [Apply Filters]                         │
└──────────────────────────────────────────┘
```

#### Filter Candidate Screen

**File:** `lib/views/screens/recuriters/filter_candidate_screen.dart`

**Features:**
- Displays filtered results
- Applied filters shown at top
- Pagination support
- Sort options (relevance, experience, CTC)

### Recruiter Controller

**File:** `lib/controllers/recuriter_controller.dart`

```dart
class RecruiterController extends GetxController {
  var isLoading = false.obs;
  var recruiter = Rxn<RecruiterModel>();
  var candidates = <CandidateModel>[].obs;
  var unlockedCandidates = <CandidateModel>[].obs;
  var filterOptions = Rxn<FilterOptionsModel>();
  var selectedFilters = <String, dynamic>{}.obs;

  // Methods
  Future<void> registerRecruiter(Map<String, dynamic> data);
  Future<void> getRecruiterProfile();
  Future<void> updateRecruiterProfile(Map<String, dynamic> data);
  Future<void> getCandidates(Map<String, dynamic> filters);
  Future<void> unlockCandidate(String candidateId);
  Future<void> getUnlockedCandidates();
  Future<void> addCandidateNote(String candidateId, String note);
  Future<void> addCandidateFollowup(String candidateId, Map data);
  Future<void> getFilterOptions();
  void applyFilters(Map<String, dynamic> filters);
  void clearFilters();
}
```

---

## 7. Wallet & Payment System

### Wallet Screen

**File:** `lib/views/screens/recuriters/recruiter_wallet_screen.dart`

**Layout:**

```
┌──────────────────────────────────────────┐
│  Wallet Balance                          │
│  ┌────────────────────────────────────┐ │
│  │         💰 100 Credits              │ │
│  │                                     │ │
│  │  [Recharge Wallet]                  │ │
│  └────────────────────────────────────┘ │
├──────────────────────────────────────────┤
│  Credit Information:                     │
│  • Wallet Credits: 100                   │
│  • Subscription Credits: 25 (from plan)  │
│  • Total Available: 125                  │
├──────────────────────────────────────────┤
│  Total Spent: ₹5,000 (50 unlocks)        │
├──────────────────────────────────────────┤
│  Transaction History:                    │
│  ┌────────────────────────────────────┐ │
│  │ + ₹1,000 Recharge   Jan 15, 10:30  │ │
│  │   Balance: 200 credits              │ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │ - 10 credits Unlock: John Doe      │ │
│  │   Jan 15, 14:30                     │ │
│  │   Balance: 190 credits              │ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │ - 10 credits Unlock: Jane Smith    │ │
│  │   Jan 16, 09:15                     │ │
│  │   Balance: 180 credits              │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

**Features:**

1. **Balance Display**
   - Current wallet balance
   - Subscription credits (if active)
   - Total available credits

2. **Recharge Functionality**
   - Payment gateway integration
   - Credit packages (50, 100, 200, 500 credits)
   - Transaction reference tracking

3. **Transaction History**
   - Credit additions (recharges)
   - Credit deductions (candidate unlocks)
   - Timestamp
   - Balance after transaction

4. **Spending Summary**
   - Total amount spent
   - Total unlocks count
   - Average cost per unlock

### Wallet Controller

**File:** `lib/controllers/wallet_controller.dart`

```dart
class WalletController extends GetxController {
  var isLoading = false.obs;
  var wallet = Rxn<WalletModel>();
  var transactions = <TransactionModel>[].obs;

  // Methods
  Future<void> getWalletBalance();
  Future<void> rechargeWallet(int credits, String paymentRef);
  Future<void> getTransactions();
  int get totalCredits; // Wallet + Subscription credits
}
```

### Credit Deduction Logic

**Priority:**
1. **Check Active Subscription**
   - If subscription active and has remaining credits
   - Deduct from subscription
2. **Else, Check Wallet**
   - Deduct from wallet balance
3. **If both insufficient**
   - Show error
   - Prompt to recharge or subscribe

**Example:**
```dart
Future<void> unlockCandidate(String candidateId) async {
  const unlockCost = 10;

  // Check subscription first
  if (hasActiveSubscription && subscriptionCreditsRemaining >= unlockCost) {
    // Deduct from subscription
    await _unlockWithSubscription(candidateId);
  } else if (walletBalance >= unlockCost) {
    // Deduct from wallet
    await _unlockWithWallet(candidateId);
  } else {
    // Insufficient credits
    throw Exception('Insufficient credits. Please recharge or subscribe.');
  }
}
```

---

## 8. Subscription System

### Subscription Screens

#### Subscription Main Screen

**File:** `lib/views/screens/recuriters/subscription_main_screen.dart`

**Sections:**

1. **Current Subscription Status**
   ```
   ┌──────────────────────────────────────┐
   │  Active Plan: Basic Plan             │
   │  Status: Active ✅                   │
   │  Expires: Jan 31, 2024 (15 days)     │
   │  Credits Used: 25 / 50               │
   └──────────────────────────────────────┘
   ```

2. **Quick Actions**
   - View Plans
   - Upgrade Plan
   - Cancel Subscription

3. **Usage Overview**
   - Credits used this month
   - Unlocks remaining
   - Daily average

#### Subscription Plans Screen

**File:** `lib/views/screens/recuriters/subscription_plans_screen.dart`

**Layout:**

```
┌──────────────────────────────────────────┐
│  Choose Your Plan                        │
├──────────────────────────────────────────┤
│  ┌────────────────────────────────────┐ │
│  │  Basic Plan        ₹999/month      │ │
│  │  • 50 candidate unlocks             │ │
│  │  • Email support                    │ │
│  │  • Basic filters                    │ │
│  │  [Select Plan]                      │ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │  Professional      ₹2,499/quarter  │ │
│  │  • 150 candidate unlocks            │ │
│  │  • Priority support                 │ │
│  │  • Advanced filters                 │ │
│  │  • Analytics dashboard              │ │
│  │  [Select Plan]    [POPULAR 🔥]      │ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │  Enterprise        ₹9,999/year     │ │
│  │  • Unlimited unlocks                │ │
│  │  • Dedicated account manager        │ │
│  │  • API access                       │ │
│  │  • Custom integrations              │ │
│  │  [Select Plan]                      │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

**Plan Features:**

1. **Basic Plan**
   - Monthly billing
   - 50 credits/month
   - Basic support

2. **Professional Plan**
   - Quarterly billing
   - 150 credits/quarter
   - Priority support
   - Advanced features

3. **Enterprise Plan**
   - Yearly billing
   - Unlimited credits
   - Premium support
   - Custom features

#### Subscription History Screen

**File:** `lib/views/screens/recuriters/subscription_history_screen.dart`

**Layout:**

```
┌──────────────────────────────────────────┐
│  Subscription History                    │
├──────────────────────────────────────────┤
│  ┌────────────────────────────────────┐ │
│  │  Basic Plan - Active ✅            │ │
│  │  Jan 1 - Jan 31, 2024              │ │
│  │  Credits: 25/50 used               │ │
│  │  Amount: ₹999                       │ │
│  └────────────────────────────────────┘ │
│  ┌────────────────────────────────────┐ │
│  │  Basic Plan - Expired ⏰           │ │
│  │  Dec 1 - Dec 31, 2023              │ │
│  │  Credits: 50/50 used               │ │
│  │  Amount: ₹999                       │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

### Subscription UI Components

#### Subscription Status Banner

**File:** `lib/views/screens/widgets/subscription_status_banner.dart`

**Displays:**
- Current plan name
- Expiry date
- Days remaining
- Warning level (if expiring soon)

**States:**
- **Active:** Green banner
- **Expiring Soon (< 7 days):** Yellow banner
- **Critical (< 3 days):** Red banner
- **Expired:** Gray banner

#### Subscription Expiry Dialog

**File:** `lib/views/screens/widgets/subscription_expiry_dialog.dart`

**Triggered:**
- Login with expired subscription
- Subscription expires while using app
- Manual check

**Actions:**
- View Plans
- Renew Subscription
- Continue with Wallet

### Subscription Model

**File:** `lib/models/subscription_model.dart`

**Classes:**

1. **SubscriptionPlan**
   ```dart
   {
     id: string,
     name: string,
     description: string,
     planType: MONTHLY | QUARTERLY | YEARLY,
     durationDays: int,
     price: decimal,
     isUnlimited: bool,
     creditsLimit: int?,
     features: List<string>,
     isActive: bool
   }
   ```

2. **SubscriptionStatus**
   ```dart
   {
     hasSubscription: bool,
     status: ACTIVE | PENDING | EXPIRED | CANCELLED,
     plan: string?,
     planType: string?,
     expiresAt: DateTime?,
     daysRemaining: int?,
     isUnlimited: bool,
     creditsUsed: int,
     creditsLimit: int?,
     creditsRemaining: int?,
     warningLevel: null | warning | critical
   }
   ```

3. **Subscription**
   ```dart
   {
     id: string,
     plan: SubscriptionPlan,
     status: PENDING | ACTIVE | EXPIRED | CANCELLED,
     startDate: DateTime,
     endDate: DateTime,
     daysRemaining: int,
     creditsUsed: int,
     creditsLimit: int?,
     paymentReference: string,
     createdAt: DateTime
   }
   ```

---

## 9. Search & Filtering

### Global Search

**File:** `lib/views/screens/widgets/search_bar.dart`

**Features:**
- Real-time search
- Search by:
  - Name
  - Role/Department
  - Skills
  - City
- Debounced API calls (500ms delay)
- Clear button
- Loading indicator

**Implementation:**
```dart
class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;

  // Debounce timer
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }
}
```

### Category-Based Filtering

**Horizontal Category Tabs:**

**File:** `lib/views/screens/widgets/horizontal_category_tabs.dart`

```
[ Engineering (150) ] [ Marketing (75) ] [ Sales (60) ] [ Finance (40) ]
```

**Features:**
- Horizontal scroll
- Active indicator
- Candidate count badges
- Tap to filter

**Category Card:**

**File:** `lib/views/screens/widgets/category_card_widget.dart`

```
┌─────────────────┐
│   Technology    │
│                 │
│  150 profiles   │
└─────────────────┘
```

### Advanced Filtering

**Filter Options Model:**

**File:** `lib/models/filter_options_model.dart`

```dart
class FilterOptionsModel {
  List<String> roles;
  List<String> cities;
  List<String> states;
  List<String> countries;
  List<String> religions;
  List<String> educations;
  List<String> skills;
}
```

**Filter State Management:**

```dart
// In RecruiterController
var selectedFilters = <String, dynamic>{
  'role': null,
  'city': null,
  'state': null,
  'min_experience': null,
  'max_experience': null,
  'skills': [],
  'min_ctc': null,
  'max_ctc': null,
}.obs;

void applyFilters() {
  // Remove null values
  final filters = selectedFilters.entries
      .where((entry) => entry.value != null && entry.value != '')
      .map((entry) => MapEntry(entry.key, entry.value))
      .toMap();

  // Call API with filters
  getCandidates(filters);
}
```

### Pagination

**File:** `lib/models/pagination_model.dart`

```dart
class PaginationModel {
  int count;          // Total results
  int page;           // Current page
  int pageSize;       // Results per page
  int totalPages;     // Total pages
  String? next;       // Next page URL
  String? previous;   // Previous page URL
}
```

**Implementation:**
```dart
// In candidate list screen
ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
}

void _onScroll() {
  if (_scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent) {
    // Reached bottom, load more
    if (controller.hasMore && !controller.isLoading.value) {
      controller.loadMore();
    }
  }
}
```

---

## 10. State Management

### GetX State Management

**Why GetX?**
- Reactive programming
- Minimal boilerplate
- Built-in dependency injection
- Performance optimized
- Easy to learn

### Controller Pattern

**Example: AuthController**

```dart
class AuthController extends GetxController {
  // Observable state
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var user = Rxn<UserModel>();
  var errorMessage = ''.obs;

  // Dependencies
  final ApiService _apiService = Get.find();

  // Methods
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.login(email, password);

      user.value = response.user;
      isAuthenticated.value = true;

      // Navigate to home
      Get.offAll(() => HomeScreen());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    user.value = null;
    isAuthenticated.value = false;
    Get.offAll(() => LoginScreen());
  }
}
```

**Usage in UI:**

```dart
class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Email field
          TextField(
            controller: emailController,
          ),

          // Password field
          TextField(
            controller: passwordController,
          ),

          // Login button with loading state
          Obx(() => authController.isLoading.value
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  authController.login(
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: Text('Login'),
              )
          ),

          // Error message
          Obx(() => authController.errorMessage.value.isNotEmpty
            ? Text(
                authController.errorMessage.value,
                style: TextStyle(color: Colors.red),
              )
            : SizedBox()
          ),
        ],
      ),
    );
  }
}
```

### Dependency Injection

**Setup in main.dart:**

```dart
void main() {
  // Initialize dependencies
  Get.put(ApiService());
  Get.put(AuthController());
  Get.lazyPut(() => CandidateController());
  Get.lazyPut(() => RecruiterController());
  Get.lazyPut(() => WalletController());

  runApp(MyApp());
}
```

**Lazy Loading:**
- `Get.lazyPut()`: Creates controller only when needed
- `Get.put()`: Creates controller immediately
- `Get.find()`: Retrieves existing controller

---

## 11. Routing & Navigation

### GetX Navigation

**Named Routes:**

```dart
// Define routes
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const roleSelection = '/role-selection';
  static const candidateHome = '/candidate-home';
  static const recruiterHome = '/recruiter-home';
  static const candidateSetup = '/candidate-setup';
  static const recruiterSetup = '/recruiter-setup';
}

// In main.dart
GetMaterialApp(
  initialRoute: AppRoutes.splash,
  getPages: [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    // ... more routes
  ],
)
```

**Navigation Methods:**

```dart
// Navigate to new screen
Get.to(() => DetailsScreen());

// Navigate with named route
Get.toNamed(AppRoutes.candidateHome);

// Navigate and remove current screen
Get.off(() => HomeScreen());

// Navigate and remove all previous screens
Get.offAll(() => LoginScreen());

// Navigate back
Get.back();

// Pass arguments
Get.to(() => DetailsScreen(), arguments: {'id': '123'});

// Receive arguments
final args = Get.arguments;
```

### Bottom Navigation

**Candidate Home Screen:**

```dart
int _selectedIndex = 0;

final List<Widget> _screens = [
  CandidateDashboard(),
  CandidateJobs(),
  CandidateApplications(),
  CandidateProfile(),
];

BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
    BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Applications'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

**Recruiter Home Screen:**

```dart
final List<Widget> _screens = [
  RecruiterDashboard(),
  UnlockedCandidatesScreen(),
  RecruiterWalletScreen(),
  SubscriptionMainScreen(),
  RecruiterProfileScreen(),
];

// 5 tabs: Home, Unlocked, Wallet, Plans, Profile
```

---

## 12. Data Models

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
  String? religion;
  String country;
  String state;
  String city;
  String education;
  String skills;
  String? languages;
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

### Model Conventions

1. **Naming:**
   - Class: `ModelName + Model` (e.g., `UserModel`)
   - File: `model_name_model.dart` (e.g., `user_model.dart`)

2. **JSON Serialization:**
   - `fromJson()`: Convert JSON to model
   - `toJson()`: Convert model to JSON

3. **Null Safety:**
   - Use `?` for nullable fields
   - Provide defaults where applicable

---

## 13. UI Components

### Reusable Widgets

#### Candidate Card

**File:** `lib/views/screens/widgets/candidate_card_widget.dart`

```dart
class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback onTap;

  @override
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
            Text('${candidate.experienceYears} years exp'),
            Text('${candidate.city}, ${candidate.state}'),
          ],
        ),
        trailing: candidate.isUnlocked
          ? Icon(Icons.lock_open, color: Colors.green)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, color: Colors.grey),
                Text('10 credits', style: TextStyle(fontSize: 10)),
              ],
            ),
        onTap: onTap,
      ),
    );
  }
}
```

#### Refresh Indicator Wrapper

**File:** `lib/views/screens/widgets/refresh_indicator_wrapper.dart`

```dart
class RefreshIndicatorWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
```

#### Hiring Available Widget

**File:** `lib/views/screens/widgets/hiring_availabile_widget.dart`

```dart
class HiringAvailableWidget extends StatelessWidget {
  final bool isAvailable;
  final Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Available for Hiring'),
      subtitle: Text(
        isAvailable
          ? 'Your profile is visible to recruiters'
          : 'Your profile is hidden from recruiters'
      ),
      value: isAvailable,
      onChanged: onToggle,
    );
  }
}
```

---

## 14. Theme & Styling

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
    _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
  }
}
```

### Theme Data

```dart
class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    // ... more theme data
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    // ... more theme data
  );
}
```

### Usage in App

```dart
GetMaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system, // or ThemeMode.light, ThemeMode.dark
)
```

---

## 15. Storage & Caching

### SharedPreferences Usage

**Stored Data:**
- Access token
- Refresh token
- User data (JSON string)
- FCM token
- Theme preference
- Onboarding completion status

**Example:**

```dart
class StorageService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

---

## 16. Error Handling

### Global Error Handler

```dart
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
          return 'Connection timeout. Please try again.';

        case DioErrorType.response:
          return _handleResponseError(error.response);

        case DioErrorType.cancel:
          return 'Request cancelled';

        default:
          return 'Network error. Please check your connection.';
      }
    }

    return error.toString();
  }

  static String _handleResponseError(Response? response) {
    if (response == null) return 'Unknown error occurred';

    final data = response.data;

    // Priority: non_field_errors > message > error > detail
    if (data is Map) {
      if (data['non_field_errors'] != null) {
        return data['non_field_errors'][0];
      }
      if (data['message'] != null) {
        return data['message'];
      }
      if (data['error'] != null) {
        return data['error'];
      }
      if (data['detail'] != null) {
        return data['detail'];
      }

      // Field-specific error
      final firstError = data.values.firstWhere(
        (value) => value is List && value.isNotEmpty,
        orElse: () => null,
      );
      if (firstError != null) {
        return firstError[0];
      }
    }

    return 'Error: ${response.statusCode}';
  }
}
```

### Usage in Controllers

```dart
try {
  await _apiService.login(email, password);
} catch (e) {
  errorMessage.value = ErrorHandler.getErrorMessage(e);
  Get.snackbar('Error', errorMessage.value);
}
```

---

## Summary

### Key Technologies

- **Framework:** Flutter
- **State Management:** GetX
- **HTTP Client:** Dio
- **Storage:** SharedPreferences
- **Notifications:** Firebase Cloud Messaging
- **Local Notifications:** flutter_local_notifications

### Architecture Highlights

- ✅ Clean separation of concerns (View/Controller/Service/Model)
- ✅ Reactive state management with GetX
- ✅ Reusable UI components
- ✅ Centralized error handling
- ✅ JWT authentication with auto-refresh
- ✅ Offline-first approach where applicable
- ✅ Theme support (Light/Dark mode)
- ✅ Pagination for large lists
- ✅ Pull-to-refresh functionality
- ✅ Comprehensive notification system

### Code Quality Practices

- ✅ Consistent naming conventions
- ✅ Code organization by feature
- ✅ Reusable widgets
- ✅ Type safety with null-safety
- ✅ Error handling throughout
- ✅ Loading states for async operations
- ✅ User feedback (SnackBars, Dialogs)

---

**Last Updated:** January 2026
**Version:** 1.0.0
**Maintained By:** Workfina Development Team
