import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/controllers/app_controller.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';

class InterstitialAdHelper {
  ///
  /// Interstitial Ad Helper
  ///

  // TODO: Change it to "true" for debug
  static const bool _isTest = true;

  // Variables
  static InterstitialAd? _interstitialAd;

  // Get Interstitial Ad ID
  static String get _getInterstitialID {
    // Check Test param
    if (_isTest) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }

    if (Platform.isAndroid) {
      return AppConfig.androidInterstitialID;
    } else if (Platform.isIOS) {
      return AppConfig.iOsInterstitialID;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // Create Interstitial Ad
  static Future<void> _createInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _getInterstitialID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('$ad loaded');
          _interstitialAd = ad;
          // Show Ad
          _interstitialAd!.show();
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error.');
          _interstitialAd = null;
          _createInterstitialAd();
        },
      ),
    );
  }

  // Show Interstitial Ads
  static Future<void> showInterstitialAd() async {
    // Check permission
    if (AuthController.instance.isPremiumMember ||
        !AppController.instance.appInfo.showAds) {
      // Debug
      debugPrint('showInterstitialAd() -> showAds is disabled');
      return;
    }

    // Create Ad
    await _createInterstitialAd();

    // Check loaded Ad to set callback
    if (_interstitialAd != null) {
      // Handle callbacks
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            debugPrint('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _createInterstitialAd();
        },
      );
    }
  }

  // Dispose Interstitial Ad
  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    debugPrint('InterstitialAd -> disposed');
  }
}
