import 'package:flutter/material.dart';
import 'package:chat_messenger/api/story_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/story/story.dart';
import 'package:chat_messenger/models/story/submodels/seen_by.dart';
import 'package:chat_messenger/models/story/submodels/story_text.dart' as txt;
import 'package:chat_messenger/models/story/submodels/story_image.dart' as img;
import 'package:chat_messenger/models/story/submodels/story_video.dart' as vdo;
import 'package:get/get.dart';
import 'package:story_view/story_view.dart';

class StoryViewController extends GetxController {
  final Story story;

  StoryViewController({required this.story});

  final StoryController storyController = StoryController();
  final List<StoryItem> storyItems = [];
  final List<dynamic> items = [];
  final RxInt index = RxInt(0);

  dynamic get storyItem => items[index.value];
  DateTime get createdAt => items[index.value].createdAt;
  List<SeenBy> get seenByList => items[index.value].seenBy;

  void getStoryItemIndex(int position) {
     index.value = position;
  }

  @override
  void onInit() {
    _loadStoryItems();
    super.onInit();
  }

  @override
  void onClose() {
    storyController.dispose();
    super.onClose();
  }

  // Load all story items
  void _loadStoryItems() {
    // <-- Get story texts -->
    for (final txt.StoryText storyText in story.texts) {
      storyItems.add(
        StoryItem.text(
          title: storyText.text,
          backgroundColor: storyText.bgColor,
          textStyle: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
      items.add(storyText);
    }

    // <-- Get story images -->
    for (final storyImage in story.images) {
      storyItems.add(
        StoryItem.pageImage(
            url: storyImage.imageUrl, controller: storyController),
      );
      items.add(storyImage);
    }

    // <-- Get story videos -->
    for (final storyVideo in story.videos) {
      storyItems.add(
        StoryItem.pageVideo(storyVideo.videoUrl, controller: storyController),
      );
      items.add(storyVideo);
    }
  }

  void markSeen() {
    if (story.isOwner) return;

    // Check current user in the list
    final bool isSeen = seenByList
        .any((e) => e.userId == AuthController.instance.currentUser.userId);

    // Check result
    if (isSeen) {
      debugPrint('markSeen() -> already seen.');
      return;
    }

    StoryApi.markSeen(
      story: story,
      storyItem: storyItem,
      seenByList: seenByList,
    );
  }

  Map<String, dynamic> get reportStoryItemData {
    final Map<String, dynamic> data = storyItem.toMap();
    data.remove('seenBy');

    final String type = switch (storyItem) {
      txt.StoryText _ => 'text',
      img.StoryImage _ => 'image'.tr,
      vdo.StoryVideo _ => 'video'.tr,
      _ => '',
    };

    return {
      'userId': story.userId,
      'type': type,
      ...data,
    };
  }

  void deleteStoryItem() {
    StoryApi.deleteStoryItem(story: story, storyItem: storyItem);
  }
}
