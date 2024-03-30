import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/screens/messages/components/utils/custom_track_shape.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';

import 'package:flutter/material.dart';
import 'package:chat_messenger/screens/messages/controllers/audio_player_controller.dart';
import 'package:get/get.dart';

class AudioMessage extends StatelessWidget {
  const AudioMessage(
    this.message, {
    super.key,
    this.profileUrl,
  });

  final Message message;
  final String? profileUrl;

  @override
  Widget build(BuildContext context) {
    // Put Audio Controller for each item by tag
    Get.put(
      AudioPlayerController(fileUrl: message.fileUrl, isRecording: true),
      tag: message.msgId,
    );

    // Variables
    final String audioName = MediaHelper.getFirebaseFileName(message.fileUrl);
    final bool isRecAudio = message.isRecAudio;

    return Obx(() {
      // Find Audio Controller for each item by tag
      final AudioPlayerController controller = Get.find(tag: message.msgId);

      final bool isPlaying = controller.isPlaying.value;
      final Duration duration = controller.duration.value;
      final Duration position = controller.position.value;

      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show Audio/Profile Icon
                if (isRecAudio)
                  CachedCircleAvatar(
                    imageUrl: profileUrl ?? '',
                    radius: 24,
                  ),
                if (!isRecAudio)
                  GestureDetector(
                    onTap: () => controller.playAudio(),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFfa6533),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Audio icon
                          const Icon(Icons.headphones, color: Colors.white),
                          // <-- Audio duration -->
                          Text(
                            isPlaying
                                ? MediaHelper.formatDuration(
                                    duration - position)
                                : MediaHelper.formatDuration(duration),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          )
                        ],
                      ),
                    ),
                  ),
                // <--- Play/Pause --->
                GestureDetector(
                  onTap: () => controller.playAudio(),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: message.isSender ? secondaryColor : greyColor,
                    size: 38,
                  ),
                ),
                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    overlayShape: SliderComponentShape.noThumb,
                    trackShape: CustomTrackShape(),
                    trackHeight: 2.5,
                  ),
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Slider(
                        min: 0.0,
                        activeColor:
                            message.isSender ? Colors.white : primaryColor,
                        inactiveColor: message.isSender ? Colors.white54 : null,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          controller.seekAudio(position);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Audio Duration
          Positioned(
            bottom: 0,
            left: 62,
            child: Opacity(
              opacity: 0.5,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Text(
                  isRecAudio
                      ? MediaHelper.formatDuration(
                          isPlaying ? (duration - position) : duration)
                      : audioName,
                  style: TextStyle(
                      fontSize: 13,
                      color: message.isSender ? Colors.white : null),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Microphone icon
          if (message.isRecAudio)
            const Positioned(
              top: 30,
              left: 30,
              child: Icon(Icons.mic, color: Color(0xFFfa6533)),
            )
        ],
      );
    });
  }
}
