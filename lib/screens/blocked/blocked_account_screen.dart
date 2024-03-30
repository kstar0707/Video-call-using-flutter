import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/config/theme_config.dart';

class BlockedAccountScreen extends StatelessWidget {
  const BlockedAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor,
              child: Icon(IconlyLight.lock, size: 60, color: Colors.white),
            ),
            Text(
              "your_account_is_blocked".tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("please_contact_support_to_request_activation".tr),
            const SizedBox(height: 10),
            const Text(
              AppConfig.appEmail,
              style: TextStyle(color: primaryColor, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
