import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/models/call.dart';

class JoinCallIndicator extends StatelessWidget {
  const JoinCallIndicator(this.call, {super.key, this.loadingColor});

  final Call call;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    // Vars
    final String profileName =
        call.isCaller ? call.receiverName : call.callerName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile name
        Text(
          profileName,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.white54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Show when current user is a caller
        if (call.isCaller)
          Text(
            'calling'.tr,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 3),
        // Show loading
        LoadingIndicator(color: loadingColor ?? primaryColor),
      ],
    );
  }
}
