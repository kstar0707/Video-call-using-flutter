import 'package:flutter/material.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/screens/messages/controllers/audio_player_controller.dart';
import 'package:get/get.dart';

import 'audio_recorder_controller.dart';
import 'components/recording_playback.dart';

class AudioRecorderModal extends StatefulWidget {
  const AudioRecorderModal(this.receiverId, {super.key});

  final String? receiverId;

  @override
  State<AudioRecorderModal> createState() => _AudioRecorderModalState();
}

class _AudioRecorderModalState extends State<AudioRecorderModal> {
  @override
  void dispose() {
    // Free up the controller resources.
    Get.delete<AudioRecorderController>(force: true);
    Get.delete<AudioPlayerController>(tag: 'recording_playback', force: true);
    if (widget.receiverId != null &&
        AuthController.instance.currentUser.isRecording) {
      UserApi.updateUserRecordingStatus(false, widget.receiverId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Init Audio Recorder Controller
    final AudioRecorderController controller = Get.put(
      AudioRecorderController(widget.receiverId),
    );

    return Obx(() {
      final bool isRecording = controller.isRecording.value;

      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(defaultRadius),
            topRight: Radius.circular(defaultRadius),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Show Recording Controls
            if (!controller.isPaused.value)
              _buildRecordingControls(context, controller),
            // 2. Playback Controls
            if (controller.isPaused.value)
              RecordingPlayback(fileUrl: controller.audioPath.value),
            //
            const SizedBox(height: 8),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delete Recorded Audio
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.delete, color: Colors.grey, size: 32),
                ),
                // Pause/Resume Recording
                IconButton(
                  onPressed: () {
                    if (isRecording) {
                      controller.pauseRecording();
                    } else {
                      controller.startRecording();
                    }
                  },
                  icon: Icon(
                    isRecording ? Icons.pause_circle_outline : Icons.mic,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                // Send Audio
                IconButton(
                  onPressed: () => controller.sendAudio(),
                  padding: EdgeInsets.zero,
                  icon: const CircleAvatar(
                    radius: 25,
                    backgroundColor: primaryColor,
                    child: SvgIcon(
                      'assets/icons/send.svg',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildRecordingControls(
      BuildContext context, AudioRecorderController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.formattedRecordingDuration,
          style:
              Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 30),
        ),
      ],
    );
  }
}
