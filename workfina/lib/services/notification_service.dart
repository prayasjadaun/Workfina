import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('[DEBUG] ========= BACKGROUND FCM MESSAGE =========');
    print('[DEBUG] Message ID: ${message.messageId}');
    print('[DEBUG] Title: ${message.notification?.title}');
    print('[DEBUG] Body: ${message.notification?.body}');
    print('[DEBUG] Data: ${message.data}');
    print('[DEBUG] =======================================');
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _createNotificationChannel();
    await _requestPermissions();
    _setupMessageHandlers();

    _isInitialized = true;
  }

  static Future<void> initializeWithoutPermissions() async {
    if (_isInitialized) return;

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _createNotificationChannel();
    _setupMessageHandlers();

    _isInitialized = true;
  }

  static Future<void> requestPermissionsLater() async {
    if (!_isInitialized) {
      await initializeWithoutPermissions();
    }
    await _requestPermissions();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('[DEBUG] ========= FCM MESSAGE RECEIVED =========');
      print('[DEBUG] Message ID: ${message.messageId}');
      print('[DEBUG] Title: ${message.notification?.title}');
      print('[DEBUG] Body: ${message.notification?.body}');
      print('[DEBUG] Data: ${message.data}');
      print('[DEBUG] From: ${message.from}');
      print('[DEBUG] =====================================');
    }

    await _showLocalNotification(message);
  }

  static void _handleMessageClick(RemoteMessage message) {
    if (kDebugMode) {
      print('[DEBUG] Message clicked: ${message.data}');
    }
    // Handle navigation based on notification data
  }

  // notification_service.dart - add this method
  static Future<bool> checkPermissions() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    print('[DEBUG] Permission status: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Add this test function in notification_service.dart
  static Future<void> testDirectNotification() async {
    await _showLocalNotification(
      RemoteMessage(
        messageId: 'test-123',
        notification: const RemoteNotification(
          title: 'Test Notification',
          body: 'This is a direct test notification',
        ),
        data: {'test': 'true'},
      ),
    );
    print('[DEBUG] Direct test notification triggered');
  }

  // notification_service.dart
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Workfina',
      message.notification?.body ?? 'You have a new notification',
      notificationDetails,
      payload: jsonEncode(message.data),
    );

    print('[DEBUG] Local notification show() called');
  }

  static Future<String?> getToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print('[DEBUG] FCM Token: $token');
      }
      await _saveTokenToPrefs(token);
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Error getting FCM token: $e');
      }
      return null;
    }
  }

  static Future<void> _saveTokenToPrefs(String? token) async {
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }
  }

  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      if (kDebugMode) {
        print('[DEBUG] Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Error subscribing to topic: $e');
      }
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('[DEBUG] Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DEBUG] Error unsubscribing from topic: $e');
      }
    }
  }
}
