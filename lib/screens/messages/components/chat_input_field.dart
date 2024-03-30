import 'dart:async';
import 'dart:io';

import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/location.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/screens/messages/components/emoji_media.dart';
import 'package:chat_messenger/screens/messages/components/reply_message.dart';
import 'package:chat_messenger/screens/messages/controllers/message_controller.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';
import '../controllers/block_controller.dart';
import 'attachment/attachment_menu.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    this.user,
    this.group,
  });

  final User? user;
  final Group? group;

  @override
  ChatInputFieldState createState() => ChatInputFieldState();
}

class ChatInputFieldState extends State<ChatInputField> {
  // Get Controllers
  final MessageController controller = Get.find();
  final BlockController blockCrl = Get.find();

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    final bool isIOS = Platform.isIOS;
    final String currentUserId = AuthController.instance.currentUser.userId;

    return Obx(
      () {
        String senderName = '';
        if (widget.group != null) {
          final Message? message = controller.replyMessage.value;
          if (message != null) {
            final member = widget.group!.getMemberProfile(message.senderId);
            senderName = member.fullname;
          }
        } else {
          senderName = widget.user!.fullname;
        }

        final bool isGroup = widget.group != null;
        final TextStyle style =
            Theme.of(context).textTheme.bodyLarge!.copyWith(color: errorColor);
        final Radius replyBorderRadius = controller.isReplying
            ? const Radius.circular(16)
            : const Radius.circular(30);

        final bool isUserBlocked = blockCrl.isUserBlocked.value;
        final bool isCurrentUserBlocked = blockCrl.isCurrentUserBlocked.value;

        // Check 1-to-1 blocked status
        if (!isGroup && isUserBlocked || isCurrentUserBlocked) {
          return _blockedMessage(
              isUserBlocked: isUserBlocked,
              isCurrentUserBlocked: isCurrentUserBlocked);
        }

        // Check removed member status
        if (isGroup && widget.group!.isRemoved(currentUserId)) {
          return Container(
            padding: const EdgeInsets.all(defaultPadding / 2),
            child: Text('not_participant_message'.tr,
                textAlign: TextAlign.center, style: style),
          );
        }

        // Check Admin messages
        if (isGroup && !widget.group!.sendMessages) {
          return Container(
            padding: const EdgeInsets.all(defaultPadding / 2),
            child: Text('only_admins_can_send_messages'.tr,
                textAlign: TextAlign.center, style: style),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvoked: (bool value) {
            if (value) return;
            
            // Check emoji picker
            if (controller.showEmoji.value) {
              controller.showEmoji.value = false;
              return;
            }
            Get.back();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // <--- Chat Input --->
              Padding(
                padding: EdgeInsets.only(
                    left: 8, top: 8, right: 8, bottom: isIOS ? 25 : 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: isDarkMode ? null : greyLight,
                          borderRadius: BorderRadius.only(
                            topLeft: replyBorderRadius,
                            topRight: replyBorderRadius,
                            bottomLeft: const Radius.circular(30),
                            bottomRight: const Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //
                            // <-- Show reply message box -->
                            //
                            if (controller.replyMessage.value != null)
                              ReplyMessage(
                                cancelReply: () => controller.cancelReply(),
                                message: controller.replyMessage.value!,
                                senderName: senderName,
                              ),
                            //
                            // <-- Text input -->
                            //
                            TextFormField(
                              focusNode: controller.chatFocusNode,
                              controller: controller.textController,
                              minLines: 1,
                              maxLines: 4,
                              onTap: () => controller.showEmoji.value = false,
                              onChanged: (String text) {
                                // Update Text Msg
                                controller.isTextMsg.value =
                                    text.trim().isNotEmpty;
                              },
                              decoration: InputDecoration(
                                hintText: 'message'.tr,
                                hintMaxLines: 1,
                                filled: true,
                                fillColor: isDarkMode ? null : greyLight,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    style: BorderStyle.none,
                                    width: 0,
                                  ),
                                ),
                                // <--- Attachment button --->
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: GestureDetector(
                                    onTap: () {
                                      _showAttachmentMenu();
                                      controller.scrollToBottom();
                                      controller.chatFocusNode.unfocus();
                                      controller.showEmoji.value = false;
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                suffixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // <--- Emoji Picker --->
                                      GestureDetector(
                                        onTap: () =>
                                            controller.handleEmojiPicker(),
                                        child: SvgIcon(
                                          controller.showEmoji.value
                                              ? 'assets/icons/keyboard.svg'
                                              : 'assets/icons/emoji_very_happy.svg',
                                          color: isDarkMode
                                              ? Colors.white54
                                              : Colors.black54,
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      // <-- Send GIF -->
                                      if (!controller.isTextMsg.value)
                                        GestureDetector(
                                          onTap: () async {
                                            // Pick GIF
                                            final String? gifUrl =
                                                await MediaHelper.getGif(
                                                    context);
                                            // Check gifUrl
                                            if (gifUrl == null) return;

                                            // Send GiF
                                            await controller.sendMessage(
                                              MessageType.gif,
                                              gifUrl: gifUrl,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            child: Icon(
                                              Icons.gif_box,
                                              size: 30,
                                              color: isDarkMode
                                                  ? Colors.white54
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      // <--- Open Camera --->
                                      if (!controller.isTextMsg.value)
                                        GestureDetector(
                                          onTap: () async {
                                            // Update UI
                                            controller.scrollToBottom();
                                            controller.chatFocusNode.unfocus();
                                            controller.showEmoji.value = false;

                                            // Open Camera Picker
                                            final File? file = await MediaHelper
                                                .openCameraScreen(
                                              context,
                                            );

                                            // Check file
                                            if (file == null) return;

                                            // Send image file
                                            if (MediaHelper.isImage(
                                                file.path)) {
                                              await controller.sendMessage(
                                                  MessageType.image,
                                                  file: file);
                                              return;
                                            }

                                            // Send video file
                                            if (MediaHelper.isVideo(
                                                file.path)) {
                                              await controller.sendMessage(
                                                  MessageType.video,
                                                  file: file);
                                              return;
                                            }
                                          },
                                          child: const Icon(
                                            IconlyBold.camera,
                                            size: 30,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    ///
                    /// <--- Send message button --->
                    ///
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        // Check action
                        if (controller.isTextMsg.value) {
                          // <-- Send Text Message -->

                          // Get text input
                          final String text = controller.textController.text;
                          // Check text msg
                          if (text.trim().isEmpty) return;

                          // Send text message
                          controller.sendMessage(MessageType.text, text: text);
                        } else {
                          //
                          // <-- Send Audio Message -->
                          //
                          final File? audio =
                              await DialogHelper.showAudioRecorderModal(
                            widget.user?.userId,
                          );

                          // Send Audio Message
                          if (audio != null) {
                            controller.sendMessage(
                              MessageType.audio,
                              file: audio,
                              isRecAudio: true,
                            );
                          }
                        }
                      },
                      icon: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: SvgIcon(
                          controller.isTextMsg.value
                              ? 'assets/icons/send.svg'
                              : 'assets/icons/mic.svg',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // <--- Show Emoji Picker --->
              Offstage(
                offstage: !controller.showEmoji.value,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: EmojiMedia(
                    textController: controller.textController,
                    onSelected: (category, emoji) {
                      // Update text msg
                      controller.isTextMsg.value = true;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle Attachment Menu
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AttachmentMenu(
        sendDocs: (List<File>? files) async {
          if (files == null) return;
          // Hold futures
          List<Future> futures = [];

          // Handle docs...
          for (File file in files) {
            // Get file path
            final String path = file.path;

            // Check comomn file types
            if (MediaHelper.isImage(path)) {
              // Send image file
              futures.add(
                controller.sendMessage(MessageType.image, file: file),
              );
              //
            } else if (MediaHelper.isAudio(path)) {
              // Send audio file
              futures.add(
                controller.sendMessage(MessageType.audio, file: file),
              );
            } else if (MediaHelper.isVideo(path)) {
              // Send video file
              futures.add(
                controller.sendMessage(MessageType.video, file: file),
              );
              //
            } else {
              // Send this file as document
              futures.add(controller.sendMessage(MessageType.doc, file: file));
            }
          }

          // Send all the files once
          await Future.wait(futures);
        },
        sendImage: (File? file) {
          if (file == null) return;
          // Send image message
          controller.sendMessage(MessageType.image, file: file);
        },
        sendVideo: (File? file) {
          // Send video message
          controller.sendMessage(MessageType.video, file: file);
        },
        sendLocation: (Location? location) {
          // Send location message
          controller.sendMessage(MessageType.location, location: location);
        },
      ),
    );
  }

  Widget _blockedMessage({
    required bool isUserBlocked,
    required bool isCurrentUserBlocked,
  }) {
    String message = '';

    if (isUserBlocked) {
      message = 'you_have_blocked_use_tap_the_top_corner_options_to_unblock';
    } else if (isCurrentUserBlocked) {
      message = 'user_has_blocked_you_it_s_not_possible_to_send_messages';
    }

    return Container(
      padding: const EdgeInsets.all(defaultPadding / 2),
      child: Text(
        message.trParams({'firstName': widget.user?.fullname ?? ''}),
        textAlign: TextAlign.center,
        style:
            Theme.of(context).textTheme.bodyLarge!.copyWith(color: errorColor),
      ),
    );
  }
}
