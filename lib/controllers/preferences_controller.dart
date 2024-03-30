import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/i18n/app_languages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_messenger/config/theme_config.dart';

class PreferencesController extends GetxController {
  // Get the current instance
  static PreferencesController instance = Get.find();

  final RxBool isDarkMode = false.obs;
  final Rx<Locale> locale = Rx(const Locale('en'));
  final Rxn<String> chatWallpaperPath = Rxn();
  final Rxn<String> groupWallpaperPath = Rxn();
  final String _defaultLocale = 'en';

  // Get current language map
  Map<String, String> get language =>
      AppLanguages().keys[locale.value.toString()] ?? {};

  // Get current language name
  String get langName => language['lang_name'] ?? '';

  // SharedPreferences key names
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _chatWallpaperKey = 'chat_wallpaper';
  //static const String _groupWallpaperKey = 'group_wallpaper';

  @override
  void onInit() {
    // Load saved theme mode and locale from SharedPreferences
    _loadThemeMode();
    _loadLocale();

    // Listen to language change
    ever(locale, (Locale value) {
      _saveLocale(value);
      Get.updateLocale(value);
    });

    // Listen to theme change
    ever(isDarkMode, (bool value) {
      _changeTheme(value);
    });

    super.onInit();
  }

  // Update system overlay when the theme changes
  void _updateSystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      getSystemOverlayStyle(isDarkMode.value),
    );
  }

  // Change theme mode
  void _changeTheme(bool isDark) {
    isDarkMode.value = isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    _updateSystemOverlay();
    _saveThemeMode(isDark);
  }

  // Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDark);
  }

  // Get device theme mode
  bool get _isDeviceDarkMode {
    if (Get.context == null) return false;
    final brightness = MediaQuery.of(Get.context!).platformBrightness;
    return brightness == Brightness.dark;
  }

  // Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDark = prefs.getBool(_themeModeKey);
    // Check pref
    if (isDark == null) {
      // Get device theme mode
      isDarkMode.value = _isDeviceDarkMode;
    } else {
      isDarkMode.value = isDark;
    }
    _updateSystemOverlay();
  }

  void _updateLocale(String langCode) {
    locale.value = Locale(langCode.split('_').first);
  }

  // Save locale to SharedPreferences
  Future<void> _saveLocale(Locale newLocale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.toString());
  }

  bool _isLocaleSupported(String locale) {
    return AppLanguages().keys.containsKey(locale);
  }

  // Load locale from SharedPreferences
  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString(_localeKey);

    // Check result
    if (savedLocale == null) {
      // Get device locale
      final Locale? deviceLocale = Get.deviceLocale;

      // Check device locale
      final bool isSupported = _isLocaleSupported(deviceLocale.toString());
      _updateLocale(isSupported ? deviceLocale.toString() : _defaultLocale);
    } else {
      final bool isSupported = _isLocaleSupported(savedLocale);
      _updateLocale(isSupported ? savedLocale : _defaultLocale);
    }
  }

  ///
  ///  <-- 1-to-1 Chat Wallpaper -->
  ///
  Future<void> setChatWallpaper() async {
    // Pick image from camera/gallery
    final File? wallpaper = await DialogHelper.showPickImageDialog();
    if (wallpaper == null) return;
    // Update wallpaper path
    chatWallpaperPath.value = wallpaper.path;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatWallpaperKey, wallpaper.path);
  }

  Future<void> removeChatWallpaper() async {
    chatWallpaperPath.value = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_chatWallpaperKey);
  }

  Future<void> getChatWallpaperPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_chatWallpaperKey);

    if (path == null) return;

    // Check the file
    if (File(path).existsSync()) {
      chatWallpaperPath.value = path;
    }
  }
  // END

  ///
  ///  <-- Groups Wallpaper -->
  ///

  Future<void> setGroupWallpaper(String groupId) async {
    // Pick image from camera/gallery
    final File? wallpaper = await DialogHelper.showPickImageDialog();
    if (wallpaper == null) return;
    // Update wallpaper path
    groupWallpaperPath.value = wallpaper.path;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(groupId, wallpaper.path);
  }

  Future<void> removeGroupWallpaper(String groupId) async {
    groupWallpaperPath.value = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(groupId);
  }

  Future<void> getGroupWallpaperPath(String groupId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(groupId);

    if (path == null) return;

    // Check the file
    if (File(path).existsSync()) {
      groupWallpaperPath.value = path;
    }
    // debugPrint('getWallpaperPath() -> groupId: $groupId, path: $path');
  }

  // END
}
