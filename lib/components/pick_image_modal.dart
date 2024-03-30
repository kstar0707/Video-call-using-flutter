import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:chat_messenger/config/theme_config.dart';

class PickImageModal extends StatelessWidget {
  const PickImageModal({super.key, required this.isAvatar});

  final bool isAvatar;

  // Handle picked image
  Future<File?> _pickAndCropImage(ImageSource source) async {
    final XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      // Crop the image
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 640,
        maxHeight: 960,
        compressQuality: 100,
        aspectRatioPresets: [
          isAvatar
              ? CropAspectRatioPreset.square
              : CropAspectRatioPreset.original,
        ],
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

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(defaultRadius),
          topRight: Radius.circular(defaultRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'photo'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: greyColor),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(IconlyLight.image),
            title: Text('gallery'.tr),
            onTap: () async {
              File? croppedImage = await _pickAndCropImage(ImageSource.gallery);
              Get.back(result: croppedImage);
            },
          ),
          ListTile(
            leading: const Icon(IconlyLight.camera),
            title: Text('camera'.tr),
            onTap: () async {
              File? croppedImage = await _pickAndCropImage(ImageSource.camera);
              Get.back(result: croppedImage);
            },
          ),
        ],
      ),
    );
  }
}
