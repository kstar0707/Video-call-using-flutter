import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';

import 'loading_indicator.dart';

class LoadMore extends StatelessWidget {
  const LoadMore({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show Load more
          if (isLoadingMore) const LoadingIndicator(),
          // No more data
          if (!hasMore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: Text(
                'no_more_data'.tr,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
        ],
      ),
    );
  }
}
