import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/circle_button.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';

class SearchChatInput extends GetView<ChatController> {
  const SearchChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final Color? color = isDarkMode ? null : Colors.white;

    return Obx(
      () {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
          child: TextField(
            controller: controller.searchController,
            onChanged: (_) => controller.searchChat(),
            style: TextStyle(color: color),
            decoration: InputDecoration(
              hintText: 'search_chats'.tr,
              filled: true,
              hintStyle: const TextStyle(color: Colors.white54),
              fillColor: color?.withOpacity(0.3),
              focusColor: color,
              prefixIcon: Icon(IconlyLight.search, color: color),
              suffixIcon: controller.isSearching.value
                  ? CircleButton(
                      color: Colors.transparent,
                      icon: Icon(IconlyLight.closeSquare, color: color),
                      onPress: () => controller.clearSerachInput(context),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
