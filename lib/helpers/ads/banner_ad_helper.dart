import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/controllers/app_controller.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';

abstract class BannerAdHelper {
  ///
  /// Banner Ad Helper
  ///

  // TODO: Change it to "true" for debug
  static const bool _isTest = true;

  // Vars
  static BannerAd? _bannerAd;

  // Get Banner Ad ID
  static String get _getBannerID {
    // Check Test param
    if (_isTest) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }

    if (Platform.isAndroid) {
      return AppConfig.androidBannerID;
    } else if (Platform.isIOS) {
      return AppConfig.iOsBannerID;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // Expose the banner Ad
  BannerAd? get getBannerAd => _bannerAd;

  // Banner Ad Listener Events
  static final BannerAdListener _bannerAdListener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) {
      debugPrint('$BannerAd loaded.');
      _bannerAd = ad as BannerAd?;
    },
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      _bannerAd = null;
      debugPrint('BannerAd failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => debugPrint('Ad impression.'),
  );

  // Load Banner Ad
  static Future<void> loadBannerAd() async {
    // Check permission
    if (!AppController.instance.appInfo.showAds ||
        AuthController.instance.isPremiumMember) {
      return;
    }
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: _getBannerID,
      request: const AdRequest(),
      listener: _bannerAdListener,
    );
    return _bannerAd?.load();
  }

  // Show Banner Ad Widget
  static Widget showBannerAd({double margin = 0}) {
    return Obx(() {
      // Check permission
      if (AuthController.instance.isPremiumMember ||
          !AppController.instance.appInfo.showAds) {
        // Debug
        debugPrint('showBannerAd() -> showAds is disabled');
        return const SizedBox.shrink();
      }

      // Check banner ad instance
      if (_bannerAd == null) return const SizedBox.shrink();

      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: margin),
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    });
  }

  // Dispose Banner Ad
  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    debugPrint('BannerAd -> disposed');
  }
}
