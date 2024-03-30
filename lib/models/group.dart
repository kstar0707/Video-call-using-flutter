import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:get/get.dart';

import 'user.dart';

class Group {
  String groupId;
  String createdBy;
  String updatedBy;
  String photoUrl;
  String name;
  String description;
  Message? lastMsg;
  int unread;
  bool sendMessages;
  bool isBroadcast;
  DateTime? createdAt;
  DateTime? updatedAt;
  // Members
  List<User> members;
  List<String> adminMembers;
  List<String> removedMembers;

  Group({
    required this.groupId,
    this.members = const [],
    this.adminMembers = const [],
    this.removedMembers = const [],
    this.createdBy = '',
    this.updatedBy = '',
    this.photoUrl = '',
    this.name = '',
    this.description = '',
    this.unread = 0,
    this.sendMessages = true,
    this.isBroadcast = false,
    this.createdAt,
    this.updatedAt,
    this.lastMsg,
  });

  factory Group.fromMap({
    required Map<String, dynamic> data,
    required List<User> members,
  }) {
    return Group(
      groupId: data['groupId'] ?? '',
      members: members,
      adminMembers: List<String>.from(data['adminMembers'] ?? []),
      removedMembers: List<String>.from(data['removedMembers'] ?? []),
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      unread: _getUnreadMessages(data['unreadList'] ?? {}),
      sendMessages: data['sendMessages'] ?? true,
      isBroadcast: data['isBroadcast'] ?? false,
      lastMsg: data['lastMsg'] != null
          ? Message.fromMap(data: data['lastMsg'], isGroup: true)
          : null,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'photoUrl': photoUrl,
      'name': name,
      'description': description,
      'sendMessages': sendMessages,
      'isBroadcast': isBroadcast,
      'members': members.map((User m) => m.userId).toList(),
      'unreadList': isBroadcast ? {} : _saveUnreadList,
      'adminMembers': [createdBy],
      'lastMsg': lastMsg?.toMap(isGroup: true),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap({bool isDeleted = false}) {
    Map<String, dynamic> data = {
      'lastMsg':
          isDeleted ? lastMsg?.toDeletedMap() : lastMsg?.toMap(isGroup: true),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!isBroadcast) {
      data.addAll(_updateUnreadList);
    }
    return data;
  }

  ///
  /// Other Helpers
  ///

  // Get current user member
  static User get _currentUser => AuthController.instance.currentUser;

  /// Get active participants
  List<User> get participants =>
      members.where((m) => !removedMembers.contains(m.userId)).toList();

  /// Get recipients
  List<User> get recipients =>
      members.where((m) => m.userId != _currentUser.userId).toList();

  bool isRemoved(String memberId) {
    return removedMembers.contains(memberId);
  }

  bool isAdmin(String memberId) {
    return adminMembers.contains(memberId);
  }

  bool get isMuted => _currentUser.mutedGroups.contains(groupId);

  Map<String, dynamic> get _saveUnreadList {
    final list = members.where((m) => m.userId != _currentUser.userId).toList();
    Map<String, dynamic> data = {};
    for (final m in list) {
      data[m.userId] = 1;
    }
    return data;
  }

  Map<String, dynamic> get _updateUnreadList {
    final list = members.where((m) => m.userId != _currentUser.userId);
    Map<String, dynamic> data = {};
    for (final m in list) {
      data['unreadList.${m.userId}'] = FieldValue.increment(1);
    }
    return data;
  }

  static int _getUnreadMessages(Map<String, dynamic> mapKeys) {
    final String key = _currentUser.userId;
    return mapKeys[key] ?? 0;
  }

  User getCurrentMember() {
    return members.firstWhere((m) => m.userId == _currentUser.userId);
  }

  User getMemberProfile(String memberId) {
    return members.firstWhereOrNull((m) => m.userId == memberId) ?? User();
  }
}
