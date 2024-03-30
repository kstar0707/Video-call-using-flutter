import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/story/story.dart';
import 'package:chat_messenger/models/story/submodels/story_image.dart';
import 'package:chat_messenger/models/story/submodels/story_text.dart';
import 'package:chat_messenger/models/story/submodels/story_video.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:get/get.dart';

class StoryCard extends StatelessWidget {
  const StoryCard(
    this.story, {
    super.key,
  });

  final Story story;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    final int total =
        (story.texts.length + story.images.length + story.videos.length);

    switch (story.type) {
      case StoryType.text:
        final StoryText storyText = story.texts.last;

        child = Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(defaultPadding / 2),
          color: storyText.bgColor,
          child: Text(
            storyText.text,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
        break;

      case StoryType.image:
        final StoryImage storyImage = story.images.last;
        child = CachedCardImage(storyImage.imageUrl);
        break;

      case StoryType.video:
        final StoryVideo storyVideo = story.videos.last;
        child = CachedCardImage(storyVideo.thumbnailUrl);
        break;
    }

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.storyView, arguments: {'story': story}),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Card content
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: child,
          ),
          // Add bottom background
          const BottomBackground(),
          // Profile photo
          Positioned(
            left: 10,
            top: 10,
            child: CachedCircleAvatar(
              radius: 25,
              borderColor: primaryColor,
              imageUrl: story.user!.photoUrl,
            ),
          ),
          // Profile name
          Positioned(
            left: 0,
            bottom: 6,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 150,
                child: Text(
                  story.user!.fullname,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Total Stories
          Positioned(
            top: 10,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    total.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (story.type == StoryType.video)
            const Center(
              child: Icon(
                IconlyLight.play,
                color: Colors.white,
                size: 60,
              ),
            ),
        ],
      ),
    );
  }
}

class BottomBackground extends StatelessWidget {
  const BottomBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultRadius),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
