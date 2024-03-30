import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:video_editor/video_editor.dart';

class CoverSelectionTab extends StatelessWidget {
  const CoverSelectionTab(this.controller, {super.key});

  // Params
  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: controller,
            size: 70,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
