import 'dart:io';

import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/message_api.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/tabs/groups/components/update_message.dart';
import 'package:get/get.dart';

import 'components/appbar_tools.dart';
import 'components/encrypted_notice.dart';
import 'components/msg_appbar_tools.dart';
import 'controllers/block_controller.dart';
import 'components/bubble_message.dart';
import 'components/chat_input_field.dart';
import 'components/group_date_separator.dart';
import 'components/scroll_down_button.dart';
import 'controllers/message_controller.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({
    super.key,
    required this.isGroup,
    this.user,
    this.groupId,
  });

  final bool isGroup;
  final User? user;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    // Init controllers
    final MessageController controller = Get.put(
      MessageController(isGroup: isGroup, user: user),
    );
    Get.put(BlockController(user?.userId));

    // Find instance
    final PreferencesController prefController = Get.find();

    // Check group
    if (isGroup) {
      prefController.getGroupWallpaperPath(
        controller.selectedGroup!.groupId,
      );
    } else {
      prefController.getChatWallpaperPath();
    }

    return Obx(
      () {
        // Get selected group instance
        Group? group = controller.selectedGroup;

        final Widget appBar = controller.selectedMessage.value != null
            ? const MsgAppBarTools()
            : AppBarTools(isGroup: isGroup, user: user, group: group);

        return Scaffold(
          appBar: appBar as PreferredSizeWidget,
          body: Obx(
            () {
              // Get wallpaper path
              final String? wallpaperPath = isGroup
                  ? prefController.groupWallpaperPath.value
                  : prefController.chatWallpaperPath.value;

              return Container(
                decoration: BoxDecoration(
                  image: wallpaperPath != null
                      ? DecorationImage(
                          image: FileImage(File(wallpaperPath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // <-- List of Messages -->
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: _buildMessagesList(wallpaperPath),
                      ),
                    ),
                    // <--- ChatInput --->
                    ChatInputField(
                      user: user,
                      group: group,
                    ),
                  ],
                ),
              );
            },
          ),
          // Show scroll list button
          floatingActionButton: _buildScrollButton,
        );
      },
    );
  }

  Widget _buildMessagesList(String? wallpaperPath) {
    // Get messages controller instance
    final MessageController controller = Get.find();
    // Get selected group instance
    Group? group = controller.selectedGroup;

    return Obx(
      () {
        // Check error
        if (controller.isLoading.value) {
          return const Center(child: LoadingIndicator(size: 35));
        } else if (controller.messages.isEmpty) {
          return NoData(
            iconData: IconlyBold.chat,
            text: 'no_messges'.tr,
            textColor: wallpaperPath != null ? Colors.white : null,
          );
        } else {
          // Get Messages List in reversed order
          final List<Message> messages = controller.messages;

          return ListView.builder(
            reverse: true,
            shrinkWrap: true,
            cacheExtent: double.maxFinite,
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              // Get Message Object
              final Message message = messages[index];

              // Check unread message to update it
              if (!isGroup) {
                if (!message.isSender && !message.isRead) {
                  MessageApi.readMsgReceipt(
                    messageId: message.msgId,
                    receiverId: user!.userId,
                  );
                }
              }

              // <--- Handle group date --->
              final DateTime? sentAt = message.sentAt;
              Widget dateSeparator = const SizedBox.shrink();

              // Check sent time
              if (sentAt != null) {
                // Check first element in reverse order
                if (index == messages.length - 1) {
                  dateSeparator = GroupDateSeparator(sentAt.formatDateTime);
                } else
                // Validate the index in range
                if (index + 1 < messages.length) {
                  // Get previous date in reverse order
                  DateTime prevDate = messages[index + 1].sentAt!;
                  // Check different dates
                  if (!(sentAt.isSameDate(prevDate))) {
                    dateSeparator = GroupDateSeparator(
                      sentAt.formatDateTime,
                    );
                  }
                }
              }

              // Get sender user
              final User senderUser =
                  isGroup ? group!.getMemberProfile(message.senderId) : user!;

              final Rxn<Message> selectedMessage = controller.selectedMessage;
              final bool isSelected = selectedMessage.value == message;
              final EdgeInsets? bubblePadding =
                  isSelected ? const EdgeInsets.fromLTRB(16, 0, 16, 16) : null;
              final Color? bubbleColor =
                  isSelected ? primaryColor.withOpacity(0.3) : null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show Group Date time
                  dateSeparator,
                  // Show encrypted notice
                  if (!isGroup && index == messages.length - 1)
                    const EncryptedNotice(),
                  // Bubble message
                  GestureDetector(
                    onLongPress: () {
                      if (message.type == MessageType.groupUpdate) {
                        return;
                      }
                      selectedMessage.value = message;
                    },
                    onTap: () => selectedMessage.value = null,
                    child: Container(
                      padding: bubblePadding,
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: isSelected ? borderRadius : null,
                      ),
                      child: isGroup && message.type == MessageType.groupUpdate
                          ? UpdateMessage(
                              group: group!,
                              message: message,
                            )
                          : BubbleMessage(
                              message: message,
                              user: user,
                              group: group,
                              onTapProfile: message.isSender
                                  ? null
                                  : () => RoutesHelper.toProfileView(
                                      senderUser, isGroup),
                              onReplyMessage: message.isDeleted
                                  ? null
                                  : () => controller.replyToMessage(message),
                            ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget? get _buildScrollButton {
    // Get messages controller instance
    final MessageController controller = Get.find();
    return Obx(() {
      // Check it.
      if (!controller.showScrollButton.value) {
        return const SizedBox.shrink();
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -10,
            bottom: 50,
            child: ScrollDownButton(
              onPress: () => controller.scrollToBottom(),
            ),
          ),
        ],
      );
    });
  }
}
