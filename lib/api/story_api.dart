import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:chat_messenger/models/story/story.dart';
import 'package:chat_messenger/models/story/submodels/seen_by.dart';
import 'package:chat_messenger/models/story/submodels/story_image.dart';
import 'package:chat_messenger/models/story/submodels/story_text.dart';
import 'package:chat_messenger/models/story/submodels/story_video.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

abstract class StoryApi {
  //
  // StoryApi - CRUD Operations
  //

  // Stories collection reference
  static final CollectionReference<Map<String, dynamic>> storiesRef =
      FirebaseFirestore.instance.collection('Stories');
  
  // Get contacts story
  static Stream<List<Story>> getStories(List<User> contacts) {
    final List<Stream<List<Story>>> stories = [];
    stories.add(_getUserStory(AuthController.instance.currentUser));
    for (final contact in contacts) {
      stories.add(_getUserStory(contact));
    }
    return CombineLatestStream(stories, (values) {
      return values.expand((list) => list).toList()
        ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    });
  }

  static Stream<List<Story>> _getUserStory(User user) {
    return storiesRef
        .where('userId', isEqualTo: user.userId)
        .snapshots()
        .map((event) {
      return event.docs
          .map((e) => Story.fromMap(user: user, data: e.data()))
          .toList();
    });
  }

