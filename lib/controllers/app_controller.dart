import 'package:chat_messenger/helpers/settings_helper.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/models/app_info.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  // Get the current instance
  static AppController instance = Get.find();

  final Rx<AppInfo> _appInfo = Rx(AppInfo());

  // Get AppInfo instance
  AppInfo get appInfo => _appInfo.value;

  @override
  void onInit() {
    _loadAppSettings();
    super.onInit();
  }

  Future<void> _loadAppSettings() async {
    final AppInfo result = await SettingsHelper.getAppSettings();
    _appInfo.value = result;
    debugPrint('AppController.appInfo -> updated');
  }
}
