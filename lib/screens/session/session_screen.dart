import 'package:chat_messenger/api/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/helpers/ads/ads_helper.dart';
import 'package:chat_messenger/helpers/ads/banner_ad_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/config/theme_config.dart';

class SesssionScreen extends StatefulWidget {
  const SesssionScreen({super.key});

  @override
  State<SesssionScreen> createState() => _SesssionScreenState();
}

class _SesssionScreenState extends State<SesssionScreen> {
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
    // Vars
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final Color? iconColor = isDarkMode ? primaryColor : null;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('account'.tr),
      ),
      body: Column(
        children: [
          // Show Banner Ad
          BannerAdHelper.showBannerAd(),
          // Body content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: Column(
              children: [
                // <-- Sign out -->
                ListTile(
                  title: Text('sign_out'.tr),
                  leading: Icon(IconlyLight.logout, color: iconColor),
                  trailing: const Icon(IconlyLight.arrowRight2),
                  onTap: () {
                    // Confirm sign out
                    DialogHelper.showAlertDialog(
                      title: Text('sign_out'.tr),
                      icon: const Icon(IconlyLight.logout, color: primaryColor),
                      content: Text('are_you_sure_you_want_to_sign_out'.tr),
                      actionText: 'YES'.tr,
                      action: () => AuthApi.signOut(),
                    );
                  },
                ),
                const Divider(height: 1),
                const SizedBox(height: 65),

                // <-- Delete Account -->
                SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Confirm delete account
                      DialogHelper.showAlertDialog(
                        title: Text('delete_account'.tr),
                        titleColor: errorColor,
                        icon: const Icon(IconlyLight.delete, color: errorColor),
                        content: Text(
                            'are_you_sure_you_want_to_delete_your_account'.tr),
                        actionText: 'DELETE'.tr,
                        action: () {
                          Get.back();
                          UserApi.deleteUserAccount();
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                    ),
                    icon: const Icon(
                      IconlyLight.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text('delete_account'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
