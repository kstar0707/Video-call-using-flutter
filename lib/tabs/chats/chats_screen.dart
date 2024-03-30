import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/floating_button.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/models/chat.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:get/get.dart';

import 'components/chat_card.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // Vars
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final ChatController controller = Get.find();

    // Other vars
    const padding = EdgeInsets.symmetric(vertical: defaultPadding);

    return Scaffold(
      body: Obx(
        () {
          // Check loading
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          } else if (controller.chats.isEmpty) {
            return NoData(
              iconData: IconlyBold.chat,
              text: 'no_chats'.tr,
            );
          }
          // Get the chats list
          final List<Chat> chats = controller.isSearching.value
              ? controller.searchChat()
              : controller.chats;

          return ListView.builder(
            shrinkWrap: true,
            padding: padding,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: chats.length,
            itemBuilder: (_, index) {
              final Chat chat = chats[index];

              return ChatCard(
                chat,
                onDeleteChat: () =>
                    controller.deleteChat(chat.receiver!.userId),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingButton(
        icon: IconlyBold.chat,
        onPress: () => Get.toNamed(AppRoutes.contacts),
      ),
    );
  }
}
