import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/api/message_api.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/group_update.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/services/push_notification_service.dart';
import 'package:get/get.dart';

abstract class GroupApi {
  //
  // GroupApi - CRUD Operations
  //

  // Groups collection reference
  static final CollectionReference<Map<String, dynamic>> groupsRef =
      FirebaseFirestore.instance.collection('Groups');

  // Create new group
  static Future<bool> createGroup({
    File? photoFile,
    required String name,
    String description = '',
    required List<User> members,
    required bool isBroadcast,
  }) async {
    try {
      final User admin = AuthController.instance.currentUser;
      String photoUrl = '';

      DialogHelper.showProcessingDialog(barrierDismissible: false);

      // Check image file
      if (photoFile != null) {
        photoUrl =
            await AppHelper.uploadFile(file: photoFile, userId: admin.userId);
      }

      // Generate the Group ID.
      final String groupId = AppHelper.generateID;

      // Created group message
      final Message createdGroupMsg = Message(
        msgId: AppHelper.generateID,
        type: MessageType.groupUpdate,
        textMsg: UpdateType.created.name,
        senderId: admin.userId,
      );

      // Build Group Instance
      final Group group = Group(
        groupId: groupId,
        createdBy: admin.userId,
        photoUrl: photoUrl,
        name: name,
        description: description,
        members: [admin, ...members],
        lastMsg: createdGroupMsg,
        isBroadcast: isBroadcast,
      );

      // Create the new Group
      await Future.wait([
        // Save new group
        groupsRef.doc(groupId).set(group.toMap()),
        // Save group message
        groupsRef
            .doc(groupId)
            .collection('Messages')
            .add(createdGroupMsg.toMap(isGroup: true)),
      ]);

      // Update message
      final Message addedMemberMsg = Message(
        msgId: AppHelper.generateID,
        type: MessageType.groupUpdate,
        textMsg: UpdateType.added.name,
        groupUpdate: GroupUpdate(
          members: members.length,
          memberId: members.length > 1 ? '' : members.first.userId,
        ),
        senderId: admin.userId,
      );

      // Update the last message
      group.lastMsg = addedMemberMsg;

      // Save last message
      MessageApi.saveGroupMessage(group);

      // Check broadcast param
      if (!isBroadcast) {
        // Hold notify futures
        List<Future<void>> notifyFutures = [];

        // Notify the members
        for (final member in members) {
          notifyFutures.add(
            PushNotificationService.sendNotification(
              type: NotificationType.group,
              title: name,
              body: '${admin.fullname} ${'added'.tr} ${'you'.tr.toLowerCase()}',
              deviceToken: member.deviceToken,
            ),
          );
        }
        // Send push notifications
        Future.wait(notifyFutures);
      }

      // Close processing dialog
      DialogHelper.closeDialog();

      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        isBroadcast ? "create_broadcast_success".tr : "create_group_success".tr,
      );
      return true;
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
      return false;
    }
  }

  static Future<void> updatePhoto(Group group) async {
    try {
      final User admin = AuthController.instance.currentUser;

      // Pick photo from camera/gallery
      final File? photoFile = await DialogHelper.showPickImageDialog(
        isAvatar: true,
      );

      if (photoFile == null) return;

      // Init processing
      DialogHelper.showProcessingDialog(barrierDismissible: false);

      // Check image file
      final String photoUrl =
          await AppHelper.uploadFile(file: photoFile, userId: admin.userId);

      // Update message
      final Message updateMsg = Message(
        msgId: AppHelper.generateID,
        type: MessageType.groupUpdate,
        textMsg: UpdateType.details.name,
        senderId: admin.userId,
      );

      // Update the group details
      group.photoUrl = photoUrl;
      group.lastMsg = updateMsg;
      final Map<String, dynamic> data = group.toUpdateMap();
      data['photoUrl'] = photoUrl;
      data['updatedBy'] = admin.userId;

      // Save last message
      await MessageApi.saveGroupMessage(group, data: data);

      DialogHelper.closeDialog();

      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, 'photo_updated_successfully'.tr);
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  static Future<void> updateDetails(Group group) async {
    try {
      final User admin = AuthController.instance.currentUser;

      // Update message
      final Message updateMsg = Message(
        msgId: AppHelper.generateID,
        type: MessageType.groupUpdate,
        textMsg: UpdateType.details.name,
        senderId: admin.userId,
      );

      // Update the group details
      group.lastMsg = updateMsg;
      final Map<String, dynamic> data = group.toUpdateMap();
      data['name'] = group.name;
      data['description'] = group.description;
      // Check broadcast
      if (!group.isBroadcast) {
        data['sendMessages'] = group.sendMessages;
      }
      data['updatedBy'] = admin.userId;

      // Save last message
      MessageApi.saveGroupMessage(group, data: data);

      DialogHelper.showSnackbarMessage(
          SnackMsgType.success,
          group.isBroadcast
              ? 'broadcast_details_updated_successfully'.tr
              : 'group_details_updated_successfully'.tr);
    } catch (e) {
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  static Stream<List<Group>> getUserGroups(String userId) {
    final User currentUser = AuthController.instance.currentUser;

    return groupsRef
        .where('members', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<Group> groups = [];
      // Handle the group data
      for (final doc in event.docs) {
        final Map<String, dynamic> data = doc.data();
        final bool isBroadcast = data['isBroadcast'] ?? false;
        final String createdBy = data['createdBy'];
        final List<String> memberIds = List<String>.from(data['members'] ?? []);
        List<Future<User?>> futures = [];
        List<User?> users = [];

        // Check broadcast
        if (isBroadcast) {
          // Make sure the broadcast is only shown to the owner
          if (createdBy == currentUser.userId) {
            futures =
                memberIds.map((userId) => UserApi.getUser(userId)).toList();
          }
        } else {
          futures = memberIds.map((userId) => UserApi.getUser(userId)).toList();
        }

        // Check user futures
        if (futures.isNotEmpty) {
          users = await Future.wait(futures);
        }
        // Get non-nullable members list
        final List<User> members = users.whereType<User>().toList();

        // Get group object
        final Group group = Group.fromMap(data: doc.data(), members: members);

        // Check removed member to hide the group if not admin
        final bool isValid = !group.isRemoved(currentUser.userId) ||
            group.isRemoved(currentUser.userId) &&
                group.isAdmin(currentUser.userId);

        if (isValid) {
          // Check broadcast list
          if (isBroadcast) {
            if (createdBy == currentUser.userId) {
              groups.add(Group.fromMap(data: doc.data(), members: members));
            }
          } else {
            groups.add(Group.fromMap(data: doc.data(), members: members));
          }
        }
      }
      return groups;
    });
  }

  // Reset total unread messages
  static Future<void> readChat(String groupId) async {
    try {
      final User currentUser = AuthController.instance.currentUser;
      
      await groupsRef.doc(groupId).update({
        'unreadList.${currentUser.userId}': FieldValue.delete(),
      });
      debugPrint('readChat() -> success');
    } catch (e) {
      debugPrint('readChat() -> error: $e');
    }
  }

  static Future<void> addMembers({
    required Group group,
    required List<User> newMembers,
    required bool isBroadcast,
  }) async {
    try {
      final User admin = AuthController.instance.currentUser;

      // Build update message
      final Message message = Message(
        msgId: AppHelper.generateID,
        type: MessageType.groupUpdate,
        textMsg: UpdateType.added.name,
        groupUpdate: GroupUpdate(
          members: newMembers.length,
          memberId: newMembers.length > 1 ? '' : newMembers.first.userId,
        ),
        senderId: admin.userId,
      );

      // Update the last message
      group.lastMsg = message;

      final List<String> memberIds = newMembers.map((e) => e.userId).toList();
      final Map<String, dynamic> data = group.toUpdateMap();
      data['members'] = FieldValue.arrayUnion(memberIds);
      data['removedMembers'] = FieldValue.arrayRemove(memberIds);
      data['updatedBy'] = admin.userId;

      // Save last message
      MessageApi.saveGroupMessage(group, data: data);

      // Check broadcast
      if (!isBroadcast) {
        // Notify futures
        List<Future<void>> notifyFutures = [];

        // Notify new members
        for (final member in newMembers) {
          notifyFutures.add(
            PushNotificationService.sendNotification(
              type: NotificationType.group,
              title: group.name,
              body: '${admin.fullname} ${'added'.tr} ${'you'.tr.toLowerCase()}',
              deviceToken: member.deviceToken,
            ),
          );
        }

        // Send push notifications to new members
        Future.wait(notifyFutures);
      }

      DialogHelper.showSnackbarMessage(
          SnackMsgType.success,
          isBroadcast
              ? 'recipients_added_successfully'.tr
              : "participants_added_successfully".tr);
    } catch (e) {
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  static Future<void> removeMember({
    required Group group,
    required String memberId,
    bool byAdmin = false,
  }) async {
    try {
      // Update message
      final Message message = Message(
        msgId: AppHelper.generateID,
        type: MessageType.groupUpdate,
        textMsg: byAdmin ? UpdateType.removed.name : UpdateType.left.name,
        groupUpdate: GroupUpdate(
          memberId: memberId,
        ),
        senderId: AuthController.instance.currentUser.userId,
      );

      // Update the last message
      group.lastMsg = message;
      // Update the group info
      final Map<String, dynamic> data = group.toUpdateMap();
      if (group.isBroadcast) {
        data['members'] = FieldValue.arrayRemove([memberId]);
      } else {
        data['removedMembers'] = FieldValue.arrayUnion([memberId]);
      }
      await MessageApi.saveGroupMessage(group, data: data);

      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, 'removed_successfully'.tr);
    } catch (e) {
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  // <-- Add or remove Admin role -->
  static Future<void> updateAdminRole({
    required bool isAdd,
    required Group group,
    required User member,
  }) async {
    try {
      // Close bottom modal
      Get.back();

      final User admin = AuthController.instance.currentUser;

      // Update message
      final Message updateMsg = Message(
        msgId: AppHelper.generateID,
        type: MessageType.groupUpdate,
        textMsg: isAdd ? UpdateType.added.name : UpdateType.removed.name,
        groupUpdate: GroupUpdate(
          asAdmin: true,
          memberId: member.userId,
        ),
        senderId: admin.userId,
      );

      // Update the group details
      group.lastMsg = updateMsg;
      final Map<String, dynamic> data = group.toUpdateMap();
      data['adminMembers'] = isAdd
          ? FieldValue.arrayUnion([member.userId])
          : FieldValue.arrayRemove([member.userId]);
      data['updatedBy'] = admin.userId;

      // Save last message
      MessageApi.saveGroupMessage(group, data: data);

      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        isAdd ? 'admin_added_successfully'.tr : 'admin_removed_successfully'.tr,
      );
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  // Delete group/broadcast
  static Future<bool> deleteGroup(Group group) async {
    try {
      // Delete group
      await groupsRef.doc(group.groupId).delete();
      // Delete group message files
      MessageApi.deleteMessageFiles();
      return true;
    } catch (e) {
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
      return false;
    }
  }
}
