import 'package:chat_messenger/models/message.dart';

extension MsgType on String {
  MessageType toEnum() {
    switch (this) {
      case 'text':
        return MessageType.text;

      case 'image':
        return MessageType.image;

      case 'gif':
        return MessageType.gif;

      case 'audio':
        return MessageType.audio;

      case 'video':
        return MessageType.video;

      case 'document':
        return MessageType.doc;

      case 'location':
        return MessageType.location;

      default:
        return MessageType.text;
    }
  }
}
