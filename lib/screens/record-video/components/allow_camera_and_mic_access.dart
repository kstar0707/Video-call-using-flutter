import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/screens/record-video/controller/record_video_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';

class AllowCameraAndMicAccess extends GetView<RecordVideoController> {
  const AllowCameraAndMicAccess({super.key});

  @override
  Widget build(BuildContext context) {
    final errorStyle =
        Theme.of(context).textTheme.bodyMedium!.copyWith(color: errorColor);

    return Material(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: 50,
        ),
        child: Stack(
          children: [
            // Body
            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "allow_camera_and_microphone_permissions_to_create_your_profile_video"
                        .tr,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Allow camera access
                  if (!controller.hasCameraAccess.value)
                    SizedBox(
                      height: 45,
                      width: double.maxFinite,
                      child: ElevatedButton.icon(
                        onPressed: controller.isCameraDeniedForever.value
                            ? () => controller.openSettings(isCamera: true)
                            : () => controller.requestCameraPermission(),
                        icon: const Icon(IconlyLight.camera),
                        label: Text(
                          controller.isCameraDeniedForever.value
                              ? 'open_settings'.tr
                              : 'allow_camera_access'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  if (controller.isCameraDeniedForever.value)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'camera_access_is_permanently_denied'.tr,
                        style: errorStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Allow microphone access
                  if (!controller.hasMicrophoneAccess.value)
                    SizedBox(
                      height: 45,
                      width: double.maxFinite,
                      child: ElevatedButton.icon(
                        onPressed: controller.isMicDeniedForever.value
                            ? () => controller.openSettings(isCamera: false)
                            : () => controller.requestMicPermission(),
                        icon: const Icon(IconlyLight.voice),
                        label: Text(
                          controller.isMicDeniedForever.value
                              ? 'open_settings'.tr
                              : 'allow_microphone_access'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  if (controller.isMicDeniedForever.value)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'microphone_access_is_permanently_denied'.tr,
                        style: errorStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
