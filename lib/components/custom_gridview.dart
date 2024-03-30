import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';

class CustomGridView extends StatelessWidget {
  const CustomGridView({
    super.key,
    this.scrollController,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.aspectRatio = 250 / 350,
    this.spacing = defaultPadding,
    this.scrollable = true,
    this.header,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  // Params
  final int itemCount, crossAxisCount;
  final ScrollController? scrollController;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? header;
  final double aspectRatio;
  final double spacing;
  final bool scrollable;

  // Loading more params
  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    // Build CustomScrollView
    return CustomScrollView(
      shrinkWrap: true,
      controller: scrollController,
      physics: scrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      slivers: <Widget>[
        // Header
        if (header != null) SliverToBoxAdapter(child: header),
        // GridView
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
        ),
        // Check loading status
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        // Show no more data
        if (!hasMore)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'no_more_data'.tr,
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
