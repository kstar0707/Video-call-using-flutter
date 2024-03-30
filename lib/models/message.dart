import 'package:chat_messenger/helpers/encrypt_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';

import 'group_update.dart';
import 'location.dart';

// Message types
enum MessageType { text, image, gif, audio, video, doc, location, groupUpdate }

class Message {
  String msgId;
  String senderId;
  MessageType type;
  String textMsg;
  String fileUrl;
  String gifUrl;
  Location? location;
  String videoThumbnail;
  bool isRead;
  bool isRecAudio;
  bool isDeleted;
  bool isForwarded;
  DateTime? sentAt;
  DateTime? updatedAt;
  Message? replyMessage;
  // For Groups
  GroupUpdate? groupUpdate;
  // This reference help us update this message
  DocumentReference<Map<String, dynamic>>? docRef;

  Message({
    required this.msgId,
    this.docRef,
    this.senderId = '',
    this.type = MessageType.text,
    this.textMsg = '',
    this.fileUrl = '',
    this.gifUrl = '',
    this.location,
    this.videoThumbnail = '',
    this.isRead = false,
    this.isRecAudio = false,
    this.isDeleted = false,
    this.isForwarded = false,
    this.sentAt,
    this.updatedAt,
    this.replyMessage,
    this.groupUpdate,
  });

  bool get isSender => senderId == AuthController.instance.currentUser.userId;

  @override
  String toString() {
    return 'Message(msgId: $msgId, senderId: $senderId, type: $type, textMsg: $textMsg, fileUrl: $fileUrl, gifUrl: $gifUrl, videoThumbnail: $videoThumbnail, isRead: $isRead, isRecAudio: $isRecAudio, sentAt: $sentAt, groupUpdate: $groupUpdate)';
  }

  // Get message type
  static MessageType getMsgType(String type) {
    return MessageType.values.firstWhere((el) => el.name == type);
  }

  factory Message.fromMap({
    required bool isGroup,
    required Map<String, dynamic> data,
    DocumentReference<Map<String, dynamic>>? docRef,
  }) {
    final String messageId = data['msgId'] ?? '';
    final String textMessage = data['textMsg'] ?? '';

    return Message(
      docRef: docRef,
      msgId: messageId,
      senderId: data['senderId'] ?? '',
      type: getMsgType(data['type']),
      textMsg:
          isGroup ? textMessage : EncryptHelper.decrypt(textMessage, messageId),
      fileUrl: data['fileUrl'] ?? '',
      gifUrl: data['gifUrl'] ?? '',
      location: Location.fromMap(data['location'] ?? {}),
      videoThumbnail: data['videoThumbnail'] ?? '',
      isRead: data['isRead'] ?? false,
      isRecAudio: data['isRecAudio'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      isForwarded: data['isForwarded'] ?? false,
      sentAt: data['sentAt']?.toDate() as DateTime?,
      updatedAt: data['updatedAt']?.toDate() as DateTime?,
      replyMessage: data['replyMessage'] != null
          ? Message.fromMap(data: data['replyMessage'], isGroup: isGroup)
          : null,
      groupUpdate: GroupUpdate.froMap(data['groupUpdate'] ?? {}),
    );
  }

  Map<String, dynamic> toMap({required bool isGroup}) {
    return {
      'msgId': msgId,
      'senderId': senderId,
      'type': type.name,
      'textMsg': isGroup ? textMsg : EncryptHelper.encrypt(textMsg, msgId),
      'fileUrl': fileUrl,
      'gifUrl': gifUrl,
      'location': location?.toMap(),
      'videoThumbnail': videoThumbnail,
      'isRead': isRead,
      'isRecAudio': isRecAudio,
      'isForwarded': isForwarded,
      'sentAt': FieldValue.serverTimestamp(),
      'replyMessage': replyMessage?.toMap(isGroup: isGroup),
      'groupUpdate': groupUpdate?.toMap(),
    };
  }

  Map<String, dynamic> toDeletedMap() {
    return {
      'isDeleted': true,
      'msgId': msgId,
      'type': 'text',
      'textMsg': 'deleted',
      'senderId': senderId,
      'replyMessage': null,
      'sentAt': sentAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
