import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/circle_button.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/story/story.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/tabs/stories/controller/story_view_controller.dart';
import 'package:get/get.dart';
import 'package:story_view/story_view.dart';

class StoryViewScreen extends StatelessWidget {
  const StoryViewScreen({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryViewController(story: story));
    final ReportController reportController = Get.find();
    final User user = story.user!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // <-- Story View -->
          StoryView(
            storyItems: controller.storyItems,
            controller: controller.storyController,
            onComplete: () => Get.back(),
            onStoryShow: (StoryItem item, index) {
              controller.getStoryItemIndex(index);
              controller.markSeen();
            },
          ),
          // Other info
          Container(
            margin: const EdgeInsets.only(top: 60),
            child: GestureDetector(
              onTap: () {
                RoutesHelper.toProfileView(user, false).then(
                  (value) => Get.back(),
                );
              },
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      IconlyLight.arrowLeft2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Profile avatar
                  CachedCircleAvatar(
                    radius: 20,
                    borderColor: primaryColor,
                    imageUrl: user.photoUrl,
                  ),
                  const SizedBox(width: 12),
                  // Other info
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile name
                        Text(
                          user.fullname,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        // Created at time
                        Obx(
                          () => Text(
                            controller.createdAt.formatDateTime,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Send message
                  if (!story.isOwner)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        onPressed: () => RoutesHelper.toMessages(user: user),
                        icon: const Icon(
                          IconlyLight.chat,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  // <-- More options -->
                  PopupMenuButton(
                    color: Colors.white,
                    onOpened: () => controller.storyController.pause(),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () => reportController.reportDialog(
                          type: ReportType.story,
                          story: controller.reportStoryItemData,
                        ),
                        child: Text('report_this_story'.tr),
                      ),
                      if (story.isOwner)
                        PopupMenuItem(
                          onTap: () => _deleteStoryItem(controller),
                          child: Text('delete_this_story'.tr),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Show seen by modal
          if (story.isOwner)
            Obx(() {
              return Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 16),
                child: CircleButton(
                  color: Colors.transparent,
                  onPress: () {
                    // Pause story
                    controller.storyController.pause();

                    // Show bottom modal
                    DialogHelper.showStorySeenByModal(
                      seenByList: controller.seenByList,
                      onDelete: () {
                        // Close modal
                        Get.back();
                        // Delete story item
                        _deleteStoryItem(controller);
                      },
                    );
                  },
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(IconlyBold.show, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.seenByList.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _deleteStoryItem(StoryViewController controller) {
    // Confirm delete story item
    DialogHelper.showAlertDialog(
      titleColor: errorColor,
      title: Text('delete_this_story'.tr),
      content: Text('this_action_cannot_be_reversed'.tr),
      actionText: 'DELETE'.tr.toUpperCase(),
      action: () {
        Get.back(); // Close confirm dialog
        Get.back(); // Close story view page
        controller.deleteStoryItem();
      },
    );
  }
}
