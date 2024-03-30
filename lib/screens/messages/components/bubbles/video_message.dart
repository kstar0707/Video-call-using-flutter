import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/media/view_media_screen.dart';
import 'package:get/get.dart';

class VideoMessage extends StatelessWidget {
  const VideoMessage(this.message, {super.key});

  // Params
  final Message message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
          () => ViewMediaScreen(fileUrl: message.fileUrl, isVideo: true)),
      child: Container(
        padding: const EdgeInsets.only(bottom: 15),
        width: MediaQuery.of(context).size.width * 0.55,
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedCardImage(
                  message.videoThumbnail,
                ),
              ),
              // Play icon
              const Center(
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: primaryColor,
                  child: Icon(
                    Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
