# Workfina - Notification System Documentation

> **Complete Guide to Firebase Cloud Messaging (FCM) Implementation**
> **Version:** 1.0.0
> **Last Updated:** January 2026

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Firebase Cloud Messaging (FCM) Setup](#3-firebase-cloud-messaging-fcm-setup)
4. [Notification Handlers](#4-notification-handlers)
5. [Platform-Specific Configuration](#5-platform-specific-configuration)
6. [Notification Flow by App State](#6-notification-flow-by-app-state)
7. [Local Notifications](#7-local-notifications)
8. [FCM Token Management](#8-fcm-token-management)
9. [Notification Permissions](#9-notification-permissions)
10. [Server Integration](#10-server-integration)
11. [Notification UI](#11-notification-ui)
12. [Testing Notifications](#12-testing-notifications)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Overview

Workfina uses **Firebase Cloud Messaging (FCM)** for push notifications across iOS and Android platforms. The system handles notifications in all app states (foreground, background, terminated) and provides a complete notification management interface.

### Key Features

- **Push Notifications** via FCM
- **Local Notifications** for foreground display
- **Background Message Handling**
- **Notification Click Handling**
- **Token Management** with server sync
- **Topic Subscription** support
- **In-app Notification Center**
- **Read/Unread Status** tracking
- **Platform-specific optimizations** (iOS/Android)

### Core Dependencies

```yaml
firebase_core: ^3.12.0
firebase_messaging: ^16.1.0
flutter_local_notifications: ^19.5.0
```

---

## 2. Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Workfina App                          │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │         NotificationService                      │   │
│  │  (lib/services/notification_service.dart)       │   │
│  └─────────────────────────────────────────────────┘   │
│           │                    │                         │
│           │                    │                         │
│  ┌────────▼──────┐    ┌───────▼──────────┐             │
│  │ FCM Handler   │    │ Local Notif      │             │
│  │ (Background)  │    │ Handler          │             │
│  └───────────────┘    └──────────────────┘             │
│                                                           │
└─────────────────────────────────────────────────────────┘
           │                             │
           │                             │
┌──────────▼─────────┐      ┌───────────▼──────────┐
│  Firebase Cloud    │      │  Platform Specific   │
│  Messaging Server  │      │  Notification System │
└────────────────────┘      └──────────────────────┘
```

### File Structure

```
lib/
├── services/
│   └── notification_service.dart       # Core notification logic
├── views/
│   └── screens/
│       └── notification/
│           └── notification_screen.dart # Notification UI
└── main.dart                            # App initialization

android/
└── app/
    └── src/
        └── main/
            └── AndroidManifest.xml      # Android permissions & config

ios/
└── Runner/
    ├── AppDelegate.swift                # iOS notification setup
    └── Runner.entitlements              # iOS capabilities
```

---

## 3. Firebase Cloud Messaging (FCM) Setup

### Initialization

**File:** `lib/services/notification_service.dart`

```dart
static Future<void> initialize() async {
  // 1. Set foreground presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 2. Initialize Firebase
  await Firebase.initializeApp();

  // 3. Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Initialize local notifications (Android & iOS)
  await _initializeLocalNotifications();

  // 5. Create Android notification channel
  await _createNotificationChannel();

  // 6. Request permissions
  await requestPermissions();

  // 7. Setup message handlers
  _setupMessageHandlers();
}
```

### Background Message Handler

**Top-level function** (required by FCM):

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
```

**Key Points:**
- Must be top-level function (not inside a class)
- `@pragma('vm:entry-point')` annotation required
- Initializes Firebase before processing
- Handles notifications when app is terminated or in background

---

## 4. Notification Handlers

### Message Handlers Setup

```dart
static void _setupMessageHandlers() {
  // 1. Foreground messages (app is active)
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  // 2. Background/terminated click handling
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);
}
```

### Foreground Handler

**When app is in foreground:**

```dart
static Future<void> _handleForegroundMessage(RemoteMessage message) async {
  if (kDebugMode) {
    print('Foreground message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }

  // Show local notification
  await _showLocalNotification(message);
}
```

**What it does:**
- Logs message details in debug mode
- Displays local notification with full presentation
- Ensures user sees notification even when app is active

### Background Click Handler

**When user taps notification (app in background/terminated):**

```dart
static void _handleMessageClick(RemoteMessage message) {
  if (kDebugMode) {
    print('Notification clicked: ${message.data}');
  }

  // TODO: Handle navigation based on notification data
  // Example:
  // if (message.data['type'] == 'CANDIDATE_UNLOCK') {
  //   navigateToCandidate(message.data['candidate_id']);
  // }
}
```

**Current Status:** Navigation not implemented (placeholder for future)

---

## 5. Platform-Specific Configuration

### Android Configuration

**File:** `android/app/src/main/AndroidManifest.xml`

#### Permissions

```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

**Permission Descriptions:**
- `WAKE_LOCK`: Wake device when notification arrives
- `RECEIVE_BOOT_COMPLETED`: Restart notification listeners after reboot
- `VIBRATE`: Vibration support for notifications

#### FCM Service

```xml
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

#### Metadata

```xml
<!-- Default notification channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />

<!-- Disable auto-init (manual control) -->
<meta-data
    android:name="firebase_messaging_auto_init_enabled"
    android:value="false" />

<!-- Disable analytics collection -->
<meta-data
    android:name="firebase_analytics_collection_enabled"
    android:value="false" />
```

#### Notification Channel

```dart
static Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',           // ID
    'High Importance Notifications',      // Name
    description: 'This channel is used for important notifications.',
    importance: Importance.max,           // Max importance
    playSound: true,
    enableVibration: true,
    showBadge: true,
    enableLights: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
```

**Channel Settings:**
- **ID:** `high_importance_channel`
- **Importance:** Max (shows as pop-up banner)
- **Sound:** Enabled
- **Vibration:** Enabled
- **Badge:** Enabled (app icon badge count)
- **Lights:** Enabled (notification LED)

---

### iOS Configuration

**File:** `ios/Runner/AppDelegate.swift`

#### Setup (Lines 25-47)

```swift
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    // Configure Firebase Messaging
    Messaging.messaging().delegate = self

    // Request user notification permissions
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
    }

    // Register for remote notifications
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

#### APNS Token Handling

```swift
override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    Messaging.messaging().apnsToken = deviceToken
}
```

**What it does:**
- Receives APNS (Apple Push Notification Service) token
- Forwards to Firebase Messaging for FCM token generation

#### Foreground Presentation (iOS 14+)

```swift
@available(iOS 10, *)
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
) {
    if #available(iOS 14.0, *) {
        completionHandler([[.banner, .sound, .badge]])
    } else {
        completionHandler([[.alert, .sound, .badge]])
    }
}
```

**Presentation Options:**
- **iOS 14+:** Banner, Sound, Badge
- **iOS 10-13:** Alert, Sound, Badge

#### FCM Token Refresh

```swift
extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}
```

**What it does:**
- Called when FCM token is refreshed
- Posts notification for Flutter to catch and update server

#### Entitlements

**File:** `ios/Runner/Runner.entitlements`

```xml
<key>aps-environment</key>
<string>development</string>
```

**IMPORTANT:** Change to `production` for App Store release!

---

## 6. Notification Flow by App State

### Foreground (App Active)

```
FCM Message Arrives
    ↓
FirebaseMessaging.onMessage.listen()
    ↓
_handleForegroundMessage(message)
    ↓
_showLocalNotification(message)
    ↓
FlutterLocalNotificationsPlugin.show()
    ↓
Notification displayed with banner + sound + badge
```

**User Experience:**
- Sees notification banner at top of screen
- Hears notification sound
- App badge updated (if supported)
- Can tap to open (navigation not implemented yet)

---

### Background (App Inactive)

```
FCM Message Arrives
    ↓
_firebaseMessagingBackgroundHandler(message)
    ↓
Log message details (debug mode)
    ↓
FCM displays notification (system tray)
```

**User Experience:**
- Sees notification in system tray
- Tapping notification opens app
- `onMessageOpenedApp` triggered with message data

---

### Terminated (App Closed)

```
FCM Message Arrives
    ↓
_firebaseMessagingBackgroundHandler(message)
    ↓
Log message details (debug mode)
    ↓
FCM displays notification (system tray)
```

**User Experience:**
- Same as background state
- Tapping notification launches app
- `getInitialMessage()` can retrieve data (not currently used)

---

### Notification Click

```
User Taps Notification
    ↓
If app in background/terminated:
    ↓
FirebaseMessaging.onMessageOpenedApp.listen()
    ↓
_handleMessageClick(message)
    ↓
Navigate based on message.data (not implemented)
```

**Current Implementation:**
- Only logs notification data
- Navigation logic commented out (placeholder)

**Future Enhancement:**
```dart
static void _handleMessageClick(RemoteMessage message) {
  final type = message.data['type'];

  switch (type) {
    case 'CANDIDATE_UNLOCK':
      navigateToCandidateDetails(message.data['candidate_id']);
      break;
    case 'SUBSCRIPTION_WARNING':
      navigateToSubscriptionPlans();
      break;
    case 'WALLET_RECHARGE':
      navigateToWallet();
      break;
    default:
      navigateToNotifications();
  }
}
```

---

## 7. Local Notifications

### Initialization

```dart
static Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}
```

**Settings:**
- **Android Icon:** Uses app launcher icon
- **iOS Permissions:** Manual (requested separately via `requestPermissions()`)

---

### Show Local Notification

```dart
static Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;

  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,  // Unique notification ID
      notification.title ?? 'Workfina',
      notification.body ?? 'You have a new notification',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),  // Pass data as JSON string
    );
  }
}
```

**Key Features:**
- **Unique ID:** Uses `message.hashCode` for each notification
- **Fallback Title:** "Workfina" if no title provided
- **Fallback Body:** Generic message if no body
- **Payload:** Stores FCM data as JSON (for click handling)
- **Platform Specific:** Different settings for Android/iOS

**Android Settings:**
- High importance (pop-up banner)
- High priority
- Shows timestamp
- Sound + Vibration enabled

**iOS Settings:**
- Alert, Badge, Sound all enabled

---

## 8. FCM Token Management

### Get FCM Token

```dart
static Future<String?> getToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      await _saveTokenToPrefs(token);
    }

    return token;
  } catch (e) {
    if (kDebugMode) {
      print('Error getting FCM token: $e');
    }
    return null;
  }
}
```

**What it does:**
- Requests FCM token from Firebase
- Logs token in debug mode (for testing)
- Saves to SharedPreferences
- Returns token for server upload

---

### Save Token to Storage

```dart
static Future<void> _saveTokenToPrefs(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fcm_token', token);
}
```

---

### Get Saved Token

```dart
static Future<String?> getSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('fcm_token');
}
```

**Use Case:** Check if token exists before requesting new one

---

### Upload Token to Server

**File:** `lib/services/api_service.dart` (Lines 1392-1402)

```dart
Future<void> uploadFCMToken(String token) async {
  try {
    await dio.post(
      '$baseUrl/auth/update-fcm-token/',
      data: {'token': token},
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading FCM token: $e');
    }
  }
}
```

**Called After Login:**
```dart
// In auth_controller.dart or login flow
final token = await NotificationService.getToken();
if (token != null) {
  await ApiService().uploadFCMToken(token);
}
```

---

## 9. Notification Permissions

### Request Permissions

```dart
static Future<void> requestPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
    criticalAlert: false,
  );

  if (kDebugMode) {
    print('User granted permission: ${settings.authorizationStatus}');
  }
}
```

**Permissions Requested:**
- **Alert:** Show notification banners
- **Badge:** Update app icon badge count
- **Sound:** Play notification sounds
- **Provisional:** No (requires explicit user approval)
- **Critical Alert:** No (high-priority system alerts)

**Platform Behavior:**
- **Android:** Auto-granted for most notification types
- **iOS:** Explicit user permission dialog

---

### Check Permissions

```dart
static Future<bool> checkPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.getNotificationSettings();

  return settings.authorizationStatus == AuthorizationStatus.authorized;
}
```

**Returns:**
- `true` if notifications are authorized
- `false` if denied or not determined

---

### Authorization Status Values

```dart
enum AuthorizationStatus {
  authorized,      // User granted permission
  denied,          // User denied permission
  notDetermined,   // User hasn't responded yet
  provisional,     // Provisional authorization (iOS 12+)
}
```

---

### App Startup Flow

**File:** `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize without permissions (delayed for better UX)
  await NotificationService.initializeWithoutPermissions();

  // Get FCM token
  final fcmToken = await NotificationService.getToken();

  // Check if permissions already granted
  final hasPermissions = await NotificationService.checkPermissions();

  // Request permissions later (after UI loads)
  await NotificationService.requestPermissionsLater();

  runApp(MyApp());
}
```

**Alternative Initialization:**

```dart
static Future<void> initializeWithoutPermissions() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initializeLocalNotifications();
  await _createNotificationChannel();

  // Skip requestPermissions() here
  _setupMessageHandlers();
}
```

**Permission Request Timing:**

Permissions are actually requested in `RecruiterDashboard` (line 86) after UI loads:

```dart
@override
void initState() {
  super.initState();
  NotificationService.requestPermissionsLater();
}
```

**Why Delayed?**
- Better user experience (doesn't block app launch)
- User sees app first, then permission dialog
- Reduces permission rejection rate

---

## 10. Server Integration

### Backend Notification API Endpoints

**Base URL:** `http://localhost:8000/api`