  // Create text story
  static Future<void> uploadTextStory({
    required String text,
    required Color bgColor,
  }) async {
    try {
      final User currentUser = AuthController.instance.currentUser;

      // Check story doc
      final storyDoc = await storiesRef.doc(currentUser.userId).get();

      // New Story Text
      final StoryText storyText = StoryText(
        text: text,
        bgColor: bgColor,
        createdAt: DateTime.now(),
      );

      // Check result
      if (storyDoc.exists) {
        final oldTexts = List<Map<String, dynamic>>.from(storyDoc['texts']);

        // Update existing story
        await storyDoc.reference.update(Story.toUpdateMap(
          type: StoryType.text,
          values: [...oldTexts, storyText.toMap()],
        ));
      } else {
        // Create new story
        final Story story = Story(
          type: StoryType.text,
          texts: [storyText],
          updatedAt: null,
        );
        await storyDoc.reference.set(story.toMap());
      }
      // Close the page
      Get.back();
      // Show message
      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, 'story_created_successfully'.tr);
    } catch (e) {
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  // Create image story
  static Future<void> uploadImageStory(File imageFile) async {
    try {
      final User currentUser = AuthController.instance.currentUser;

      DialogHelper.showProcessingDialog(
          title: 'uploading'.tr, barrierDismissible: false);

      // Check story doc
      final storyDoc = await storiesRef.doc(currentUser.userId).get();

      final String imageUrl =
          await AppHelper.uploadFile(file: imageFile, userId: currentUser.userId);

      // New Story Image
      final StoryImage storyImage =
          StoryImage(imageUrl: imageUrl, createdAt: DateTime.now());

      // Check result
      if (storyDoc.exists) {
        final oldImages = List<Map<String, dynamic>>.from(storyDoc['images']);

        // Update existing story
        await storyDoc.reference.update(Story.toUpdateMap(
          type: StoryType.image,
          values: [...oldImages, storyImage.toMap()],
        ));
      } else {
        // Create new story
        final Story story = Story(
          type: StoryType.image,
          images: [storyImage],
          updatedAt: null,
        );
        await storyDoc.reference.set(story.toMap());
      }
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, 'story_created_successfully'.tr);
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  // Create video story
  static Future<void> uploadVideoStory(File videoFile) async {
    try {
      final User currentUser = AuthController.instance.currentUser;

      DialogHelper.showProcessingDialog(
          title: 'uploading'.tr, barrierDismissible: false);

      // Check story doc
      final storyDoc = await storiesRef.doc(currentUser.userId).get();

      // <-- Upload video & thumbnail -->
      final String videoUrl =
          await AppHelper.uploadFile(file: videoFile, userId: currentUser.userId);
      final File thumbFile =
          await MediaHelper.getVideoThumbnail(videoFile.path);
      final String thumbnailUrl =
          await AppHelper.uploadFile(file: thumbFile, userId: currentUser.userId);

      // New Story video
      final StoryVideo storyVideo = StoryVideo(
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        createdAt: DateTime.now(),
      );

      // Check result
      if (storyDoc.exists) {
        final oldVideos = List<Map<String, dynamic>>.from(storyDoc['videos']);

        // Update existing story
        await storyDoc.reference.update(Story.toUpdateMap(
          type: StoryType.video,
          values: [...oldVideos, storyVideo.toMap()],
        ));
      } else {
        // Create new story
        final Story story = Story(
          type: StoryType.video,
          videos: [storyVideo],
          updatedAt: null,
        );
        await storyDoc.reference.set(story.toMap());
      }
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(
          SnackMsgType.success, 'story_created_successfully'.tr);
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  static Future<void> markSeen({
    required Story story,
    required dynamic storyItem,
    required List<SeenBy> seenByList,
  }) async {
    try {
      final User currentUser = AuthController.instance.currentUser;

      // New seen by
      final SeenBy newSeenBy = SeenBy(
        userId: currentUser.userId,
        fullname: currentUser.fullname,
        photoUrl: currentUser.photoUrl,
        time: DateTime.now(),
      );

      // New seen by list
      final List<SeenBy> newSeenByList = [...seenByList, newSeenBy];

      switch (storyItem) {
        case StoryText _:
          // Update story item
          final List<StoryText> texts = story.texts.map((e) {
            if (e == storyItem) {
              e.seenBy = newSeenByList;
            }
            return e;
          }).toList();

          await storiesRef.doc(story.id).update({
            'texts': texts.map((e) => e.toMap()).toList(),
          });
          break;
        case StoryImage _:
          // Update story item
          final List<StoryImage> images = story.images.map((e) {
            if (e == storyItem) {
              e.seenBy = newSeenByList;
            }
            return e;
          }).toList();

          await storiesRef.doc(story.id).update({
            'images': images.map((e) => e.toMap()).toList(),
          });
          break;
        case StoryVideo _:
          // Update story item
          final List<StoryVideo> videos = story.videos.map((e) {
            if (e == storyItem) {
              e.seenBy = newSeenByList;
            }
            return e;
          }).toList();

          await storiesRef.doc(story.id).update({
            'videos': videos.map((e) => e.toMap()).toList(),
          });
          break;
      }
      debugPrint('markSeen() -> success');
    } catch (e) {
      debugPrint('markSeen() -> error: $e');
    }
  }

  static Future<void> _updateStoryData({
    required Story story,
    required Map<Object, Object?> data,
  }) async {
    final int totalItems =
        (story.texts.length + story.images.length + story.videos.length);

    if (totalItems == 0) {
      await storiesRef.doc(story.id).delete();
    } else {
      await storiesRef.doc(story.id).update(data);
    }
  }

  static Future<void> deleteStoryItem({
    required Story story,
    required dynamic storyItem,
  }) async {
    try {
      void success() {
        DialogHelper.showSnackbarMessage(
            SnackMsgType.success, 'story_deleted_successfully'.tr);
      }

      switch (storyItem) {
        case StoryText _:
          final List<StoryText> texts = story.texts;
          texts.remove(storyItem);

          await _updateStoryData(story: story, data: {
            'texts': texts.map((e) => e.toMap()).toList(),
          });

          success();
          debugPrint('deleteStoryItem -> text: deleted');
          break;

        case StoryImage _:
          final List<StoryImage> images = story.images;

          // Delete image file
          AppHelper.deleteFile(storyItem.imageUrl);

          images.remove(storyItem);

          // Update story data
          await _updateStoryData(story: story, data: {
            'images': images.map((e) => e.toMap()).toList(),
          });

          success();
          debugPrint('deleteStoryItem -> image: deleted');
          break;

        case StoryVideo _:
          final List<StoryVideo> videos = story.videos;

          // Delete video & thumbnail files
          Future.wait([
            AppHelper.deleteFile(storyItem.videoUrl),
            AppHelper.deleteFile(storyItem.thumbnailUrl),
          ]);

          videos.remove(storyItem);

          // Update story data
          await _updateStoryData(story: story, data: {
            'videos': videos.map((e) => e.toMap()).toList(),
          });

          success();
          debugPrint('deleteStoryItem -> video: deleted');
          break;
      }
    } catch (e) {
      debugPrint('deleteStoryItem() -> error: $e');
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
    }
  }

  static Future<void> viewStories(List<Story> stories) async {
    try {
      final User currentUser = AuthController.instance.currentUser;
      
      final List<Future<void>> futures = stories.map((story) {
        return storiesRef.doc(story.id).update({
          'viewers': FieldValue.arrayUnion([currentUser.userId]),
        });
      }).toList();
      await Future.wait(futures);
      debugPrint('viewStories() -> success');
    } catch (e) {
      debugPrint('viewStories() -> error: $e');
    }
  }
}
