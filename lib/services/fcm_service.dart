// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TOP-LEVEL background handler (must be outside any class)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the system in background isolate.
  debugPrint('📬 [FCM Background] ${message.notification?.title}');
}

// ─────────────────────────────────────────────────────────────────────────────
// FcmService
// ─────────────────────────────────────────────────────────────────────────────

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();

  /// Android notification channel (high importance → shows heads-up banner)
  static const _channel = AndroidNotificationChannel(
    'formanova_high',
    'Formanova Notifications',
    description: 'Course updates, job alerts, and application status',
    importance: Importance.high,
    playSound: true,
  );

  // ── Public init ────────────────────────────────────────────────────────────

  Future<void> init(BuildContext context) async {
    // 1. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permission (iOS & Android 13+)
    await _requestPermission();

    // 3. Create Android channel
    await _createAndroidChannel();

    // 4. Initialise local notifications (for foreground display)
    await _initLocalNotifications(context);

    // 5. Save FCM token to Firestore
    await _saveToken();

    // 6. Listen for token refresh
    _fcm.onTokenRefresh.listen(_updateToken);

    // 7. Handle foreground messages
    FirebaseMessaging.onMessage.listen((msg) => _onForeground(msg, context));

    // 8. Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => _handleNavigation(msg, context),
    );

    // 9. Handle notification that launched the app from terminated state
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      // Delay to let navigator settle
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) _handleNavigation(initial, context);
    }
  }

  // ── Permission ─────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('📲 FCM permission: ${settings.authorizationStatus}');
  }

  // ── Android channel ────────────────────────────────────────────────────────

  Future<void> _createAndroidChannel() async {
    if (Platform.isAndroid) {
      await _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  // ── Local notifications init ───────────────────────────────────────────────

  Future<void> _initLocalNotifications(BuildContext context) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotif.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        // User tapped a local notification while app was in foreground
        final payload = details.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            _navigate(data, context);
          } catch (_) {}
        }
      },
    );
  }

  // ── Token management ───────────────────────────────────────────────────────

  Future<void> _saveToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final token = await _fcm.getToken();
    if (token == null) return;

    await _writeToken(uid, token);
    debugPrint('✅ FCM token saved for $uid');
  }

  Future<void> _updateToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _writeToken(uid, token);
    debugPrint('🔄 FCM token refreshed for $uid');
  }

  Future<void> _writeToken(String uid, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': token,
      'fcmUpdatedAt': FieldValue.serverTimestamp(),
      'platform': Platform.isIOS ? 'ios' : 'android',
    });
  }

  /// Call this on logout to clear the token so no notifications arrive
  Future<void> clearToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': FieldValue.delete(),
    });
    await _fcm.deleteToken();
    debugPrint('🗑️ FCM token cleared on logout');
  }

  // ── Foreground message ─────────────────────────────────────────────────────

  Future<void> _onForeground(RemoteMessage msg, BuildContext context) async {
    debugPrint('📩 [FCM Foreground] ${msg.notification?.title}');

    final notification = msg.notification;
    if (notification == null) return;

    // Show a local heads-up notification (FCM suppresses UI in foreground)
    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF155DFC),
          styleInformation: BigTextStyleInformation(notification.body ?? ''),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(msg.data),
    );
  }

  // ── Navigation on tap ──────────────────────────────────────────────────────

  void _handleNavigation(RemoteMessage msg, BuildContext context) {
    debugPrint('🚀 [FCM Tap] navigating from data: ${msg.data}');
    _navigate(msg.data, context);
  }

  void _navigate(Map<String, dynamic> data, BuildContext context) {
    final type = data['type'] as String?;
    final route = _routeFor(type, data);
    if (route != null) {
      Navigator.pushNamed(context, route, arguments: data['args']);
    }
  }

  String? _routeFor(String? type, Map<String, dynamic> data) {
    switch (type) {
      case 'applicationAccepted':
      case 'applicationRejected':
      case 'applicationInterview':
      case 'applicationReviewing':
        return '/notifications'; // deep link to applied jobs

      case 'newApplicant':
        return '/recruteur/candidates';

      case 'courseEnrolled':
      case 'newStudentEnrolled':
      case 'lessonAdded':
        return '/notifications';

      case 'certificateEarned':
        return '/certificates';

      default:
        return '/notifications';
    }
  }
}
