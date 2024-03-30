abstract class AppConfig {
  ///
  /// <-- CONFIG OF CONSTANT VALUES -->
  ///

  /// App Name
  static const String appName = "chatting_app";

  /// Email for Support
  static const String appEmail = "your@mail.com";

  /// App Version is displayed in settings > "About us" page.
  static const String appVersion = "Android v1.0.0 - iOS v1.0.0";

  // App identifiers used to share the app and rate it on Google Play/App Store.
  static const String iOsAppId = "123456789";
  static const String androidPackageName = "de.bau300.app1";

  /// Privacy Policy Link:
  static const String privacyPolicyUrl = "https://www.yoursite.com/privacy";

  /// Terms of Service Link:
  static const String termsOfServiceUrl = "https://www.yoursite.com/terms";

  ///
  ///  <-- Video & Voice call features -->
  /// Please get your agora APP_ID at: https://www.agora.io
  ///
  static const String agoraAppID = "520016d33d044a2dbe78267193554dc5";

  static const String certificate = "b188f83e55934a02a82bb76c98540ff7";

  static const String agoraToken = "007eJxTYLju//7ZWc3sW/qqLgsmr5/mfSUt4fgNMf+glKjMgIPenxcpMJgaGRgYmqUYG6cYmJgkGqUkpZpbGJmZG1oam5qapCSbtiozpzUEMjJIS8kzMzJAIIjPw5CWWVRckpyRmJeXmsPAAABLfCDu";

  ///
  ///  <-- GIF API KEY -->
  /// TODO: Get your GIF_API_KEY at: https://developers.giphy.com/dashboard
  ///
  static const String gifAPiKey = "YOUR_GIF_API_KEY";

  //
  // <-- GOOGLE ADMOB IDS - Section -->
  //

  //
  // <-- Android Platform -->
  //
  // TODO: Add your Android AD Unit IDs
  static const String androidBannerID = "Your-Android-Banner-ID";
  static const String androidInterstitialID = "Your-Android-Interstitial-ID";

  //
  // <-- IOS Platform -->
  //
  // TODO: Add your iOS AD Unit IDs
  static const String iOsBannerID = "Your-iOS-Banner-ID";
  static const String iOsInterstitialID = "Your-iOS-Interstitial-ID";
}
