import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/components/default_button.dart';
import 'package:chat_messenger/screens/auth/password/controller/forgot_pwd_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        padding: const EdgeInsets.all(defaultPadding),
        margin: const EdgeInsets.symmetric(vertical: defaultMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "reset_password".tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: Text(
                "enter_the_email_address_associated_with_your_account".tr,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: greyColor),
              ),
            ),
            Form(
              key: controller.formKey,
              child: TextFormField(
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                controller: controller.emailController,
                validator: (String? value) {
                  // Validate email
                  if (GetUtils.isEmail(value ?? '')) {
                    return null;
                  }
                  return 'enter_valid_email_address'.tr;
                },
                decoration: InputDecoration(
                  hintText: 'enter_your_email'.tr,
                  prefixIcon: const Icon(IconlyLight.message),
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Send reset password
            Obx(
              () => DefaultButton(
                height: 45,
                isLoading: controller.isLoading.value,
                width: double.maxFinite,
                text: 'send'.tr,
                onPress: () => controller.sendResetPassword(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
