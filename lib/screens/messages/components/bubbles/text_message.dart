import 'package:flutter/material.dart';
import 'package:chat_messenger/components/message_badge.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/message.dart';
import '../rich_text_message.dart';

class TextMessage extends StatelessWidget {
  const TextMessage(this.message, {super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
      constraints: const BoxConstraints(
        minWidth: 45,
      ),
      child: message.isDeleted
          ? MessageDeleted(
              isSender: message.isSender,
              iconColor: message.isSender ? Colors.white : greyColor,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: message.isSender ? Colors.white : null,
              ),
            )
          : RichTexMessage(
              text: message.textMsg,
              defaultStyle: TextStyle(
                fontSize: 16,
                color: message.isSender ? Colors.white : null,
              ),
            ),
    );
  }
}
