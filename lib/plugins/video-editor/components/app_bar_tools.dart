import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:video_editor/video_editor.dart';

import '../screens/crop_screen.dart';

class AppBarTools extends StatelessWidget {
  const AppBarTools(
    this.controller, {
    super.key,
    required this.exportVideo,
    required this.isExporting,
  });

  // Params
  final VideoEditorController controller;
  final VoidCallback exportVideo;
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: primaryColor,
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed:
                    isExporting ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: isExporting
                    ? null
                    : () => controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left, color: Colors.white),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: isExporting
                    ? null
                    : () => controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right, color: Colors.white),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: isExporting
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                CropScreen(controller: controller),
                          ),
                        ),
                icon: const Icon(Icons.crop, color: Colors.white),
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: isExporting
                    ? null
                    : () {
                        // Execute export
                        exportVideo();
                        // Play the video while exporting it.
                        controller.video.play();
                      },
                icon: const Icon(Icons.check, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
