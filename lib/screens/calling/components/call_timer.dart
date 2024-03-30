import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/screens/calling/controller/call_controller.dart';
import 'package:chat_messenger/screens/calling/helper/call_helper.dart';

class CallTimer extends StatelessWidget {
  const CallTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final CallController controller = Get.find();

    return Obx(
      () => Text(
        CallHelper.formatTime(controller.seconds.value),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
