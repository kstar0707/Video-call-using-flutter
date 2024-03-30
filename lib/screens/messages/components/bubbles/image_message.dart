import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/media/view_media_screen.dart';
import 'package:get/get.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage(this.message, {super.key});

  // Params
  final Message message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ViewMediaScreen(fileUrl: message.fileUrl)),
      child: Container(
        padding: const EdgeInsets.only(bottom: 15),
        width: MediaQuery.of(context).size.width * 0.55,
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedCardImage(
              message.fileUrl,
            ),
          ),
        ),
      ),
    );
  }
}
