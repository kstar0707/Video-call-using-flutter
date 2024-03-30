import 'package:flutter/material.dart';
import 'package:chat_messenger/components/circle_button.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:chat_messenger/screens/messages/components/utils/custom_track_shape.dart';
import 'package:chat_messenger/screens/messages/controllers/audio_player_controller.dart';
import 'package:get/get.dart';

class RecordingPlayback extends StatelessWidget {
  const RecordingPlayback({super.key, required this.fileUrl});

  final String fileUrl;

  @override
  Widget build(BuildContext context) {
    // Init Audio Player Controller with unique tag
    final AudioPlayerController controller = Get.put(
      AudioPlayerController(fileUrl: fileUrl),
      tag: 'recording_playback',
    );

    return Obx(() {
      final bool isPlaying = controller.isPlaying.value;
      final Duration duration = controller.duration.value;
      final Duration position = controller.position.value;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(defaultRadius * 2),
        ),
        child: Row(
          children: [
            CircleButton(
              size: 30,
              onPress: () => controller.playAudio(),
              icon: Icon(
                controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                color: secondaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            // Play Progress
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
            const SizedBox(width: 8),
            Text(
              MediaHelper.formatDuration(
                  isPlaying ? (duration - position) : duration),
            ),
          ],
        ),
      );
    });
  }
}
