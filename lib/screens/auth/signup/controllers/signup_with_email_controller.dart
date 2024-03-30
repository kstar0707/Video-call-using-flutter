import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/auth_api.dart';

class SignUpWithEmailController extends GetxController {
  // Variables
  final RxBool isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  String? confirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'enter_confirm_password'.tr;
    } else if (passwordController.text != value) {
      return 'passwords_dont_match'.tr;
    }
    return null;
  }

  Future<void> signUpWithEmailAndPassword() async {
    // Check the form
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    await AuthApi.signUpWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    isLoading.value = false;
  }
}
