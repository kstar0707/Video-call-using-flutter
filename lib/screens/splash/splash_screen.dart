import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/app_logo.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/screens/splash/controller/splash_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Init splash controller
    Get.put(SplashController());

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          Center(
            child: Column(
              children: [
                const AppLogo(),
                const SizedBox(height: 16),
                // App name
                Text(
                  AppConfig.appName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 20),
                ),
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                  ),
                  child: Text(
                    "app_short_description".tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: greyColor, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 50),
                const Center(child: LoadingIndicator(size: 50)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
