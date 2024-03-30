import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/chat.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';

abstract class ChatApi {
  //
  // ChatApi - CRUD Operations
  //

  // Firestore instance
  static final _firestore = FirebaseFirestore.instance;

  // Save chat for both users
  static Future<void> saveChat({
    required String userId1,
    required String userId2,
    required Message message,
  }) async {
    try {
      // Get chat instance
      final Chat chat = Chat(
        senderId: userId1,
        msgType: message.type,
        lastMsg: message.textMsg,
        msgId: message.msgId,
      );

      await Future.wait([
        // Save chat in current user collection
        _firestore
            .collection('Users/$userId1/Chats')
            .doc(userId2)
            .set(chat.toMap(false), SetOptions(merge: true)),

        // Save inverse chat copy for another user
        _firestore
            .collection('Users/$userId2/Chats')
            .doc(userId1)
            .set(chat.toMap(true), SetOptions(merge: true)),
      ]);

      // Debug
      debugPrint('saveChat() -> success');
    } catch (e) {
      debugPrint('saveChat() -> error: $e');
    }
  }

  static Stream<List<Chat>> getChats() {
    // Get current user model
    final User currentUer = AuthController.instance.currentUser;

    // Build query
    return _firestore
        .collection('Users/${currentUer.userId}/Chats')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .asyncMap((event) async {
      // Hold the list
      List<Chat> chats = [];

      for (var doc in event.docs) {
        // Get map data
        final data = doc.data();
        // Fetch user data
        final User? user = await UserApi.getUser(doc.id);
        // Add chat to the list
        if (user != null) {
          chats.add(Chat.fromMap(data, doc: doc, receiver: user));
        }
      }
      return chats;
    });
  }

  // Update Chat Node
  static Future<void> updateChatNode({
    required String userId1,
    required String userId2,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId1)
          .collection('Chats')
          .doc(userId2)
          .set(data, SetOptions(merge: true));
      debugPrint('updateChatNode() -> success');
    } catch (e) {
      debugPrint('updateChatNode() -> error: $e');
    }
  }

  // Update Chat typing status
  static Future<void> updateChatTypingStatus(
    bool isTyping,
    String receiverId,
  ) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await updateChatNode(
        userId1: receiverId,
        userId2: currentUer.userId,
        data: {'isTyping': isTyping, 'isRecording': false},
      );
      debugPrint('updateChatTypingStatus() -> success');
    } catch (e) {
      debugPrint('updateChatTypingStatus() -> error: $e');
    }
  }

  // Update Chat recording status
  static Future<void> updateChatRecordingStatus(
    bool isRecording,
    String receiverId,
  ) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await updateChatNode(
        userId1: receiverId,
        userId2: currentUer.userId,
        data: {'isRecording': isRecording, 'isTyping': false},
      );
      debugPrint('updateChatRecordingStatus() -> success');
    } catch (e) {
      debugPrint('updateChatRecordingStatus() -> error: $e');
    }
  }

  // Update the Chat Node
  static Future<void> leaveChat(
    String receiverId,
  ) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await Future.wait([
        UserApi.closeTypingOrRecordingStatus(),
        updateChatNode(
          userId1: receiverId,
          userId2: currentUer.userId,
          data: {'isTyping': false, 'isRecording': false, 'unread': 0},
        ),
      ]);
      debugPrint('updateTypingAndRecordingStatus() -> success');
    } catch (e) {
      debugPrint('updateTypingAndRecordingStatus() -> error: $e');
    }
  }

  // Soft delete chat.
  static Future<void> softDeleteChat({
    required String userId1,
    required String userId2,
    required String msgId,
  }) async {
    final User currentUer = AuthController.instance.currentUser;

    // Get Chat instance
    final Chat chat = Chat(
      senderId: currentUer.userId,
      msgType: MessageType.text,
      lastMsg: 'deleted',
      msgId: msgId,
    );
    _firestore
        .collection('Users/$userId1/Chats')
        .doc(userId2)
        .set(chat.toDeletedMap(), SetOptions(merge: true));
  }

  // Reset the last message in chat node.
  static Future<void> resetChat({
    required String userId1,
    required String userId2,
  }) async {
    _firestore
        .collection('Users/$userId1/Chats')
        .doc(userId2)
        .set({'msgType': 'text', 'lastMsg': null, 'sentAt': null});
  }

  static Future<void> clearChat({
    required List<Message> messages,
    required String receiverId,
    bool showMessage = true,
  }) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      // Reset the last message in my chat node.
      resetChat(userId1: currentUer.userId, userId2: receiverId);

      // Loop the message futures
      final List<Future<void>> messageFutures =
          messages.map((msg) => msg.docRef!.delete()).toList();

      if (messageFutures.isNotEmpty) {
        Future.wait(messageFutures);
      }
      // Debug
      debugPrint("clearChat() -> success");
    } catch (e) {
      // Debug
      debugPrint("clearChat() -> error: $e");
    }
  }

  static Future<void> muteChat({
    required bool isMuted,
    required String receiverId,
  }) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await _firestore
          .collection('Users/$receiverId/Chats')
          .doc(currentUer.userId)
          .set({'isMuted': isMuted}, SetOptions(merge: true));
      // Debug
      debugPrint("muteChat() -> $isMuted");
    } catch (e) {
      // Debug
      debugPrint("muteChat() -> error: $e");
    }
  }

  static Future<bool> checkMuteStatus(String receiverId) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      final chatDoc = await _firestore
          .collection('Users/$receiverId/Chats')
          .doc(currentUer.userId)
          .get();
      return chatDoc.data()?['isMuted'] ?? false;
    } catch (e) {
      // Debug
      debugPrint("getMuteStatus() -> error: $e");
      return false;
    }
  }

  static Future<void> deleteChat({required String userId}) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      final reference = _firestore.collection('Users/${currentUer.userId}/Chats');

      // Delete messages
      final results = await reference.doc(userId).collection('Messages').get();
      final futures = results.docs.map((e) => e.reference.delete()).toList();
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      // Delete the chat node
      await reference.doc(userId).delete();

      debugPrint('saveChat() -> success');
    } catch (e) {
      debugPrint('saveChat() -> error: $e');
    }
  }
}
