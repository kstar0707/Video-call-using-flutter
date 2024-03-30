import 'dart:io';

import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class DocPreview extends StatelessWidget {
  const DocPreview({
    super.key,
    required this.file,
    this.cardSize = const Size(100, 100),
  });

  // Params
  final File file;
  final Size cardSize;

  // Get icon preview
  Widget getImgIcon(String icon) {
    return Image.asset(
      'assets/icons/extensions/$icon',
      fit: BoxFit.cover,
      width: double.maxFinite,
      height: double.maxFinite,
    );
  }

  Widget getExtName(String ext) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        ext.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Init
    Widget icon = const SizedBox.shrink();
    // Get file info
    final String ext = path.extension(file.path).replaceAll('.', '');
    final String fileName = path.basename(file.path);
    bool isDefaultExt = false;

    // Handle common types
    if (MediaHelper.isImage(file.path)) {
      icon = Image.file(
        file,
        fit: BoxFit.cover,
        width: cardSize.width,
        height: cardSize.height,
      );
    } else if (MediaHelper.isVideo(file.path)) {
      // Video
      icon = getImgIcon('video_preview.png');
    } else if (MediaHelper.isAudio(file.path)) {
      // Audio
      icon = getImgIcon('audio_preview.png');
    } else if (MediaHelper.isPDF(file.path)) {
      // PDF
      icon = getImgIcon('pdf.png');
    } else if (MediaHelper.isExcel(file.path)) {
      // Exel
      icon = getImgIcon('xls.png');
    } else if (MediaHelper.isDoc(file.path)) {
      // DOC
      icon = getImgIcon('doc.png');
    } else {
      // Update the value
      isDefaultExt = true;

      // Show file preview with its extension
      icon = Stack(
        children: [
          // Show default icon
          Align(
            alignment: Alignment.center,
            child: getImgIcon('default.png'),
          ),
          // Show ext name
          Align(child: getExtName(ext)),
        ],
      );
    }

    return Container(
      width: cardSize.width,
      height: cardSize.height,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // <--- File Preview Icon --->
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                // Icon
                icon,
                // Show ext name
                if (!isDefaultExt) Align(child: getExtName(ext)),
              ],
            ),
          ),
          // File name
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Wrap(
                children: [
                  Text(
                    fileName,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
