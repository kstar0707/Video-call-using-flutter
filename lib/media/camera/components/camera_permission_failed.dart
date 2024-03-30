import 'package:flutter/material.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CameraPermissionFailed extends StatelessWidget {
  const CameraPermissionFailed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera permission'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              const SvgIcon(
                'assets/icons/camera.svg',
                color: primaryColor,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 8),
              // Description
              const Text(
                'Failed! please accept all permissions to use the camera.',
                style: TextStyle(color: errorColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => PhotoManager.openSetting(),
                child: const Text('Allow camera permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
