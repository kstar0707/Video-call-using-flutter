import 'dart:async';

import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/chat_api.dart';
import 'package:chat_messenger/models/chat.dart';

class ChatController extends GetxController {
  // Get the current instance
  static ChatController instance = Get.find();

  // Vars
  final RxBool isLoading = RxBool(true);
  final RxList<Chat> chats = RxList();
  final RxBool isSearching = RxBool(false);
  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<Chat>>? _stream;

  bool get newMessage => chats.where((el) => el.unread > 0).isNotEmpty;

  @override
  void onInit() {
    // Load chats
    _getChats();
    super.onInit();
  }

  @override
  void onClose() {
    _stream?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _getChats() {
    _stream = ChatApi.getChats().listen((event) {
      chats.value = event;
      isLoading.value = false;
    }, onError: (e) => debugPrint(e.toString()));
  }

  Chat getChat(String receiverId) {
    final Chat chat = ChatController.instance.chats
        .firstWhere((chat) => chat.receiver!.userId == receiverId);
    return chat;
  }

  bool isChatMuted(String receiverId) {
    final Chat chat = ChatController.instance.chats
        .firstWhere((chat) => chat.receiver!.userId == receiverId);
    return chat.isMuted;
  }

  // Search chats by user full name
  List<Chat> searchChat() {
    final String text = searchController.text.trim();

    isSearching.value = text.isNotEmpty;
    return chats
        .where((chat) =>
            chat.receiver!.fullname.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  void clearSerachInput(BuildContext context) {
    searchController.clear();
    isSearching.value = false;
    FocusScope.of(context).unfocus();
  }

  void deleteChat(String userId) {
    // Confirm delete chat
    DialogHelper.showAlertDialog(
      titleColor: errorColor,
      title: Text('delete_chat'.tr),
      content: Text('this_action_cannot_be_reversed'.tr),
      actionText: 'DELETE'.tr.toUpperCase(),
      action: () {
        Get.back();
        ChatApi.deleteChat(userId: userId);
      },
    );
  }
}
