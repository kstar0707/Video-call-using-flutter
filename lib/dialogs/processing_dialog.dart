import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/theme/app_theme.dart';

class ProcessingDialog extends StatelessWidget {
  const ProcessingDialog(
    this.title, {
    super.key,
    this.description,
  });

  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: defaultMargin * 2),
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: AppTheme.of(context).isDarkMode ? greyColor : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitThreeBounce(size: 25, color: primaryColor),
            const SizedBox(height: 16.0),
            Text(
              title ?? 'processing'.tr,
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            const SizedBox(height: 8.0),
            Text(description ?? 'please_wait'.tr,
                style: Theme.of(context).textTheme.bodyLarge!),
          ],
        ),
      ),
    );
  }
}
