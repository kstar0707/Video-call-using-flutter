import 'package:flutter/material.dart';
import 'package:chat_messenger/tabs/calls/controller/call_history_controller.dart';
import 'package:get/get.dart';

class ClearCallsButton extends GetView<CallHistoryController> {
  const ClearCallsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.calls.isEmpty) {
        return const SizedBox.shrink();
      }
      return PopupMenuButton(
        iconColor: Colors.white,
        itemBuilder: (_) => [
          PopupMenuItem(
            onTap: () => controller.clearCallLog(),
            child: Text('clear_call_log'.tr),
          ),
        ],
      );
    });
  }
}
