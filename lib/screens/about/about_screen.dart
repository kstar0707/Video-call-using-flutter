import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/components/app_logo.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/helpers/ads/ads_helper.dart';
import 'package:chat_messenger/helpers/ads/banner_ad_helper.dart';
import 'package:chat_messenger/config/theme_config.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    // Load Ads
    AdsHelper.loadAds();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    AdsHelper.disposeAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('about_us'.tr),
      ),
      body: Column(
        children: [
          // Show Banner Ad
          BannerAdHelper.showBannerAd(),

          // Body content
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // App logo
                const AppLogo(),
                const SizedBox(height: 10),

                // App name
                Text(
                  AppConfig.appName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 22),
                ),
                const SizedBox(height: 10),

                // App short description
                Text(
                  "app_short_description".tr,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // App version
                Text(
                  AppConfig.appVersion,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 18, color: greyColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
