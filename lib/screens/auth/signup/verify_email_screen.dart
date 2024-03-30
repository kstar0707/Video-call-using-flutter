import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/default_button.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/components/custom_appbar.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        backgroundColor: Colors.transparent,
        leading: SizedBox.shrink(),
      ),
      body: Container(
        padding: const EdgeInsets.all(defaultPadding),
        margin: const EdgeInsets.symmetric(vertical: defaultMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            const Icon(IconlyBold.message, size: 80, color: primaryColor),
            const SizedBox(height: 8),

            // Title
            Text(
              "verify_your_email".tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // Desc 01
            Text(
              "we_ve_sent_an_email_verification_to_your_email_inbox_please_verify_your_email_to_complete_the_signup_process"
                  .tr,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: greyColor),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // Done button
            DefaultButton(
              height: 45,
              width: double.maxFinite,
              text: 'DONE'.tr,
              onPress: () => Future(() => Get.offAllNamed(AppRoutes.signIn)),
            ),
          ],
        ),
      ),
    );
  }
}
