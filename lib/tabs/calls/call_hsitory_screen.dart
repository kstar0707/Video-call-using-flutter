import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/floating_button.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/call_history.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/tabs/calls/controller/call_history_controller.dart';
import 'package:get/get.dart';

import 'components/call_history_card.dart';

class CallHistoryScreen extends GetView<CallHistoryController> {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          // Check loading
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          } else if (controller.calls.isEmpty) {
            return NoData(
              iconData: IconlyBold.call,
              text: 'no_calls'.tr,
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              vertical: defaultPadding,
            ),
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.calls.length,
            itemBuilder: (_, index) {
              final CallHistory call = controller.calls[index];

              return CallHistoryCard(call);
            },
          );
        },
      ),
      floatingActionButton: FloatingButton(
        icon: IconlyBold.calling,
        onPress: () => Get.toNamed(AppRoutes.contacts),
      ),
    );
  }
}