#### Get User Notifications
```
GET /notifications/?page={page}
Authorization: Bearer {token}
```

#### Get Notification Count
```
GET /notifications/count/
Authorization: Bearer {token}
```

#### Mark as Read
```
POST /notifications/{id}/read/
Authorization: Bearer {token}
```

#### Mark All as Read
```
POST /notifications/mark-all-read/
Authorization: Bearer {token}
```

#### Send Test Notification
```
POST /notifications/test/
Authorization: Bearer {token}

Body:
{
  "title": "Test",
  "body": "Test notification"
}
```

---

### Notification Types

```dart
// Notification types sent by server
enum NotificationType {
  CANDIDATE_UNLOCK,
  SUBSCRIPTION_WARNING,
  SUBSCRIPTION_EXPIRED,
  WALLET_RECHARGE,
  GENERAL,
}
```

**Notification Data Structure:**

```json
{
  "id": "notif_123",
  "title": "Candidate Unlocked",
  "body": "You have unlocked John Doe's profile",
  "type": "CANDIDATE_UNLOCK",
  "is_read": false,
  "data": {
    "candidate_id": "456",
    "candidate_name": "John Doe"
  },
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### Topic Subscription

```dart
// Subscribe to topic
static Future<void> subscribeToTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error subscribing to topic: $e');
    }
  }
}

