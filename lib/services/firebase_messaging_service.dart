import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/helpers/notification_helper.dart';

abstract class FirebaseMessagingService {
  ///
  /// Handle incoming notifications while the app is in the Foreground
  ///
  static Future<void> initFirebaseMessagingUpdates() async {

    // Get inicial message if the application
    // has been opened from a terminated state.
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // Check notification data
    if (initialMessage != null) {
      // Debug
      debugPrint('getInitialMessage() -> data: ${initialMessage.data}');
      // Handle notification click
      NotificationHelper.onNotificationClick(
        openRoute: true,
        payload: initialMessage.data,
      );
    }

    // Returns a [Stream] that is called when a user
    // presses a notification message displayed via FCM.
    // Note: A Stream event will be sent if the app has
    // opened from a background state (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Debug
      debugPrint('onMessageOpenedApp() -> data: ${message.data}');
      // Handle notification click
      NotificationHelper.onNotificationClick(
        openRoute: true,
        payload: message.data,
      );
    });

    // Listen for incoming push notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Debug
      debugPrint('onMessage() -> data: ${message.data}');

      // Handle notification click
      NotificationHelper.onNotificationClick(payload: message.data);
    });

    // Request iOS permission
    _requestPushNotificationsForIOS();
  }

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  static void _requestPushNotificationsForIOS() async {
    if (Platform.isIOS) {
      // Request permission for iOS devices
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final AuthorizationStatus status = settings.authorizationStatus;
      // Debug
      debugPrint('_requestPushNotificationsForIOS() -> status: $status');
    }
  }
}
