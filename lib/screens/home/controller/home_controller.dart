import 'package:chat_messenger/screens/contacts/controllers/contact_controller.dart';
import 'package:chat_messenger/tabs/calls/controller/call_history_controller.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:chat_messenger/tabs/stories/controller/story_controller.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/tabs/calls/call_hsitory_screen.dart';
import 'package:chat_messenger/tabs/groups/screens/groups_screen.dart';
import 'package:chat_messenger/tabs/profile/profile_screen.dart';
import 'package:chat_messenger/tabs/stories/stories_screen.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/tabs/chats/chats_screen.dart';

class HomeController extends GetxController {
  // Vars
  final RxInt pageIndex = 0.obs;

  // List of tab pages
  final List<Widget> pages = [
    const ChatsScreen(),
    const GroupsScreen(),
    const StoriesScreen(),
    const CallHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void onInit() {
    Get.put(ContactController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(GroupController(), permanent: true);
    Get.put(CallHistoryController(), permanent: true);
    Get.put(StoryController(), permanent: true);
    super.onInit();
  }
}
