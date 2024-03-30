import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/floating_button.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:get/get.dart';

import 'components/story_card.dart';
import 'controller/story_controller.dart';

class StoriesScreen extends GetView<StoryController> {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: BuildStories(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Upload text story button
          SizedBox(
            width: 45,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.all(8),
                foregroundColor: primaryColor,
                backgroundColor: primaryColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Get.toNamed(AppRoutes.writeStory),
              child: const Icon(IconlyLight.edit),
            ),
          ),
          const SizedBox(height: 16),
          // Upload file story button
          FloatingButton(
            icon: IconlyBold.camera,
            onPress: () => controller.uploadFileStory(),
          ),
        ],
      ),
    );
  }
}

class BuildStories extends GetView<StoryController> {
  const BuildStories({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // Check loading status
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        } else if (controller.stories.isEmpty) {
          return NoData(
            iconData: IconlyBold.video,
            text: 'no_stories'.tr,
          );
        }

        return GridView.builder(
          itemCount: controller.stories.length,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 250 / 350,
          ),
          itemBuilder: (_, index) => StoryCard(controller.stories[index]),
        );
      },
    );
  }
}
