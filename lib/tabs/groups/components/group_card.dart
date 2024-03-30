import 'package:flutter/material.dart';
import 'package:chat_messenger/components/badge_count.dart';
import 'package:chat_messenger/components/message_badge.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/sent_time.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/config/theme_config.dart';

import 'update_message.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    this.onPress,
  });

  final Group group;
  final Function()? onPress;

  @override
  Widget build(BuildContext context) {
    // Vars
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final String senderId = group.lastMsg?.senderId ?? '';
    final User senderMember = group.getMemberProfile(senderId);
    final bool isSender =
        AuthController.instance.currentUser.userId == senderId;
    final bool isDeleted = group.lastMsg != null && group.lastMsg!.isDeleted;

    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? greyLight.withOpacity(0.10) : greyLight,
            ),
          ),
        ),
        child: Row(
          children: [
            // Group photo
            _buildPhoto,
            const SizedBox(width: 10),
            // Group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 01
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Group name
                      Expanded(
                        child: Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Last msg sent time
                      SentTime(time: group.lastMsg?.sentAt),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Row 02
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sender name
                      if (!isDeleted &&
                          group.lastMsg!.type != MessageType.groupUpdate)
                        Text(
                          isSender
                              ? "${'you'.tr}: "
                              : "~ ${senderMember.fullname}: ",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      // Show last message & sender
                      Expanded(child: _buildLastMessage(context)),
                      // Show muted icon
                      Obx(() {
                        if (group.isMuted) {
                          return const Icon(
                            Icons.volume_off,
                            color: greyColor,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      // Total unread messages
                      BadgeCount(
                        counter: group.unread,
                        bgColor: const Color(0xFFfa4e1c),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _buildPhoto {
    const Widget broadcastIcon = SvgIcon('assets/icons/broadcast.svg',
        width: 32, height: 32, color: Colors.white);

    // Check broadcast empty icon
    if (group.isBroadcast && group.photoUrl.isEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[350],
        child: broadcastIcon,
      );
    }
    return CachedCircleAvatar(
      imageUrl: group.photoUrl,
      radius: 28,
      isGroup: true,
    );
  }

  Widget _buildLastMessage(BuildContext context) {
    final Message? lastMsg = group.lastMsg;

    if (lastMsg == null) {
      return Text(
          '${group.participants.length} ${group.isBroadcast ? 'recipients'.tr : 'participants'.tr}');
    } else if (lastMsg.type == MessageType.groupUpdate) {
      return UpdateMessage(group: group, message: lastMsg, isTextFormat: true);
    } else if (lastMsg.isDeleted) {
      return MessageDeleted(
        iconSize: 22,
        isSender: lastMsg.isSender,
      );
    }
    return MessageBadge(
      type: lastMsg.type,
      textMsg: lastMsg.textMsg,
      maxLines: 1,
    );
  }
}
