import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/app_logo.dart';
import 'package:chat_messenger/components/default_button.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/config/theme_config.dart';

class SigninOrSignupScreen extends StatelessWidget {
  const SigninOrSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: 50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
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
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                height: 45,
                width: double.maxFinite,
                child: OutlinedButton(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.signIn, preventDuplicates: false),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'sign_in'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              DefaultButton(
                height: 45,
                width: double.maxFinite,
                text: 'sign_up'.tr,
                onPress: () => Get.toNamed(AppRoutes.signUpWithEmail,
                    preventDuplicates: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
