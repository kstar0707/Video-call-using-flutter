import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/group_api.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:get/get.dart';

class GroupActionsModal extends GetView<GroupController> {
  const GroupActionsModal({
    super.key,
    required this.group,
    required this.member,
    required this.isAdmin,
  });

  final Group group;
  final User member;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final String fullname = member.fullname;
    final bool isMemberAdmin = group.isAdmin(member.userId);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(defaultRadius),
          topRight: Radius.circular(defaultRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: greyColor),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(height: 0),
          // Remove member
          if (isAdmin)
            ListTile(
              onTap: () => controller.removeMember(member),
              leading: const Icon(IconlyLight.delete, color: errorColor),
              title: Text(
                group.isBroadcast
                    ? 'remove_from_broadcast'.tr
                    : 'remove_from_group'.tr,
                style: const TextStyle(color: errorColor),
              ),
            ),

          // Make group Admin / Dismiss as Admin
          if (!group.isBroadcast)
            if (isAdmin)
              ListTile(
                leading: Icon(
                    isMemberAdmin ? IconlyLight.delete : IconlyLight.user3,
                    color: errorColor),
                title: Text(
                  isMemberAdmin ? 'dismiss_as_admin'.tr : 'make_group_admin'.tr,
                  style: const TextStyle(color: errorColor),
                ),
                onTap: () => GroupApi.updateAdminRole(
                  isAdd: isMemberAdmin ? false : true,
                  group: group,
                  member: member,
                ),
              ),
          ListTile(
            leading: const Icon(IconlyLight.dangerCircle),
            title: Text("${'view'.tr} $fullname"),
            onTap: () {
              // Close this dialog
              Get.back();
              // Go to profile view page
              RoutesHelper.toProfileView(member, true);
            },
          ),
          ListTile(
            leading: const Icon(IconlyLight.chat),
            title: Text("${'message'.tr} $fullname"),
            onTap: () {
              // Go to messages page
              RoutesHelper.toMessages(user: member).then((_) {
                // Close messages page
                Get.back();
                // Close group details page
                Get.back();
                // Close this modal
                Get.back();
              });
            },
          ),
        ],
      ),
    );
  }
}
