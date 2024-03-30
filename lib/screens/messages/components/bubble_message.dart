import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/plugins/swipeto/swipe_to.dart';
import 'package:chat_messenger/screens/messages/components/bubbles/location_message.dart';
import 'package:chat_messenger/screens/messages/components/reply_message.dart';
import 'package:chat_messenger/screens/messages/controllers/message_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';

import 'bubbles/audio_message.dart';
import 'bubbles/document_message.dart';
import 'bubbles/gif_message.dart';
import 'bubbles/image_message.dart';
import 'bubbles/text_message.dart';
import 'bubbles/video_message.dart';
import 'forwarded_badge.dart';
import 'read_time_status.dart';

class BubbleMessage extends StatelessWidget {
  const BubbleMessage({
    super.key,
    required this.message,
    required this.onTapProfile,
    required this.onReplyMessage,
    required this.user,
    required this.group,
  });

  // final bool isGroup;
  final Message message;
  final User? user;
  final Group? group;
  // final String senderName;
  // final String? profileUrl;
  final Function()? onTapProfile;
  final Function()? onReplyMessage;

  @override
  Widget build(BuildContext context) {
    // Variables
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final bool isGroup = group != null;

    // Get sender user
    final User senderUser =
        isGroup ? group!.getMemberProfile(message.senderId) : user!;

    // Get sender profile url
    final String profileUrl = message.isSender
        ? AuthController.instance.currentUser.photoUrl
        : senderUser.photoUrl;

    final bool isSender = message.isSender;
    final Color backgroundColor = isSender
        ? primaryColor
        : isDarkMode
            ? greyColor.withOpacity(0.5)
            : greyLight;
    final Color senderColor = isDarkMode
        ? Colors.white
        : ColorGenerator.getColorForSender(message.senderId);

    return SwipeTo(
      iconColor: primaryColor,
      onRightSwipe: onReplyMessage,
      child: Container(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: defaultPadding,
            left: isSender ? 50 : 0,
            right: isSender ? 0 : 50,
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(!isSender ? 2 : 15),
              topRight: const Radius.circular(15),
              bottomLeft: const Radius.circular(15),
              bottomRight: Radius.circular(!isSender ? 15 : 2),
            ),
          ),
          child: Stack(
            children: [
              // <--- Show message content -->
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Forwarded badge
                  if (message.isForwarded && !message.isDeleted)
                    ForwardedBadge(isSender: isSender),
                  // Show sender name
                  if (isGroup && !isSender && !message.isDeleted)
                    GestureDetector(
                      onTap: onTapProfile,
                      child: Text(
                        isSender ? 'you'.tr : "~ ${senderUser.fullname}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: senderColor,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  // Reply message
                  if (message.replyMessage != null)
                    ReplyMessage(
                      message: message.replyMessage!,
                      senderName: isGroup
                          ? group!
                              .getMemberProfile(message.replyMessage!.senderId)
                              .fullname
                          : user!.fullname,
                      bgColor: message.isSender
                          ? isDarkMode
                              ? Colors.black
                              : greyLight
                          : null,
                      lineColor: message.isSender ? secondaryColor : null,
                    ),
                  // Main message
                  _showMessageContent(profileUrl),
                ],
              ),
              // <-- Show sent time -->
              ReadTimeStatus(message: message, isGroup: isGroup),
            ],
          ),
        ),
      ),
    );
  }

  // Handle message type
  Widget _showMessageContent(String profileUrl) {
    // Check type
    switch (message.type) {
      case MessageType.text:
        // Show text msg
        return TextMessage(message);

      case MessageType.image:
        // Show image msg
        return ImageMessage(message);

      case MessageType.gif:
        // Show GIF msg
        return GifMessage(message);

      case MessageType.audio:
        // Show audio msg
        return AudioMessage(message, profileUrl: profileUrl);

      case MessageType.video:
        // Show video msg
        return VideoMessage(message);

      case MessageType.doc:
        // Show document msg
        return DocumentMessage(
          message: message,
        );

      case MessageType.location:
        return LocationMessage(message);

      default:
        return const SizedBox.shrink();
    }
  }
}
