import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_messenger/screens/record-video/controller/record_video_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';

import 'camera_action_button.dart';

class CameraActions extends StatelessWidget {
  const CameraActions({super.key});

  @override
  Widget build(BuildContext context) {
    final RecordVideoController controller = Get.find();

    return Obx(
      () {
        // Vars
        final bool isRecording = controller.isRecording.value;

        return Positioned(
          bottom: 100,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                // Other actions
                Row(
                  mainAxisAlignment: isRecording
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    // Upload video from gallery
                    if (!isRecording)
                      CameraActionButton(
                        icon: const Icon(IconlyBold.image, color: Colors.white),
                        onTap: () async {
                          // Pick a video from gallery.
                          final XFile? galleryVideo = await ImagePicker()
                              .pickVideo(source: ImageSource.gallery);

                          // Check the file
                          if (galleryVideo != null) {
                            // Open Video Editor
                            controller.openVideoEditor(File(galleryVideo.path));
                          }
                        },
                      ),

                    // <--- Record video button --->
                    CameraActionButton(
                      onTap: () async {
                        // Check status
                        if (isRecording) {
                          // Stop video recording
                          controller.stopVideoRecording();
                        } else {
                          // Start video recording
                          controller.startVideoRecording();
                        }
                      },
                      padding: 0,
                      color: isRecording ? Colors.red : Colors.white,
                      icon: Stack(
                        children: [
                          Icon(
                            isRecording
                                ? Icons.stop_circle_outlined
                                : Icons.radio_button_on,
                            color: isRecording ? Colors.red : Colors.white,
                            size: 80,
                          ),
                          Offstage(
                            offstage: !isRecording,
                            child: const Icon(Icons.radio_button_off,
                                size: 80, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Switch camera
                    if (!isRecording)
                      CameraActionButton(
                        onTap: () => controller.switchCamera(),
                        icon: RotatedBox(
                          quarterTurns: controller.selectedCamera.value,
                          child: const Icon(
                            IconlyBold.camera,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
