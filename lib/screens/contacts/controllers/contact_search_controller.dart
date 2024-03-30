import 'package:flutter/material.dart';
import 'package:chat_messenger/api/contact_api.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';

class ContactSearchController extends GetxController {
  final RxBool isLoading = RxBool(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  Rxn<User> contact = Rxn();

  Future<void> searchContact() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    final User? result =
        await ContactApi.searchContact(usernameController.text.trim());
    // Check the result
    if (result != null) {
      contact.value = result;
    } else {
      contact.value = null;
      DialogHelper.showSnackbarMessage(
          SnackMsgType.error, "contact_not_found".tr);
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }
}
