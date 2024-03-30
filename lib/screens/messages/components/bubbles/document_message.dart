import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/screens/messages/controllers/message_controller.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class DocumentMessage extends GetView<MessageController> {
  const DocumentMessage({
    super.key,
    required this.message,
  });

  // Params
  final Message message;

  @override
  Widget build(BuildContext context) {
    return docBody;
  }

  Widget get docBody {
    // Init
    Widget icon = const SizedBox.shrink();

    // Handle file info
    String fileName = path.basename(message.fileUrl);

    // Check remote path
    if (message.fileUrl.startsWith('https')) {
      fileName = MediaHelper.getFirebaseFileName(message.fileUrl);
    }
    final String fileExt = fileName.split('.').last;

    // <-- Check known doc types -->
    if (MediaHelper.isPDF(fileName)) {
      // PDF file
      icon = _getImgIcon('pdf.png', fileExt);
    } else if (MediaHelper.isExcel(fileName)) {
      // Exel file
      icon = _getImgIcon('xls.png', fileExt);
    } else if (MediaHelper.isDoc(fileName)) {
      // DOC file
      icon = _getImgIcon('doc.png', fileExt);
    } else {
      // Other doc types and its extension
      icon = _getImgIcon('default.png', fileExt);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon
          docIcon(icon),
          const SizedBox(width: 10),
          // File info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  fileName,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: message.isSender ? Colors.white : null,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget docIcon(Widget icon) {
    // File icon
    return icon;
  }

  // Get icon preview
  Widget _getImgIcon(String icon, String ext) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Icon
        Image.asset(
          'assets/icons/extensions/$icon',
          fit: BoxFit.cover,
          width: 40,
        ),
        // Extension
        Align(
          alignment: Alignment.center,
          child: Text(
            ext.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
