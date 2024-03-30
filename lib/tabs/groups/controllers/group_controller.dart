import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/group_api.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  // Get the current instance
  static GroupController instance = Get.find();

  // Others
  final RxBool isLoading = RxBool(true);
  final RxList<Group> groups = RxList();
  final RxnString groupId = RxnString();
  final Rxn<Group> selectedGroup = Rxn();
  StreamSubscription<List<Group>>? _stream;

  @override
  void onInit() {
    _getUserGroups();
    super.onInit();
  }

  @override
  void onClose() {
    _stream?.cancel();
    super.onClose();
  }

  bool get newMessage => groups.where((g) => g.unread > 0).isNotEmpty;
  Group get group => selectedGroup.value!;

  Group? getSelectedGroup() {
    final Group? group =
        groups.firstWhereOrNull((group) => group.groupId == groupId.value);
    if (group != null) {
      selectedGroup.value = group;
    }
    return group;
  }

  void clearSelectedGroup() {
    groupId.value = null;
    selectedGroup.value = null;
  }

  // Get current user groups
  void _getUserGroups() {
    _stream = GroupApi.getUserGroups(
      AuthController.instance.currentUser.userId,
    ).listen((event) {
      groups.value = event;
      getSelectedGroup();
      isLoading.value = false;
    }, onError: (e) => debugPrint(e.toString()));
  }

  Future<void> addMembers() async {
    final List? contacts = await RoutesHelper.toSelectContacts(
      title: group.isBroadcast ? 'add_recipients'.tr : 'add_participants'.tr,
      isBroadcast: group.isBroadcast,
    );
    if (contacts == null) return;
    final List<User> members = contacts.whereType<User>().toList();
    GroupApi.addMembers(
      group: group,
      newMembers: members,
      isBroadcast: group.isBroadcast,
    );
  }

  Future<void> exitGroup() async {
    DialogHelper.showAlertDialog(
      barrierDismissible: false,
      titleColor: errorColor,
      title: Text('exit_group'.tr),
      icon: const Icon(IconlyLight.logout, color: errorColor),
      content: Text('exit_group_message'.tr),
      actionText: 'exit'.tr.toUpperCase(),
      action: () {
        Get.back();
        GroupApi.removeMember(
          group: group,
          memberId: AuthController.instance.currentUser.userId,
        );
      },
    );
  }

  Future<void> deleteGroup() async {
    DialogHelper.showAlertDialog(
      barrierDismissible: false,
      titleColor: errorColor,
      title:
          Text(group.isBroadcast ? 'delete_broadcast'.tr : 'delete_group'.tr),
      icon: const Icon(IconlyLight.logout, color: errorColor),
      content: Text('are_you_sure'.tr),
      actionText: 'DELETE'.tr,
      action: () async {
        Get.back();
        final bool result = await GroupApi.deleteGroup(group);
        if (result) {
          Get.back();
          Get.back();
          DialogHelper.showSnackbarMessage(
            SnackMsgType.success,
            group.isBroadcast
                ? 'broadcast_deleted_successfully'.tr
                : 'group_deleted_successfully'.tr,
          );
        }
      },
    );
  }

  Future<void> removeMember(User member) async {
    // Close bottom modal
    Get.back();
    // Show confirm dialog
    DialogHelper.showAlertDialog(
      barrierDismissible: false,
      titleColor: errorColor,
      title: Text(group.isBroadcast
          ? 'remove_from_broadcast'.tr
          : 'remove_from_group'.tr),
      icon: const Icon(IconlyLight.delete, color: errorColor),
      content: Text('${'remove'.tr} ${member.fullname}?'),
      actionText: 'remove'.tr.toUpperCase(),
      action: () {
        // Close dialog
        Get.back();
        // Send request
        GroupApi.removeMember(
          group: group,
          byAdmin: true,
          memberId: member.userId,
        );
      },
    );
  }
}
