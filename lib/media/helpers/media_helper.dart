import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/plugins/video-editor/screens/video_editor_screen.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:file_picker/file_picker.dart';

import '../camera/camera_screen.dart';
import 'components/picker_theme.dart';

abstract class MediaHelper {
  ///
  /// Media Helper APIs
  ///
  static final BuildContext context = Get.context!;

  // Get asset from device storage
  static Future<File?> pickMediaFromGallery({
    required RequestType type,
  }) async {
    // Variables
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          gridCount: 4,
          pageSize: 60,
          requestType: type,
          themeColor: isDarkMode ? primaryColor : null,
          textDelegate: const EnglishAssetPickerTextDelegate(),
          pickerTheme: isDarkMode ? null : pickerTheme,
        ),
      );

      // Hold picked file
      File? pickedFile;

      // Check result
      if (result != null) {
        // Get AssetEntity
        final AssetEntity asset = result.first;
        pickedFile = await asset.file;
      }

      return pickedFile;
    } catch (e) {
      debugPrint('pickMediaFromGallery -> error: $e');
    }

    return null;
  }

  /// Pick image file from gallery
  static Future<File?> pickImage() async {
    final File? pickedImage = await MediaHelper.pickMediaFromGallery(
      type: RequestType.image,
    );
    // Edit the image
    return await MediaHelper.openImageOrVideoEditor(pickedImage);
  }

  /// Pick video file from gallery
  static Future<File?> pickVideo() async {
    final File? pickedVideo = await MediaHelper.pickMediaFromGallery(
      type: RequestType.video,
    );
    // Edit the video
    return await MediaHelper.openImageOrVideoEditor(pickedVideo);
  }

  /// Pick documents files
  static Future<List<File>?> pickDocFiles({
    bool isMultiple = false,
    FileType type = FileType.any,
  }) async {
    // Get file from device
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: isMultiple,
      allowedExtensions: null,
    );

    if (result != null) {
      // Get files list
      return result.files.map((el) => File(el.path!)).toList();
    }
    return [];
  }

  static Future<File?> openCameraScreen(BuildContext context) async {
    // <-- Open Camera Picker -->
    final File? file = await Get.to<File?>(() => const CameraScreen());

    return openImageOrVideoEditor(file);
  }

  static Future<File?> openImageOrVideoEditor(File? file) async {
    if (file == null) return null;

    // Check file type
    if (isImage(file.path)) {
      // Crop the image
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        maxWidth: 1280,
        maxHeight: 1080,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'crop_image'.tr,
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'crop_image'.tr),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    }

    if (isVideo(file.path)) {
      // Open Video Editor
      final File? editedVideo = await Get.to<File?>(
        () => VideoEditorScreen(file: file),
      );
      return editedVideo;
    }

    return null;
  }

  static Future<String?> getGif(BuildContext context) async {
    final GiphyGif? gif = await GiphyGet.getGif(
      context: context,
      apiKey: AppConfig.gifAPiKey,
      tabColor: primaryColor,
      textSelectedColor: primaryColor,
    );

    // Get GIF url
    final String? gifUrl = gif?.images?.original?.url;

    if (gifUrl == null) return null;

    return gifUrl.split('?').first;
  }

  static Future<File> getVideoThumbnail(
    String videoPath, {
    int quality = 50,
    int maxHeight = 400,
  }) async {
    final String? thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      quality: quality,
      maxHeight: maxHeight,
      imageFormat: ImageFormat.JPEG,
    );
    return File(thumbPath!);
  }

  /// Get "file name" stored in firebase storage
  static String getFirebaseFileName(String? fileUrl) {
    if (fileUrl == null) return "";
    final Uri uri = Uri.parse(fileUrl);
    final String fileName = uri.pathSegments.last.split('/').last;
    return fileName;
  }

  /// Get formatted duration with two digits: (min:sec)
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  ///
  ///  File Extension Methods
  ///

  // Check image file
  static bool isImage(String path) {
    return _getMimeType(path).contains('image');
  }

  // Check video file
  static bool isVideo(String path) {
    return _getMimeType(path).contains('video');
  }

  // Check audio file
  static bool isAudio(String path) {
    return _getMimeType(path).contains('audio');
  }

  // Check PDF file
  static bool isPDF(String path) {
    return _getMimeType(path).contains('pdf');
  }

  // Check Excel file
  static bool isExcel(String path) {
    return _getMimeType(path).contains('excel');
  }

  // Check Doc file
  static bool isDoc(String path) {
    return _getMimeType(path).contains('doc');
  }

  // Get file mime type
  static String _getMimeType(String path) {
    return lookupMimeType(path)?.toLowerCase() ?? '';
  }
}
