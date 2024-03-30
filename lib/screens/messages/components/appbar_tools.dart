import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/app_controller.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/screens/calling/helper/call_helper.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../controllers/block_controller.dart';
import '../controllers/message_controller.dart';
import 'popup_menu_title.dart';

class AppBarTools extends StatelessWidget implements PreferredSizeWidget {
  const AppBarTools({
    super.key,
    required this.isGroup,
    this.user,
    required this.group,
  });

  final bool isGroup;
  final Group? group;
  final User? user;

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final MessageController messageController = Get.find();
    final GroupController groupController = Get.find();
    final PreferencesController prefController = Get.find();
    final ReportController reportController = Get.find();

    const devider = PopupMenuItem<String>(
      height: 0,
      padding: EdgeInsets.zero,
      child: Divider(height: 3),
    );

    // <-- Build Group AppBar -->
    if (isGroup) {
      // Vars
      final bool isBroadcast = group!.isBroadcast;

      return AppBar(
        leadingWidth: 35,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        ),
        // Group info
        title: GestureDetector(
          onTap: () => RoutesHelper.toGroupDetails(group!.groupId),
          child: Row(
            children: [
              // Group photo
              CachedCircleAvatar(
                isGroup: true,
                isBroadcast: isBroadcast,
                backgroundColor: secondaryColor,
                imageUrl: group!.photoUrl,
                borderWidth: 0,
                padding: 0,
                radius: 20,
              ),
              const SizedBox(width: defaultPadding * 0.75),
              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group name
                    Text(
                      group!.name,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Tap to for info
                    Text(
                      '${isBroadcast ? group!.recipients.length : group!.participants.length} ${isBroadcast ? 'recipients'.tr.toLowerCase() : 'participants'.tr.toLowerCase()}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: isBroadcast
            ? null
            : [
                Obx(() {
                  final User currentUser = AuthController.instance.currentUser;

                  // Get group wallpaper path
                  final String? groupWallpaperPath =
                      prefController.groupWallpaperPath.value;

                  return PopupMenuButton<String>(
                    initialValue: '',
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () =>
                            RoutesHelper.toGroupDetails(group!.groupId),
                        child: PopupMenuTitle(
                          icon: IconlyLight.dangerCircle,
                          title: 'group_info'.tr,
                        ),
                      ),
                      devider,
                      PopupMenuItem(
                        onTap: () =>
                            UserApi.muteGroup(group!.groupId, group!.isMuted),
                        child: PopupMenuTitle(
                          icon: group!.isMuted
                              ? Icons.volume_off
                              : IconlyLight.notification,
                          title: group!.isMuted
                              ? 'unmute_notifications'.tr
                              : 'mute_notifications'.tr,
                        ),
                      ),
                      devider,
                      PopupMenuItem(
                        onTap: () {
                          if (groupWallpaperPath == null) {
                            prefController.setGroupWallpaper(group!.groupId);
                          } else {
                            prefController.removeGroupWallpaper(group!.groupId);
                          }
                        },
                        child: PopupMenuTitle(
                          icon: IconlyLight.image2,
                          title: groupWallpaperPath == null
                              ? 'set_wallpaper'.tr
                              : 'remove_wallpaper'.tr,
                        ),
                      ),
                      devider,
                      PopupMenuItem(
                        onTap: () => reportController.reportDialog(
                          type: ReportType.group,
                          groupId: group!.groupId,
                        ),
                        child: PopupMenuTitle(
                          icon: IconlyLight.dangerTriangle,
                          title: 'report_group'.tr,
                        ),
                      ),
                      devider,
                      if (!group!.isRemoved(currentUser.userId))
                        PopupMenuItem(
                          onTap: () => groupController.exitGroup(),
                          child: PopupMenuTitle(
                            icon: IconlyLight.logout,
                            title: 'exit_group'.tr,
                          ),
                        ),
                    ],
                  );
                }),
              ],
      );
    }

    //
    // <-- Build 1-to-1 Chat AppBar Session -->
    //

    // Get block user controller
    final BlockController blockController = Get.find();
    final User currentUser = AuthController.instance.currentUser;

    return AppBar(
      leadingWidth: 35,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
      ),
      title: GestureDetector(
        onTap: () => RoutesHelper.toProfileView(user!, false),
        child: Row(
          children: [
            // <--- Profile photo --->
            CachedCircleAvatar(
              backgroundColor:
                  user!.photoUrl.isEmpty ? secondaryColor : primaryColor,
              imageUrl: user!.photoUrl,
              borderWidth: 0,
              padding: 0,
              radius: 20,
            ),
            const SizedBox(width: defaultPadding * 0.75),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// <--- Profile name --->
                  Text(
                    user!.fullname,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  /// <--- Status -> Online/Last seen time/Typing --->
                  StreamBuilder<User>(
                    stream: UserApi.getUserUpdates(user!.userId),
                    builder: (context, snapshot) {
                      // Get updated user
                      final User receiver = snapshot.data ?? user!;

                      // Update controller
                      messageController.isReceiverOnline = receiver.isOnline;

                      // Get typing status
                      final isTypingToMe = receiver.isTyping &&
                          receiver.typingTo == currentUser.userId;
                      // Get recording status
                      final isRecordingToMe = receiver.isRecording &&
                          receiver.recordingTo == currentUser.userId;

                      // Chek typing status
                      if (isTypingToMe) {
                        return Text(
                          'typing'.tr,
                          style: const TextStyle(fontSize: 12),
                        );
                      } else if (isRecordingToMe) {
                        return Text(
                          'recording_audio'.tr,
                          style: const TextStyle(fontSize: 12),
                        );
                      } else if (receiver.isOnline) {
                        return const Text(
                          "Online",
                          style: TextStyle(fontSize: 12),
                        );
                      }
                      final DateTime? lastActive = receiver.lastActive;
                      if (lastActive == null) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        height: 20,
                        child: Marquee(
                          blankSpace: 20.0,
                          velocity: 30.0,
                          style: const TextStyle(fontSize: 14),
                          text: lastActive.getLastSeenTime,
                        ),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        // <-- Voice call button -->
        Obx(() {
          // Check permission
          if (!AppController.instance.appInfo.allowVoiceCall) {
            return const SizedBox.shrink();
          }

          return IconButton(
            onPressed: () => CallHelper.makeCall(isVideo: false, user: user!),
            icon: const Icon(IconlyLight.call, color: Colors.white),
          );
        }),

        // <-- Video call button -->
        Obx(() {
          // Check permission
          if (!AppController.instance.appInfo.allowVideoCall) {
            return const SizedBox.shrink();
          }
          return IconButton(
            onPressed: () => CallHelper.makeCall(isVideo: true, user: user!),
            icon: const Icon(IconlyLight.video, size: 32, color: Colors.white),
          );
        }),

        // <-- Show popup options -->
        Obx(() {
          // Vars
          final bool isUserBlocked = blockController.isUserBlocked.value;
          final String blockTitle = isUserBlocked ? 'unblock'.tr : 'block'.tr;

          final String? chatWallpaperPath =
              prefController.chatWallpaperPath.value;
          final bool isChatMuted = messageController.isChatMuted.value;

          return PopupMenuButton<String>(
            initialValue: '',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => messageController.muteChat(),
                value: 'mute_notifications',
                child: PopupMenuTitle(
                  icon:
                      isChatMuted ? Icons.volume_off : IconlyLight.notification,
                  title: isChatMuted
                      ? 'unmute_notifications'.tr
                      : 'mute_notifications'.tr,
                ),
              ),
              devider,
              PopupMenuItem(
                onTap: () {
                  if (chatWallpaperPath == null) {
                    prefController.setChatWallpaper();
                  } else {
                    prefController.removeChatWallpaper();
                  }
                },
                value: 'change_wallpaper',
                child: PopupMenuTitle(
                  icon: IconlyLight.image2,
                  title: chatWallpaperPath == null
                      ? 'set_wallpaper'.tr
                      : 'remove_wallpaper'.tr,
                ),
              ),
              devider,
              PopupMenuItem(
                value: 'clear_chat',
                child: PopupMenuTitle(
                  icon: IconlyLight.delete,
                  title: 'clear_chat'.tr,
                ),
              ),
              devider,
              PopupMenuItem(
                value: 'block_user',
                child: PopupMenuTitle(
                  icon: IconlyLight.closeSquare,
                  title: blockTitle,
                ),
              ),
              devider,
              PopupMenuItem(
                onTap: () => reportController.reportDialog(
                  type: ReportType.user,
                  userId: user!.userId,
                ),
                child: PopupMenuTitle(
                  icon: IconlyLight.infoSquare,
                  title: 'report'.tr,
                ),
              ),
            ],
            onSelected: (String option) {
              switch (option) {
                case 'clear_chat':
                  // Confirm delete chat
                  DialogHelper.showAlertDialog(
                    title: Text('${'clear_chat'.tr}?'),
                    icon: const Icon(IconlyLight.chat, color: primaryColor),
                    content: Text('this_action_cannot_be_reversed'.tr),
                    actionText: 'clear'.tr.toUpperCase(),
                    action: () => messageController.clearChat(),
                  );
                  break;

                case 'block_user':
                  // Confirm block user
                  DialogHelper.showAlertDialog(
                    title: Text(blockTitle),
                    icon: Icon(
                        isUserBlocked ? IconlyLight.unlock : IconlyLight.lock,
                        color: primaryColor),
                    content: Text(
                      'are_you_sure_you_want_to_block'.trParams(
                        {'blockTitle': blockTitle, 'firstName': user!.fullname},
                      ),
                    ),
                    actionText: 'YES'.tr,
                    action: () {
                      // Close this dialog
                      Get.back();

                      // Check status
                      if (isUserBlocked) {
                        blockController.unblockUser();
                      } else {
                        blockController.blockUser();
                      }
                    },
                  );
                  break;
              }
            },
          );
        }),

        //const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
