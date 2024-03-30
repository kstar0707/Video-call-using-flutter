import 'package:chat_messenger/models/app_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class SettingsHelper {
  //
  // Statistics Helper
  //

  // Get settings reference
  static DocumentReference<Map<String, dynamic>> get _settingsRef =>
      FirebaseFirestore.instance.collection('AppInfo').doc('settings');

  // Get app settings
  static Future<AppInfo> getAppSettings() async {
    try {
      final doc = await _settingsRef.get();
      if (doc.exists) {
        return AppInfo.fromMap(doc.data()!);
      }
      return AppInfo();
    } catch (e) {
      // Debug
      debugPrint("Failed to fetch app settings. Error: $e");
      return AppInfo();
    }
  }

  static Future<void> updateTotalUsers(bool isIncrement) async {
    await _settingsRef.update({
      'totalUsers': FieldValue.increment(isIncrement ? 1 : -1),
    });
  }
}
