import 'package:flutter/material.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/badge_indicator.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/tabs/calls/components/clear_calls_button.dart';
import 'package:chat_messenger/tabs/calls/controller/call_history_controller.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:chat_messenger/tabs/stories/controller/story_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/helpers/ads/ads_helper.dart';
import 'package:chat_messenger/helpers/ads/banner_ad_helper.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/components/app_logo.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/services/firebase_messaging_service.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import 'components/search_chat_input.dart';
import 'controller/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    // Init other controllers
    Get.put(ReportController(), permanent: true);
    Get.put(PreferencesController(), permanent: true);

    // Load Ads
    AdsHelper.loadAds(interstitial: false);

    // Listen to incoming firebase push notifications
    FirebaseMessagingService.initFirebaseMessagingUpdates();

    // Update user presence
    UserApi.updateUserPresenceInRealtimeDb();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // <-- Handle the user presence -->
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // Set User status Online
        UserApi.updateUserPresence(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Set User status Offline
        UserApi.updateUserPresence(false);
        break;
    }
  }
  // END

  @override
  Widget build(BuildContext context) {
    // Get Controllers
    final HomeController homeController = Get.find();
    final ChatController chatController = Get.find();
    final GroupController groupController = Get.find();
    final CallHistoryController callController = Get.find();
    final StoryController storyController = Get.find();

    // Others
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final Color color = isDarkMode ? primaryColor : Colors.white;

    return Obx(() {
      // Get page index
      final int pageIndex = homeController.pageIndex.value;
      // Get current user
      final User currentUer = AuthController.instance.currentUser;

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          toolbarHeight: pageIndex == 0 ? 80 : 65,
          title: Row(
            children: [
              // App logo
              AppLogo(width: 35, height: 35, color: color),
              const SizedBox(width: 16),
              // App name
              Text(
                AppConfig.appName,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: color, fontSize: 20),
              ),
            ],
          ),
          actions: [
            // Change Theme Mode
            if (pageIndex == 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () =>
                      PreferencesController.instance.isDarkMode.toggle(),
                  icon: const Icon(Icons.brightness_6, color: Colors.white),
                ),
              ),

            // Clear call log
            if (pageIndex == 3) const ClearCallsButton(),

            // Go to session page
            if (pageIndex == 4)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.session),
                  icon: const Icon(IconlyLight.logout, color: Colors.white),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Chats
              if (pageIndex == 0) const SearchChatInput(),
              // Show Banner Ad
              if (pageIndex != 0)
                BannerAdHelper.showBannerAd(margin: pageIndex == 1 ? 8 : 0),
              // Show the body content
              Expanded(child: homeController.pages[pageIndex]),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (int index) {
            homeController.pageIndex.value = index;
            // View stories
            if (index == 2) {
              storyController.viewStories();
            }
            // View calls
            if (index == 3) {
              callController.viewCalls();
            }
          },
          type: BottomNavigationBarType.fixed,
          items: [
            // Chats
            BottomNavigationBarItem(
              label: 'chats'.tr,
              icon: BadgeIndicator(
                icon: pageIndex == 0 ? IconlyBold.chat : IconlyLight.chat,
                isNew: chatController.newMessage,
              ),
            ),
            // Groups
            BottomNavigationBarItem(
              label: 'groups'.tr,
              icon: BadgeIndicator(
                icon: pageIndex == 1 ? IconlyBold.user3 : IconlyLight.user3,
                isNew: groupController.newMessage,
              ),
            ),
            // Stories
            BottomNavigationBarItem(
              label: 'stories'.tr,
              icon: BadgeIndicator(
                icon: IconlyBold.play,
                isNew: storyController.hasUnviewedStories,
                iconSize: 45,
                iconColor: primaryColor,
              ),
            ),
            // Calls
            BottomNavigationBarItem(
              label: 'calls'.tr,
              icon: BadgeIndicator(
                icon: pageIndex == 3 ? IconlyBold.call : IconlyLight.call,
                isNew: callController.newCalls.isNotEmpty,
              ),
            ),
            // Profile account
            BottomNavigationBarItem(
              label: 'profile'.tr,
              icon: CachedCircleAvatar(
                imageUrl: currentUer.photoUrl,
                iconSize: currentUer.photoUrl.isEmpty ? 22 : null,
                borderColor: pageIndex == 4
                    ? primaryColor
                    : primaryColor.withOpacity(0.5),
                radius: 12,
              ),
            ),
          ],
        ),
      );
    });
  }
}
