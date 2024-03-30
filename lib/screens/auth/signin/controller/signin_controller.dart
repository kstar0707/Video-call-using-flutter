import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/auth_api.dart';

class SignInController extends GetxController {
  // Controllers
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onInit() {
    debugPrint('SignInController() -> onInit');
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  Future<void> signInWithEmailAndPassword() async {
    // Process valid data
    if (emailFormKey.currentState!.validate()) {
      // Update loading
      isLoading.value = true;

      await AuthApi.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      isLoading.value = false;
    }
  }
}
