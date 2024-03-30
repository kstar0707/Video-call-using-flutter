import 'package:chat_messenger/api/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/routes/app_pages.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'controllers/preferences_controller.dart';
import 'firebase_options.dart';
import 'i18n/app_languages.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// <-- Initialize Firebase App -->
  /// TODO: 👉 Please follow the [Documentation - README FIRST] instructions
  /// to generate the required [firebase_options.dart] for your app.
  ///
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    // Initialize the Mobile Ads SDK
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Get preferences controller
    final preferencesController = Get.put(PreferencesController());

    // Get theme mode
    final bool isDarkMode = preferencesController.isDarkMode.value;

    return GetMaterialApp(
      locale: preferencesController.locale.value,
      fallbackLocale: const Locale('en'),
      translations: AppLanguages(),
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(context).lightTheme,
      darkTheme: AppTheme.of(context).darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
