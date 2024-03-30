import 'dart:io';

import 'package:chat_messenger/api/auth_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Filter;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/api/chat_api.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/helpers/settings_helper.dart';
import 'package:chat_messenger/models/user.dart';

import '../tabs/groups/controllers/group_controller.dart';

abstract class UserApi {
  //
  // UserApi - CRUD Operations
  //

  // Firebase instances
  static final _firestore = FirebaseFirestore.instance;
  static final _realtime = FirebaseDatabase.instance;
  static final _firebaseMsg = FirebaseMessaging.instance;

  static Future<dynamic> createAccount({
    File? photoFile,
    required String fullname,
    required String username,
  }) async {
    try {
      final firebaseUser = AuthController.instance.firebaseUser!;

      // Get Firebase User Info:
      final String userId = firebaseUser.uid;
      final String email = firebaseUser.email ?? '';
      final String deviceToken = await _firebaseMsg.getToken() ?? '';

      // Upload profile photo
      String photoUrl = '';

      // Check file
      if (photoFile != null) {
        photoUrl = await AppHelper.uploadFile(
          file: photoFile,
          userId: userId,
        );
      }

      // Set profile info
      final User user = User(
        userId: userId,
        photoUrl: photoUrl,
        fullname: fullname,
        username: username,
        email: email,
        bio: 'default_bio'.trParams({'appName': AppConfig.appName}),
        deviceToken: deviceToken,
        loginProvider: AuthController.instance.provider,
        lastActive: DateTime.now(),
        isOnline: true,
      );

      // Save data
      await _firestore.collection('Users').doc(userId).set(user.toMap());

      // Subscribe for Push Notifications
      _firebaseMsg.subscribeToTopic('NOTIFY_USERS');
      return true;
    } catch (e) {
      return e;
    }
  }

  static Future<dynamic> updateAccount({
    File? photoFile,
    required String fullname,
    required String username,
    required String bio,
  }) async {
    try {
      // Get current user
      final User currentUser = AuthController.instance.currentUser;

      // Update photo
      String photoUrl = currentUser.photoUrl;

      // Check file
      if (photoFile != null) {
        photoUrl = await AppHelper.uploadFile(
          file: photoFile,
          userId: currentUser.userId,
        );
      }

      // Save data
      await _firestore.collection('Users').doc(currentUser.userId).update({
        'photoUrl': photoUrl,
        'fullname': fullname,
        'username': username,
        'bio': bio,
      });

      return true;
    } catch (e) {
      return e;
    }
  }

