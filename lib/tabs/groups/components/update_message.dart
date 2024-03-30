import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/group_update.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';

class UpdateMessage extends StatelessWidget {
  const UpdateMessage({
    super.key,
    required this.group,
    required this.message,
    this.isTextFormat = false,
  });

  final Group group;
  final Message message;
  final bool isTextFormat;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    final GroupUpdate? groupUpdate = message.groupUpdate;
    final bool isBroadcast = group.isBroadcast;
    final String groupTitle =
        isBroadcast ? 'created_broadcast'.tr : 'created_group'.tr;

    if (groupUpdate == null) {
      return Text(message.textMsg,
          style: Theme.of(context).textTheme.bodyLarge);
    }
    final String currentUserId = AuthController.instance.currentUser.userId;
    final User senderAdmin = group.getMemberProfile(message.senderId);
    final bool isSenderAdmin = senderAdmin.userId == currentUserId;
    final String you = 'you'.tr;
    final UpdateType type = GroupUpdate.getType(message.textMsg);
    String textMessage = '';

    switch (type) {
      case UpdateType.created:
        textMessage = isSenderAdmin
            ? '$you $groupTitle "${group.name}"'
            : '${senderAdmin.fullname} $groupTitle "${group.name}"';
        break;

      case UpdateType.added:

        // Check added as Admin
        if (message.groupUpdate!.asAdmin) {
          textMessage = _asAdminMessage(added: true);
          // Don't continue
          break;
        }

        // Check added as participants
        if (groupUpdate.members > 1) {
          textMessage = isSenderAdmin
              ? "$you ${'added'.tr} ${groupUpdate.members} ${isBroadcast ? 'recipients'.tr : 'members'.tr}"
              : '${senderAdmin.fullname} ${'added'.tr} ${you.toLowerCase()} and other ${groupUpdate.members} ${'members'.tr}';
        } else {
          String memberName =
              group.getMemberProfile(groupUpdate.memberId).fullname;
          textMessage = isSenderAdmin
              ? "$you ${'added'.tr} $memberName"
              : '${senderAdmin.fullname} ${'added'.tr} ${you.toLowerCase()}';
        }

        break;
      case UpdateType.removed:
        // Check removed as Admin
        if (message.groupUpdate!.asAdmin) {
          textMessage = _asAdminMessage(added: false);
          // Don't continue
          break;
        }

        String memberName =
            group.getMemberProfile(groupUpdate.memberId).fullname;
        textMessage = isSenderAdmin
            ? "$you ${'removed'.tr} $memberName"
            : '${senderAdmin.fullname} ${'removed'.tr} $you';

        break;

      case UpdateType.left:
        String memberName =
            group.getMemberProfile(groupUpdate.memberId).fullname;
        textMessage = isSenderAdmin
            ? "$you ${'left_group'.tr}"
            : '$memberName ${'left_group'.tr}';
        break;

      case UpdateType.details:
        final String details = isBroadcast
            ? 'updated_broadcast_details'.tr
            : 'updated_group_details'.tr;
        final String adminName =
            group.getMemberProfile(group.updatedBy).fullname;
        textMessage =
            isSenderAdmin ? "${'you_have'.tr} $details" : '$adminName $details';
        break;
      default:
    }

    if (isTextFormat) {
      return Text(
        textMessage,
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }

    return FittedBox(
      child: Container(
        padding: const EdgeInsets.all(defaultPadding / 2),
        margin: const EdgeInsets.symmetric(
          horizontal: defaultMargin,
          vertical: defaultMargin / 2,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? greyColor.withOpacity(0.5) : greyLight,
          borderRadius: BorderRadius.circular(defaultRadius / 2),
        ),
        alignment: Alignment.center,
        child: Text(
          textMessage,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _asAdminMessage({required bool added}) {
    final GroupUpdate groupUpdate = message.groupUpdate!;
    final String currentUserId = AuthController.instance.currentUser.userId;
    final String action = added ? 'added'.tr : 'removed'.tr;

    final User senderAdmin = group.getMemberProfile(message.senderId);
    final bool isCurrentAdmin = senderAdmin.userId == currentUserId;
    final User member = group.getMemberProfile(groupUpdate.memberId);
    final bool isCurrentMember = member.userId == currentUserId;

    // Message for Admins
    if (group.isAdmin(currentUserId)) {
      return isCurrentAdmin
          ? "${'you'.tr} $action ${member.fullname} ${'as_admin'.tr}"
          : '${senderAdmin.fullname} $action ${isCurrentMember ? 'you'.tr.toLowerCase() : member.fullname} ${'as_admin'.tr}';
    } else {
      // Message for participants
      return '${senderAdmin.fullname} ${'updated_group_details'.tr}';
    }
  }
}
