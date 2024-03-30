import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/auth_api.dart';

class ForgotPasswordController extends GetxController {
  // Variables
  RxBool isLoading = RxBool(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetPassword() async {
    // Send valid data to server
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      // Send request to server
      await AuthApi.requestPasswordRecovery(emailController.text.trim());

      isLoading.value = false;
    }
  }
}
