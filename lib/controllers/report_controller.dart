import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:get/get.dart';

class ReportController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  Future<void> reportDialog({
    required ReportType type,
    String? userId,
    String? groupId,
    Map<String, dynamic>? story,
  }) async {
    final String title = switch (type) {
      ReportType.user => 'report_user'.tr,
      ReportType.group => 'report_group'.tr,
      ReportType.story => 'report_this_story'.tr,
    };

    await DialogHelper.showAlertDialog(
      barrierDismissible: false,
      titleColor: errorColor,
      title: Text(title),
      icon: const Icon(
        IconlyLight.dangerTriangle,
        color: errorColor,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: TextFormField(
            maxLines: 1,
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'message'.tr,
              hintText: 'write_your_feedback'.tr,
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'write_your_feedback'.tr;
              }
              return null;
            },
          ),
        ),
      ),
      actionText: 'report'.tr.toUpperCase(),
      action: () {
        if (_formKey.currentState!.validate()) {
          // Close dialog
          Get.back();
          // Send request
          ReportApi.report(
            type: type,
            message: _messageController.text.trim(),
            userId: userId,
            groupId: groupId,
            story: story,
          );
        }
      },
    );
    // Clear text input on close
    _messageController.clear();
  }

  @override
  void onClose() {
    _messageController.dispose();
    super.onClose();
  }
}
