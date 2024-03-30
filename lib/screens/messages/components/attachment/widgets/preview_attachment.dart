import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';

import 'doc_preview.dart';

class PreviewAttachment extends StatelessWidget {
  const PreviewAttachment({
    super.key,
    required this.file,
    required this.onDelete,
  });

  // Params
  final File file;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Show preview icon
        DocPreview(file: file),
        // Remove attachment
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.cancel, color: errorColor),
          ),
        ),
      ],
    );
  }
}
