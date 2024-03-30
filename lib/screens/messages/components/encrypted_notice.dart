import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:get/get.dart';

class EncryptedNotice extends StatelessWidget {
  const EncryptedNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(
        horizontal: defaultMargin,
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              const WidgetSpan(
                child: Icon(IconlyBold.lock, size: 16),
              ),
              TextSpan(
                text:
                    ' ${'encrypted_message'.tr} ${'no_one_outside_of_this_chat_can_read_them'.trParams(
                  {'appName': AppConfig.appName},
                )}',
                //style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
