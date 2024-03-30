import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';

class ProfileVideoTip extends StatelessWidget {
  const ProfileVideoTip({
    super.key,
    required this.title,
    this.onPress,
  });

  final String title;
  final Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: double.maxFinite,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_image.png"),
            fit: BoxFit.cover,
            repeat: ImageRepeat.noRepeat,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(.8),
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: 60,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  "showcase_yourself_interests_and_personality".tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  "create_a_captivating_profile_video_that_introduces_yourself"
                      .tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  height: 45,
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    onPressed: onPress,
                    icon: const Icon(IconlyLight.video),
                    label: Text(
                      'get_started'.tr,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
