import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/helpers/ads/ads_helper.dart';
import 'package:chat_messenger/helpers/ads/banner_ad_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/i18n/app_languages.dart';
import 'package:chat_messenger/config/theme_config.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
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
        title: Text('choose_a_language'.tr),
      ),
      body: Column(
        children: [
          // Show Banner Ad
          BannerAdHelper.showBannerAd(),

          // Body content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding * 2,
              ),
              children: AppLanguages().keys.entries.map<Widget>((entry) {
                // Vars
                final String langName = entry.value['lang_name'] ?? entry.key;
                // Check selected
                final bool isSelected =
                    PreferencesController.instance.langName == langName;

                return ListTile(
                  selected: isSelected,
                  shape: const Border(
                    bottom: BorderSide(color: greyColor, width: 0.5),
                  ),
                  leading: Image.asset(
                    'assets/flags/${entry.key}.png',
                    width: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, __) =>
                        const Icon(Icons.translate, size: 25),
                  ),
                  title: Text(langName),
                  trailing: const Icon(IconlyLight.arrowRight2),
                  onTap: () {
                    // Confirm change language
                    DialogHelper.showAlertDialog(
                      title: Text('${'change_language'.tr}?'),
                      icon: const Icon(Icons.translate, color: primaryColor),
                      content: Text(langName.tr),
                      actionText: 'change'.tr.toUpperCase(),
                      action: () {
                        Get.back();
                        PreferencesController.instance.locale.value =
                            Locale(entry.key);
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
