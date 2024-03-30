import 'package:flutter/material.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/models/story/submodels/seen_by.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';

class StorySeenByModal extends StatelessWidget {
  const StorySeenByModal({
    super.key,
    required this.seenByList,
    required this.onDelete,
  });

  final List<SeenBy> seenByList;
  final Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(defaultRadius),
          topRight: Radius.circular(defaultRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            color: primaryColor,
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${'viewed_by'.tr} ${seenByList.length}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                PopupMenuButton(
                  color: Colors.white,
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      onTap: onDelete,
                      child: Text('delete_this_story'.tr),
                    )
                  ],
                ),
              ],
            ),
          ),
          // <-- List of viewers -->
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: seenByList.length,
              itemBuilder: (_, index) {
                final SeenBy seenBy = seenByList[index];

                return ListTile(
                  leading: CachedCircleAvatar(imageUrl: seenBy.photoUrl),
                  title: Text(seenBy.fullname),
                  subtitle: Text(seenBy.time.formatDateTime),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
