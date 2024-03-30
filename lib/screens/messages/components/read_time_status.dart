import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:flutter/material.dart';

class ReadTimeStatus extends StatelessWidget {
  const ReadTimeStatus({
    super.key,
    required this.message,
    required this.isGroup,
  });

  final Message message;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    // Vars
    final bool isDoc = message.type == MessageType.doc;

    return Positioned(
      right: 0,
      bottom: isDoc ? 8 : 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // <-- Sent time -->
          Opacity(
            opacity: 0.7,
            child: Text(
              message.isDeleted
                  ? message.updatedAt?.formatMsgTime ?? ''
                  : message.sentAt?.formatMsgTime ?? '',
              style: TextStyle(
                  fontSize: 13, color: message.isSender ? Colors.white : null),
            ),
          ),
          const SizedBox(width: 2),
          // Read status
          if (message.isSender && !isGroup)
            Icon(message.isRead ? Icons.done_all : Icons.done,
                size: 15, color: Colors.white),
          // For group message
          if (isGroup)
            Icon(Icons.done_all,
                size: 15, color: message.isSender ? Colors.white : null),
        ],
      ),
    );
  }
}
