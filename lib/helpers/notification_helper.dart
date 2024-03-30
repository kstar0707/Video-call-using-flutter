import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/app_logo.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/models/call.dart';
import 'package:chat_messenger/routes/app_routes.dart';

import 'dialog_helper.dart';

abstract class NotificationHelper {
  //
  // NotificationHelper
  //

  // Handle notification click. E.g: open a route..
  static Future<void> onNotificationClick({
    bool openRoute = false,
    Map<String, dynamic>? payload,
  }) async {
    // Vars
    String type = payload!['type'] ?? '';
    String title = payload['title'] ?? '';
    String message = payload['message'] ?? '';

    // Handle notification type
    switch (type) {
      case 'call':
        // Get call data
        final Call call = Call.fromMap(data: jsonDecode(payload['call']));

        // Go to incoming call page
        Get.toNamed(AppRoutes.incomingCall, arguments: {'call': call});
        break;

      case 'alert':
        // Show alert dialog info
        DialogHelper.showAlertDialog(
          icon: const AppLogo(width: 35, height: 35),
          title: title.isNotEmpty ? Text(title) : const Text(AppConfig.appName),
          content: Text(message),
          actionText: 'OK'.tr,
          action: () => Get.back(),
          showCancelButton: false,
        );
        break;
    }
  }
}
