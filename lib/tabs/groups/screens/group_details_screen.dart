import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/group_api.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:get/get.dart';

class GroupDetailsScreen extends GetView<GroupController> {
  const GroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController reportController = Get.find();

    return Obx(() {
      final Group group = controller.selectedGroup.value!;
      final User currentUser = AuthController.instance.currentUser;
      final User admin = group.getMemberProfile(group.createdBy);
      final bool isAdmin = group.isAdmin(currentUser.userId);
      final bool isOwner = currentUser.userId == admin.userId;
      final bool isBroadcast = group.isBroadcast;

      return Scaffold(
        appBar: CustomAppBar(
          height: 56,
          title: Text(
            group.name,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            const SizedBox(width: 16),
            // Report group
            if (!isBroadcast)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: () => reportController.reportDialog(
                    type: ReportType.group,
                    groupId: group.groupId,
                  ),
                  icon:
                      const Icon(IconlyLight.dangerCircle, color: Colors.white),
                ),
              ),

            // Exit group
            if (!isBroadcast)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: () => controller.exitGroup(),
                  icon: const Icon(IconlyLight.logout, color: Colors.white),
                ),
              ),

            // <-- Delete group -->
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: IconButton(
                  onPressed: () => controller.deleteGroup(),
                  icon: const Icon(IconlyLight.delete, color: Colors.white),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Obx(() {
              final bool isMuted = AuthController
                  .instance.currentUser.mutedGroups
                  .contains(group.groupId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding / 2,
                      vertical: defaultPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: isAdmin
                                ? () => GroupApi.updatePhoto(group)
                                : null,
                            child: Stack(
                              children: [
                                // Group photo
                                CachedCircleAvatar(
                                  radius: 70,
                                  isGroup: true,
                                  isBroadcast: isBroadcast,
                                  iconSize: 60,
                                  imageUrl: group.photoUrl,
                                ),
                                if (isAdmin)
                                  const Positioned(
                                    right: 0,
                                    bottom: 16,
                                    child: CircleAvatar(
                                      backgroundColor: primaryColor,
                                      child: Icon(IconlyBold.camera,
                                          color: Colors.white, size: 23),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Group name
                        Center(
                          child: GestureDetector(
                            onTap: isAdmin
                                ? () => RoutesHelper.toEditGroup(group)
                                : null,
                            child: Wrap(
                              children: [
                                Text(
                                  group.name,
                                  style:
                                      Theme.of(context).textTheme.titleLarge!,
                                ),
                                if (isAdmin)
                                  const Icon(IconlyLight.edit,
                                      color: greyColor),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            isBroadcast
                                ? "${'broadcast'.tr} | ${group.recipients.length} ${'recipients'.tr}"
                                : "${'group'.tr} | ${group.participants.length} ${'participants'.tr}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: greyColor),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            "${'created_by'.tr} ${isOwner ? 'you'.tr.toLowerCase() : admin.fullname} ,"
                            "${group.createdAt!.formatDateTime}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: greyColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        // Group description
                        GestureDetector(
                          onTap: isAdmin
                              ? () => RoutesHelper.toEditGroup(group)
                              : null,
                          child: Card(
                            child: Container(
                              width: double.maxFinite,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBroadcast
                                        ? "broadcast_description".tr
                                        : "group_description".tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: greyColor),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          group.description.isEmpty
                                              ? isAdmin
                                                  ? 'add_description'.tr
                                                  : 'no_description'.tr
                                              : group.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  color: group.description
                                                              .isEmpty &&
                                                          isAdmin
                                                      ? primaryColor
                                                      : null),
                                        ),
                                      ),
                                      if (isAdmin)
                                        const Icon(IconlyLight.edit,
                                            color: greyColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // <-- Group options container -->
                        if (!isBroadcast)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                horizontalTitleGap: 8,
                                leading: const Icon(IconlyLight.notification),
                                title: Text('mute_notifications'.tr),
                                trailing: CupertinoSwitch(
                                  onChanged: (_) {
                                    UserApi.muteGroup(group.groupId, isMuted);
                                  },
                                  value: isMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                horizontalTitleGap: 8,
                                onTap: isAdmin
                                    ? () => RoutesHelper.toEditGroup(group)
                                    : null,
                                leading: const Icon(IconlyLight.setting),
                                title: Text('group_permissions'.tr),
                                subtitle: Text(
                                  group.sendMessages
                                      ? 'both_admins_and_participants_can_send_messages'
                                          .tr
                                      : 'only_admins_can_send_messages'.tr,
                                ),
                                trailing: isAdmin
                                    ? const Icon(IconlyLight.edit,
                                        color: greyColor)
                                    : null,
                              ),
                              const Divider(),
                            ],
                          ),
                        if (isBroadcast) const SizedBox(height: 20),
                        //
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                          ),
                          child: Text(
                            isBroadcast
                                ? "${group.recipients.length} ${'recipients'.tr}"
                                : "${group.participants.length} ${'participants'.tr}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: greyColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Check Admin
                  if (isAdmin)
                    ListTile(
                      onTap: () => controller.addMembers(),
                      leading: const CircleAvatar(
                        backgroundColor: primaryColor,
                        child: Icon(Icons.group_add,
                            color: Colors.white, size: 22),
                      ),
                      title: Text(isBroadcast
                          ? 'add_recipients'.tr
                          : 'add_participants'.tr),
                      trailing:
                          const Icon(IconlyLight.arrowRight2, color: greyColor),
                    ),
                  if (isAdmin) const Divider(),

                  // <-- Participants list -->
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: isBroadcast
                        ? group.recipients.length
                        : group.participants.length,
                    itemBuilder: (_, index) {
                      final User member = isBroadcast
                          ? group.recipients[index]
                          : group.participants[index];

                      return ListTile(
                        onTap: isAdmin
                            ? () {
                                // Check current user
                                if (member.userId == currentUser.userId) {
                                  return;
                                }
                                DialogHelper.showGroupOptionsModal(
                                  group: group,
                                  member: member,
                                  isAdmin: isAdmin,
                                );
                              }
                            : null,
                        leading: CachedCircleAvatar(
                          radius: 20,
                          imageUrl: member.photoUrl,
                        ),
                        title: Text(member.userId == currentUser.userId
                            ? 'you'.tr
                            : member.fullname),
                        subtitle: Text('@${member.username}'),
                        trailing: Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Check member admin status
                              if (group.isAdmin(member.userId))
                                const AdminBadge(),
                              // Check current user admin status
                              if (isAdmin &&
                                  member.userId != currentUser.userId)
                                const Icon(Icons.more_vert, color: greyColor),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}

class AdminBadge extends StatelessWidget {
  const AdminBadge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'admin'.tr,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
