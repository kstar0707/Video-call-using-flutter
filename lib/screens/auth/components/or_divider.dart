import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'or'.tr,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: greyColor),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
