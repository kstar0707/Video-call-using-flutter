import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';

class EditProfileController extends GetxController {
  // Vars
  final RxBool isLoading = RxBool(false);
  final RxBool isExtended = RxBool(false);
  final Rxn<File> photoFile = Rxn();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void onInit() {
    _loadInitialData();
    super.onInit();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final User currentUser = AuthController.instance.currentUser;
    
    nameController.text = currentUser.fullname;
    usernameController.text = currentUser.username;
    bioController.text = currentUser.bio;
  }

  Future<void> updateAccount() async {
    // Check the form
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    // Update user account
    final result = await UserApi.updateAccount(
      photoFile: photoFile.value,
      fullname: nameController.text.trim(),
      username: usernameController.text.trim(),
      bio: bioController.text.trim(),
    );

    isLoading.value = false;

    // Check result
    if (result) {
      Get.back();
      // Show success message
      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, 'account_updated_successfully'.tr);
    } else {
      // Show error message
      DialogHelper.showSnackbarMessage(SnackMsgType.error, result.toString());
    }
  }
}
