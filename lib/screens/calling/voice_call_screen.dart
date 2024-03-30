import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/models/call.dart';
import 'package:chat_messenger/config/theme_config.dart';

import 'components/call_timer.dart';
import '../../components/circle_button.dart';
import 'components/join_call_indicator.dart';
import 'controller/call_controller.dart';

class VoiceCallScreen extends StatelessWidget {
  const VoiceCallScreen({super.key, required this.call});

  final Call call;

  @override
  Widget build(BuildContext context) {
    // Get call controller
    final CallController controller = Get.put(CallController(call: call));

    return Obx(() {
      // Get obx vars
      final int? remoteUid = controller.remoteUid.value;
      final String photoUrl =
          call.isCaller ? call.receiverPhotoUrl : call.callerPhotoUrl;

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          onBackPress: () => controller.onEndCall(),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with blur
            if (photoUrl.isNotEmpty) CachedCardImage(photoUrl),
            // Apply a blur effect to the background image
            if (photoUrl.isNotEmpty)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            if (photoUrl.isEmpty)
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            // Content container
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                  vertical: defaultPadding * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Profile avatar
                    CachedCircleAvatar(
                      iconSize: 70,
                      imageUrl: photoUrl,
                      radius: 75,
                    ),
                    const SizedBox(height: 16),
                    // Show call duration
                    remoteUid != null
                        ? const CallTimer()
                        : JoinCallIndicator(call),

                    const Spacer(),

                    // <-- Call Actions -->
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleButton(
                          color: photoUrl.isEmpty ? greyColor : primaryColor,
                          icon: Icon(
                            controller.speaker.value
                                ? IconlyBold.volumeUp
                                : IconlyBold.volumeOff,
                            color: Colors.white,
                          ),
                          onPress: () => controller.onToggleSpeaker(),
                        ),
                        const SizedBox(width: 30),
                        CircleButton(
                          color: photoUrl.isEmpty ? greyColor : primaryColor,
                          icon: Icon(
                            controller.mute.value
                                ? Icons.mic_off
                                : IconlyBold.voice,
                            color: Colors.white,
                          ),
                          onPress: () => controller.onToggleMute(),
                        ),
                        const SizedBox(width: 30),
                        CircleButton(
                          color: Colors.redAccent,
                          icon: const Icon(
                            IconlyBold.callMissed,
                            color: Colors.white,
                          ),
                          onPress: () => controller.onEndCall(),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
