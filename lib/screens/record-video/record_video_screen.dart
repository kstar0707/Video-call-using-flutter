import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/screens/record-video/controller/record_video_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'components/allow_camera_and_mic_access.dart';
import 'components/camera_actions.dart';
import 'components/camera_display.dart';

class RecordVideoScreen extends StatelessWidget {
  const RecordVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RecordVideoController controller = Get.put(RecordVideoController());

    return Material(
      color: Colors.black,
      child: Obx(() {
        final bool isCameraInitialized = controller.isCameraInitialized.value;

        return Stack(
          children: [
            // Camera Preview
            if (controller.permissionsGranted && isCameraInitialized)
              CameraDisplay(controller.cameraController),
            // AppBar
            _buildAppBar(controller),

            // Camera actions
            const CameraActions(),

            // Check permissions
            if (!controller.permissionsGranted) const AllowCameraAndMicAccess(),

            // Close button
            if (!controller.permissionsGranted)
              Positioned(
                top: 23,
                left: 3,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(RecordVideoController controller) {
    return AppBar(
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: controller.isRecording.value ? Colors.red : Colors.black26,
            borderRadius: BorderRadius.circular(defaultPadding)),
        child: Text(
          // <--- Show recording timer --->
          controller.isRecording.value ? controller.formatDuration() : '00:00',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.close),
      ),
      actions: [
        IconButton(
          onPressed: controller.toggleFlash,
          icon: Icon(
              controller.isFlashOn.value ? Icons.flash_on : Icons.flash_off,
              color: Colors.white),
        ),
      ],
    );
  }
}
