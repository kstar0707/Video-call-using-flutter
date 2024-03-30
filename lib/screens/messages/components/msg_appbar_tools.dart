import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/screens/messages/controllers/message_controller.dart';
import 'package:get/get.dart';

class MsgAppBarTools extends StatelessWidget implements PreferredSizeWidget {
  const MsgAppBarTools({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageController controller = Get.find();

    const Size iconSize = Size(23, 23);

    return Obx(() {
      final Message message = controller.selectedMessage.value!;
      final bool isTextMsg = message.type == MessageType.text;

      return AppBar(
        leading: IconButton(
          onPressed: () => controller.selectedMessage.value = null,
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        actions: [
          // <-- Reply message -->
          if (!message.isDeleted)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => controller.replyToMessage(message),
                icon: SvgIcon(
                  'assets/icons/reply.svg',
                  width: iconSize.width,
                  height: iconSize.height,
                  color: Colors.white,
                ),
              ),
            ),

          // <-- Delete message -->
          if (message.isSender)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () {
                  DialogHelper.showAlertDialog(
                    titleColor: errorColor,
                    title: Row(
                      children: [
                        const Icon(IconlyBold.delete,
                            color: errorColor, size: 25),
                        const SizedBox(width: 8),
                        Text('delete_message'.tr),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // <-- Soft Delete for everyone 1-to-1 or Group Chat
                        if (message.isSender && !message.isDeleted)
                          TextButton(
                            onPressed: () => controller
                                .softDeleteForEveryone()
                                .then((_) => controller.clearSelectedMsg()),
                            child: Text(
                              'delete_for_everyone'.tr,
                              style: const TextStyle(
                                  color: primaryColor, fontSize: 18),
                            ),
                          ),

                        // <-- Delete forever for group chat -->
                        if (controller.isGroup && message.isDeleted)
                          TextButton(
                            onPressed: () => controller
                                .deleteMessageForever()
                                .then((_) => controller.clearSelectedMsg()),
                            child: Text(
                              'delete_forever'.tr,
                              style: const TextStyle(
                                  color: primaryColor, fontSize: 18),
                            ),
                          ),

                        // <-- Delete for me
                        if (!controller.isGroup)
                          TextButton(
                            onPressed: () => message.isDeleted
                                ? controller
                                    .deleteMessageForever()
                                    .then((_) => controller.clearSelectedMsg())
                                : controller
                                    .deleteMsgForMe()
                                    .then((_) => controller.clearSelectedMsg()),
                            child: Text(
                              'delete_for_me'.tr,
                              style: const TextStyle(
                                  color: primaryColor, fontSize: 18),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                icon: const Icon(
                  IconlyBold.delete,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),

          // <-- Forward message -->
          if (!message.isDeleted)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => controller
                    .forwardMessage(message)
                    .then((_) => controller.clearSelectedMsg()),
                icon: SvgIcon(
                  'assets/icons/forward.svg',
                  width: iconSize.width,
                  height: iconSize.height,
                  color: Colors.white,
                ),
              ),
            ),

          // Copy message / Download the file
          if (!message.isDeleted)
            if (message.type != MessageType.location)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: () {
                    // Check message type
                    if (isTextMsg) {
                      // <-- Copy text message -->
                      Clipboard.setData(ClipboardData(text: message.textMsg))
                          .then((_) => controller.clearSelectedMsg());
                      DialogHelper.showSnackbarMessage(
                          SnackMsgType.success, 'message_copied'.tr,
                          duration: 1);
                    } else {
                      //
                      // <-- Download the file -->
                      //
                      AppHelper.downloadFile(message.fileUrl);
                    }
                  },
                  icon: Icon(isTextMsg ? Icons.copy : Icons.download,
                      color: Colors.white, size: 25),
                ),
              ),
        ],
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
