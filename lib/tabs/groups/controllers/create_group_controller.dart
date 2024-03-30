import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat_messenger/api/group_api.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';

class CreateGroupController extends GetxController {
  RxBool isLoading = RxBool(false);
  final Rxn<File> photoFile = Rxn();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final RxSet<User> members = RxSet();

  bool isSelected(User user) {
    return members.contains(user);
  }

  void selectContact(User user) {
    if (members.contains(user)) {
      members.remove(user);
    } else {
      members.add(user);
    }
  }

  void onCheckBoxChanged(bool? value, User user) {
    if (value != null) {
      if (value) {
        members.add(user);
      } else {
        members.remove(user);
      }
    }
  }

  // <-- Create New Group -->
  Future<void> createGroup(bool isBroadcast) async {
    if (!formKey.currentState!.validate()) return;

    final result = await GroupApi.createGroup(
      photoFile: photoFile.value,
      name: nameController.text.trim(),
      members: members.toList(),
      isBroadcast: isBroadcast,
    );

    if (result) {
      // Close new group page
      Get.back(closeOverlays: true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
