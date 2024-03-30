import 'banner_ad_helper.dart';
import 'interstitial_ad_helper.dart';

abstract class AdsHelper {
  //
  // Load Banner & Interstitial Ads
  static Future<void> loadAds({bool interstitial = true}) async {
    // Load Banner Ad
    BannerAdHelper.loadBannerAd();

    // Load and show Interstitial Ad
    if (interstitial) {
      InterstitialAdHelper.showInterstitialAd();
    }
  }

  // Dispose Ads
  static void disposeAds() {
    // Dispose Banner Ad
    BannerAdHelper.disposeBannerAd();

    // Dispose Interstitial Ad
    InterstitialAdHelper.disposeInterstitialAd();
  }
}