// Unsubscribe from topic
static Future<void> unsubscribeFromTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
```

**Use Cases:**
- Subscribe all recruiters to "recruiter_updates"
- Subscribe all candidates to "candidate_updates"
- Subscribe to region-specific topics
- Promotional campaign topics

---

## 11. Notification UI

**File:** `lib/views/screens/notification/notification_screen.dart`

### Features

1. **Tab Filters**
   - All notifications
   - Unread only
   - Read only

2. **Notification List**
   - Title and body
   - Time ago (e.g., "2 hours ago")
   - Status icons (Delivered/Failed/Sent)
   - Read/unread indicator

3. **Actions**
   - Pull-to-refresh
   - Mark as read (tap notification)
   - Mark all as read (toolbar action)

4. **Empty States**
   - No notifications message
   - Icon + text for empty state

### UI Components

```dart
// Notification tile
ListTile(
  leading: CircleAvatar(
    child: Icon(Icons.notifications),
  ),
  title: Text(notification.title),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(notification.body),
      SizedBox(height: 4),
      Text(
        timeAgo(notification.createdAt),
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  ),
  trailing: notification.isRead
    ? null
    : Icon(Icons.circle, color: Colors.blue, size: 12),
  onTap: () {
    // Mark as read
    markAsRead(notification.id);
  },
)
```

---

## 12. Testing Notifications

### Test Direct Notification

```dart
static Future<void> testDirectNotification() async {
  RemoteMessage testMessage = RemoteMessage(
    notification: RemoteNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Workfina',
    ),
    data: {
      'type': 'TEST',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  await _showLocalNotification(testMessage);

  if (kDebugMode) {
    print('Test notification sent');
  }
}
```

**Usage:**
```dart
// In any screen
NotificationService.testDirectNotification();
```

---

### Debug FCM Token

**In debug mode, token is printed to console:**

```
[log] FCM Token: fL3Ck8xRQvG-9qY...
```

**Use this token to:**
1. Test notifications from Firebase Console
2. Send test notifications via Postman
3. Debug server-side notification issues

---

### Firebase Console Testing

1. Go to Firebase Console
2. Select your project
3. Navigate to Cloud Messaging
4. Click "Send test message"
5. Enter FCM token from debug logs
6. Enter title and body
7. Send notification

---

## 13. Troubleshooting

### Notifications Not Received

**Check:**
1. ✅ FCM token generated? (Check debug logs)
2. ✅ Token uploaded to server?
3. ✅ Permissions granted? (Call `checkPermissions()`)
4. ✅ Firebase initialized? (Check `main.dart`)
5. ✅ Background handler registered?
6. ✅ Device has internet connection?

---

### iOS Notifications Not Working

**Check:**
1. ✅ APNS certificate configured in Firebase Console
2. ✅ `Runner.entitlements` has Push Notifications capability
3. ✅ App ID has Push Notifications enabled in Apple Developer Portal
4. ✅ Using correct bundle ID
5. ✅ Entitlements set to `production` for release builds
6. ✅ iOS simulator cannot receive remote notifications (use real device)

---

### Android Notifications Not Showing

**Check:**
1. ✅ Notification channel created? (Check `_createNotificationChannel()`)
2. ✅ `google-services.json` in `android/app/`
3. ✅ Firebase dependencies in `android/app/build.gradle`
4. ✅ Permissions in `AndroidManifest.xml`
5. ✅ Battery optimization disabled for app (on some devices)
6. ✅ Notification channels not manually disabled by user

---

### Foreground Notifications Not Displaying

**Check:**
1. ✅ `FirebaseMessaging.onMessage.listen()` registered
2. ✅ `_handleForegroundMessage()` called
3. ✅ Local notifications initialized
4. ✅ Notification permission granted
5. ✅ Local notification channel matches FCM channel ID

---

### Background Handler Not Called

**Check:**
1. ✅ Function is top-level (not inside class)
2. ✅ `@pragma('vm:entry-point')` annotation present
3. ✅ Firebase initialized in handler
4. ✅ Handler registered before `runApp()`

---

### Token Not Uploading to Server

**Check:**
1. ✅ API endpoint `/auth/update-fcm-token/` exists
2. ✅ User is authenticated (token in headers)
3. ✅ `uploadFCMToken()` called after login
4. ✅ Network connectivity
5. ✅ Check API logs for errors

---

## Best Practices

### 1. Permission Timing
✅ Request permissions after showing value proposition
✅ Don't request on app launch (poor UX)
❌ Don't spam permission requests

### 2. Token Management
✅ Upload token immediately after login
✅ Store token locally for comparison
✅ Re-upload on token refresh
❌ Don't upload token on every app launch

### 3. Notification Handling
✅ Show local notification for foreground messages
✅ Handle all app states (foreground/background/terminated)
✅ Implement click navigation
❌ Don't ignore notification data

### 4. User Experience
✅ Clear, concise notification titles
✅ Actionable notification bodies
✅ Proper notification grouping
❌ Don't spam users with too many notifications

### 5. Testing
✅ Test on real devices (iOS simulator doesn't support)
✅ Test all app states
✅ Test permission flows
✅ Test token refresh scenarios

---

## Future Enhancements

### Planned Features

1. **Navigation Handling**
   - Navigate to specific screens based on notification type
   - Deep linking support

2. **Notification Types**
   - Different channels for different notification types
   - Custom sounds per type

3. **Action Buttons**
   - Quick actions in notification (e.g., "View", "Dismiss")

4. **Notification Grouping**
   - Group related notifications
   - Summary notifications for multiple items

5. **Rich Notifications**
   - Images in notifications
   - Progress indicators
   - Custom layouts

6. **Analytics**
   - Track notification open rates
   - A/B test notification content
   - User engagement metrics

---

## Summary

### Key Components

| Component | Purpose |
|-----------|---------|
| NotificationService | Core notification logic & FCM handling |
| Background Handler | Processes notifications when app terminated |
| Local Notifications | Displays notifications in foreground |
| FCM Token Management | Token generation, storage, server sync |
| Permission System | Request & check notification permissions |
| Notification UI | In-app notification center |

### Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Fully Supported | All features working |
| iOS | ✅ Fully Supported | Requires APNS certificate |
| Web | ❌ Not Supported | FCM Web not configured |

### App State Coverage

| State | Notification Display | Click Handling |
|-------|---------------------|----------------|
| Foreground | ✅ Local Notification | ✅ (navigation pending) |
| Background | ✅ FCM System Tray | ✅ (navigation pending) |
| Terminated | ✅ FCM System Tray | ✅ (navigation pending) |

---

**Last Updated:** January 2026
**Version:** 1.0.0
**Maintained By:** Workfina Development Team
