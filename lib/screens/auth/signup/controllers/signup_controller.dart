import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/helpers/settings_helper.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/config/theme_config.dart';

class SignUpController extends GetxController {
  // Variables
  final RxBool isLoading = RxBool(false);
  // SignUp info
  final Rxn<File> photoFile = Rxn();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void onInit() {
    _setDisplayName();
    super.onInit();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void _setDisplayName() {
    // Get social login name
    final String? displayName =
        AuthController.instance.firebaseUser?.displayName;
    // Check it
    if (displayName != null) {
      nameController.text = displayName;
      usernameController.text = AppHelper.sanitizeUsername(displayName);
    }
  }

  // <-- Create Account -->
  Future<void> signUp() async {
    // Check the form
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    // Show dialog
    DialogHelper.showProcessingDialog(
      title: 'creating_account'.tr,
      barrierDismissible: false,
    );

    // Create user account
    final result = await UserApi.createAccount(
      photoFile: photoFile.value,
      fullname: nameController.text.trim(),
      username: usernameController.text.trim(),
    );

    print(result);
    // Check result
    if (result) {
      // Get current user
      await AuthController.instance.getCurrentUserAndLoadData();

      // Close previous dialog
      DialogHelper.closeDialog();

      // Show confirm dialog
      DialogHelper.showAlertDialog(
        icon: const Icon(Icons.check_circle, color: primaryColor),
        title: Text('success'.tr),
        content: Text(
          'your_profile_account_has_been_successfully_created'.tr,
          style: const TextStyle(fontSize: 16),
        ),
        actionText: 'get_started'.tr.toUpperCase(),
        // Go to home screen
        action: () => Future(() => Get.offAllNamed(AppRoutes.home)),
        showCancelButton: false,
        barrierDismissible: false,
      );

      // Update admin statistics
      SettingsHelper.updateTotalUsers(true);
    } else {
      // Close dialog
      DialogHelper.closeDialog();

      // Show message
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'failed_to_create_account'.trParams(
          {'error': result.toString()},
        ),
      );
    }
    isLoading.value = false;
  }
}
