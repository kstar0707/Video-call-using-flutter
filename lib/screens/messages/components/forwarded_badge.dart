import 'package:flutter/material.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:get/get.dart';

class ForwardedBadge extends StatelessWidget {
  const ForwardedBadge({
    super.key,
    required this.isSender,
  });

  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(
            'assets/icons/forward.svg',
            width: 16,
            height: 16,
            color: isSender ? Colors.white : greyColor,
          ),
          const SizedBox(width: 4),
          Text(
            'forwarded'.tr,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: isSender ? Colors.white : greyColor,
            ),
          ),
        ],
      ),
    );
  }
}