  static Future<User?> getUser(String userId) async {
    final doc = await _firestore.collection('Users').doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  static Stream<User> getUserUpdates(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .snapshots()
        .map((event) => User.fromMap(event.data()!));
  }

  // Check username availability in database
  static Future<bool> checkUsername({
    required String username,
    bool showMsg = true,
  }) async {
    final query = await _firestore
        .collection('Users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    final bool result = query.docs.isEmpty;

    if (result) {
      if (showMsg) {
        DialogHelper.showSnackbarMessage(
            SnackMsgType.success, "username_success".tr);
      }
      return true;
    }
    if (showMsg) {
      DialogHelper.showSnackbarMessage(SnackMsgType.error, "username_taken".tr);
    }
    return false;
  }

  // Update user data
  static Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
    bool isSet = false,
  }) async {
    if (isSet) {
      await _firestore
          .collection('Users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } else {
      await _firestore.collection('Users').doc(userId).update(data);
    }
  }

  static Future<void> updateUserInfo(User user) async {
    // Get device token
    final String deviceToken = await _firebaseMsg.getToken() ?? '';

    // Save data
    await updateUserData(
      userId: user.userId,
      data: {
        'deviceToken': deviceToken,
        'lastActive': DateTime.now().millisecondsSinceEpoch,
        'isOnline': true,
      },
      isSet: true,
    );
    // Subscribe for Push Notifications
    _firebaseMsg.subscribeToTopic('NOTIFY_USERS');
  }

  // Delete all the files upload by user
  static Future<void> deleteUserStorageFiles() async {
    try {
      final User currentUser = AuthController.instance.currentUser;

      final ListResult listResult = await FirebaseStorage.instance
          .ref('uploads/users/${currentUser.userId}')
          .listAll();
      final List<Future<void>> references =
          listResult.items.map((e) => e.delete()).toList();
      // Check result
      if (references.isNotEmpty) {
        await Future.wait(references);
        debugPrint('_deleteUserStorageFiles() -> success');
      } else {
        debugPrint('_deleteUserStorageFiles() -> no files');
      }
    } catch (e) {
      debugPrint('_deleteUserStorageFiles() -> error: $e');
    }
  }

  static Future<void> deleteUserAccount() async {
    try {
      // Get current user model
      final User currentUer = AuthController.instance.currentUser;

      DialogHelper.showProcessingDialog(
        title: 'deleting_profile_account'.tr,
        barrierDismissible: false,
      );

      // Delete all user-uploaded files
      AppHelper.deleteStorageFiles('uploads/${currentUer.userId}');

      // Get User Groups
      final List<Group> userGroups = GroupController.instance.groups
          .where((group) => group.createdBy == currentUer.userId)
          .toList();

      // Delete user's groups
      final groupFutures = userGroups
          .map((e) => _firestore.collection('Groups').doc(e.groupId).delete());
      if (groupFutures.isNotEmpty) {
        await Future.wait(groupFutures);
      }

      // Delete profile account data
      await _firestore.collection('Users').doc(currentUer.userId).delete();

      // Update admin statistics
      await SettingsHelper.updateTotalUsers(false);

      // Close previous dialog
      DialogHelper.closeDialog();

      // Show confirm dialog
      DialogHelper.showAlertDialog(
        icon: const Icon(Icons.check_circle, color: primaryColor),
        title: Text('success'.tr),
        content: Text(
          'profile_account_successfully_deleted'.tr,
          style: const TextStyle(fontSize: 16),
        ),
        actionText: 'sign_out'.tr.toUpperCase(),
        action: () => AuthApi.signOut(),
        showCancelButton: false,
        barrierDismissible: false,
      );
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(SnackMsgType.error,
          "failed_to_delete_user_account".trParams({'error': e.toString()}));
    }
  }

  ///
  /// <-- User Presense features -->
  ///

  static Map<String, dynamic> _isUserOnline(bool value) {
    var data = {
      'isOnline': value,
      'lastActive': Timestamp.now().millisecondsSinceEpoch,
    };
    if (!value) {
      data['isTyping'] = false;
      data['isRecording'] = false;
    }
    return data;
  }

  // Update User Presence in Realtime Database.
  static Future<void> updateUserPresenceInRealtimeDb() async {
    final User currentUer = AuthController.instance.currentUser;

    // Get Realtime database reference
    final DatabaseReference connectedRef = _realtime.ref('.info/connected');
    // Listen to updates
    connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value as bool? ?? false;
      if (isConnected) {
        _realtime.ref().child(currentUer.userId).update(_isUserOnline(true));
      } else {
        _realtime
            .ref()
            .child(currentUer.userId)
            .onDisconnect()
            .update(_isUserOnline(false));
      }
    });
  }

  // Update User presence
  static Future<void> updateUserPresence(bool isOnline) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await updateUserData(
        userId: currentUer.userId,
        data: _isUserOnline(isOnline),
        isSet: true,
      );
      debugPrint('updateUserPresence() -> success');
    } catch (e) {
      debugPrint('updateUserPresence() -> error: $e');
    }
  }

  /// Update User typing status
  static Future<void> updateUserTypingStatus(
    bool isTyping,
    String receiverId,
  ) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await updateUserData(
        userId: currentUer.userId,
        data: {
          'isTyping': isTyping,
          'typingTo': receiverId,
          'isRecording': false,
        },
        isSet: true,
      );
      // Also update chat node typing status
      await ChatApi.updateChatTypingStatus(isTyping, receiverId);
      debugPrint('updateUserTypingStatus() -> success');
    } catch (e) {
      debugPrint('updateUserTypingStatus() -> error: $e');
    }
  }

  /// Update User recording status
  static Future<void> updateUserRecordingStatus(
    bool isRecording,
    String receiverId,
  ) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await updateUserData(
        userId: currentUer.userId,
        data: {
          'isRecording': isRecording,
          'recordingTo': receiverId,
          'isTyping': false
        },
        isSet: true,
      );
      // Also update chat node recording status
      await ChatApi.updateChatRecordingStatus(isRecording, receiverId);
      debugPrint('updateUserRecordingStatus() -> success');
    } catch (e) {
      debugPrint('updateUserRecordingStatus() -> error: $e');
    }
  }

  /// Close User typing or recording status
  static Future<void> closeTypingOrRecordingStatus() async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await updateUserData(
        userId: currentUer.userId,
        data: {'isTyping': false, 'isRecording': false},
        isSet: true,
      );
      debugPrint('closeTypingOrRecordingStatus() -> success');
    } catch (e) {
      debugPrint('closeTypingOrRecordingStatus() -> error: $e');
    }
  }

  static Future<void> muteGroup(String groupId, bool isMuted) async {
    try {
      final User currentUer = AuthController.instance.currentUser;

      await UserApi.updateUserData(
        userId: currentUer.userId,
        data: {
          'mutedGroups': isMuted
              ? FieldValue.arrayRemove([groupId])
              : FieldValue.arrayUnion([groupId])
        },
      );
      debugPrint('muteGroup() -> success');
    } catch (e) {
      debugPrint('muteGroup() -> error: $e');
    }
  }
}
