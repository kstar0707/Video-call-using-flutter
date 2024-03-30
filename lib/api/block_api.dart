import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';

abstract class BlockApi {
  //
  // BlockApi - CRUD Operations
  //

  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Block user profile
  static Future<bool> blockUser({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      await _firestore
          .collection('Users/$currentUserId/BlockedUsers')
          .doc(otherUserId)
          .set(
        {'userId': otherUserId, 'createdAt': FieldValue.serverTimestamp()},
      );
      // Show success message
      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, "user_blocked_successfully".tr);
      return true;
    } catch (e) {
      // Show error message
      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        "failed_to_block_user".trParams(
          {'error': e.toString()},
        ),
      );
      return false;
    }
  }

  // Unblock user profile
  static Future<bool> unblockUser({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      // Delete the blocked user entry from the subcollection
      await _firestore
          .collection('Users/$currentUserId/BlockedUsers')
          .doc(otherUserId)
          .delete();
      // Show success message
      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, "user_unblocked_successfully".tr);
      return true;
    } catch (e) {
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "failed_to_unblock_user".trParams(
          {'error': e.toString()},
        ),
      );
      return false;
    }
  }

  // Check blocked user
  static Future<bool> isBlocked({
    required String userId1,
    required String userId2,
  }) async {
    try {
      final doc = await _firestore
          .collection('Users/$userId1/BlockedUsers')
          .doc(userId2)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('isBlocked() -> error: $e');
      return false;
    }
  }
}
