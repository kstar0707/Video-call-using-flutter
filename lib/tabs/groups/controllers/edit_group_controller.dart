import 'package:flutter/material.dart';
import 'package:chat_messenger/api/group_api.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:get/get.dart';

class EditGroupController extends GetxController {
  final Group group;

  EditGroupController(this.group);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxBool sendMessages = RxBool(true);

  @override
  void onInit() {
    nameController.text = group.name;
    descriptionController.text = group.description;
    sendMessages.value = group.sendMessages;
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void updateGroupDetails() {
    if (!formKey.currentState!.validate()) return;
    group.name = nameController.text.trim();
    group.description = descriptionController.text.trim();
    group.sendMessages = sendMessages.value;
    Get.back();
    GroupApi.updateDetails(group);
  }
}
