import 'package:chat_messenger/api/chat_api.dart';
import 'package:chat_messenger/api/group_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

abstract class RoutesHelper {
  ///
  /// Open routes helpers
  ///

  // Open messages page
  static Future<dynamic> toMessages({
    bool isGroup = false,
    User? user,
    String? groupId,
  }) async {
    // Get controllers
    final GroupController groupController = Get.find();

    // Set groupId
    if (groupId != null) {
      groupController.groupId.value = groupId;
    }

    //
    // <-- Go to messages page -->
    //
    final result = await Get.toNamed(
      AppRoutes.messages,
      arguments: {'isGroup': isGroup, 'user': user, 'groupId': groupId},
    );

    // Reset unread counter
    if (groupId != null) {
      // Group Chat
      GroupApi.readChat(groupId);
    } else if (user != null) {
      final User currentUser = AuthController.instance.currentUser;
      // Update typing or recording
      if (currentUser.isTyping || currentUser.isRecording) {
        // 1-to-1 Chat
        ChatApi.leaveChat(user.userId);
      }
    }

    // Reset the previous path
    PreferencesController.instance.groupWallpaperPath.value = null;

    return Future.value(result);
  }

  static Future<dynamic> toNewGroup(bool isBroadcast) async {
    return Get.toNamed(
      AppRoutes.createGroup,
      arguments: {'isBroadcast': isBroadcast},
    );
  }

  static Future<dynamic> toGroupDetails(String groupId) async {
    return Get.toNamed(
      AppRoutes.groupDetails,
      arguments: {'groupId': groupId},
    );
  }

  static Future<dynamic> toEditGroup(Group group) async {
    return Get.toNamed(
      AppRoutes.editGroup,
      arguments: {'group': group},
    );
  }

  static Future<List?> toSelectContacts({
    required String title,
    required bool isBroadcast,
    bool showGroups = false,
  }) async {
    final List? contacts = await Get.toNamed(
      AppRoutes.selectContacts,
      arguments: {
        'title': title,
        'showGroups': showGroups,
        'isBroadcast': isBroadcast,
      },
    ) as List?;
    return contacts;
  }

  static Future<dynamic> toProfileView(User user, bool isGroup) async {
    return Get.toNamed(
      AppRoutes.profileView,
      arguments: {'user': user, 'isGroup': isGroup},
    );
  }
}
