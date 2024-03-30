import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/screens/messages/components/rich_text_message.dart';
import 'package:get/get.dart';

class MessageBadge extends StatelessWidget {
  const MessageBadge({
    super.key,
    required this.type,
    required this.textMsg,
    this.maxLines,
    this.textStyle,
  });

  final MessageType type;
  final String textMsg;
  final TextStyle? textStyle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      MessageType.text => rowInfo(title: textMsg),
      MessageType.image => rowInfo(icon: IconlyBold.image, title: 'photo'.tr),
      MessageType.gif => rowInfo(icon: Icons.gif_box, title: 'GIF'),
      MessageType.audio => rowInfo(icon: Icons.headphones, title: 'audio'.tr),
      MessageType.video => rowInfo(icon: IconlyBold.video, title: 'video'.tr),
      MessageType.doc =>
        rowInfo(icon: IconlyBold.document, title: 'document'.tr),
      MessageType.location =>
        rowInfo(icon: IconlyBold.location, title: 'location'.tr),
      _ => const SizedBox.shrink(),
    };
  }

  Widget rowInfo({
    IconData? icon,
    required String title,
  }) {
    return Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(icon, size: 20, color: greyColor),
          ),
        Expanded(
          child: RichTexMessage(
            text: title,
            maxLines: maxLines,
            defaultStyle: textStyle ??
                const TextStyle(
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ),
      ],
    );
  }
}

class MessageDeleted extends StatelessWidget {
  const MessageDeleted({
    super.key,
    required this.isSender,
    this.iconColor = greyColor,
    this.iconSize,
    this.style,
  });

  final bool isSender;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final String deletedMsg = isSender
        ? 'you_deleted_this_message'.tr
        : 'this_message_was_deleted'.tr;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block, size: iconSize, color: iconColor),
        const SizedBox(width: 3),
        Text(deletedMsg, style: style),
      ],
    );
  }
}
