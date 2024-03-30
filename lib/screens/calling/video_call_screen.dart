import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/call.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/screens/calling/controller/call_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';

import 'components/call_bacground.dart';
import 'components/call_timer.dart';
import '../../components/circle_button.dart';
import 'components/join_call_indicator.dart';
import 'components/local_user_preview.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({
    super.key,
    required this.call,
  });

  final Call call;

  @override
  Widget build(BuildContext context) {
    // Get call controller
    final CallController controller = Get.put(CallController(call: call));

    // Get current user model
    final User currentUser = AuthController.instance.currentUser;

    return Obx(() {
      // Get obx vars
      final int? remoteUid = controller.remoteUid.value;
      final String photoUrl =
          call.isCaller ? call.receiverPhotoUrl : call.callerPhotoUrl;

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          // Show call duration
          title: remoteUid != null ? const CallTimer() : null,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          onBackPress: () => controller.onEndCall(),
        ),
        body: CallBackground(
          remoteUid: remoteUid,
          // <-- REMOTE user video preview  -->
          preview: remoteUid != null
          ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(
                  uid: remoteUid,
                ),
                connection: RtcConnection(channelId: call.callerId),
              ),
            )
          : photoUrl.isEmpty
            ? Container(
                color: Theme.of(context).colorScheme.primaryContainer,
              )
            : CachedCardImage(photoUrl),
          // Other content
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    // <-- LOCAL user video preview  -->
                    Obx(
                      () => LocalUserPreview(
                        child: controller.isLocalUserJoined.value
                            ? AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: controller.engine,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              )
                            : currentUser.photoUrl.isEmpty
                                ? const Icon(IconlyBold.profile,
                                    color: Colors.white, size: 60)
                                : CachedCardImage(currentUser.photoUrl),
                      ),
                    ),

                    // <-- Call actions -->
                    Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Speaker
                          CircleButton(
                            color: primaryColor,
                            icon: Icon(
                              controller.speaker.value
                                  ? IconlyBold.volumeUp
                                  : IconlyBold.volumeOff,
                              color: Colors.white,
                            ),
                            onPress: () => controller.onToggleSpeaker(),
                          ),
                          // Switch camera
                          CircleButton(
                            color: primaryColor,
                            icon: Icon(
                              controller.switchCamera.value
                                  ? IconlyBold.video
                                  : IconlyBold.camera,
                              color: Colors.white,
                            ),
                            onPress: () => controller.onSwitchCamera(),
                          ),
                          // Mute
                          CircleButton(
                            color: primaryColor,
                            icon: Icon(
                              controller.mute.value
                                  ? Icons.mic_off
                                  : IconlyBold.voice,
                              color: Colors.white,
                            ),
                            onPress: () => controller.onToggleMute(),
                          ),
                          // End call
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
                    ),
                  ],
                ),
              ),
              // <-- Call indicator status -->
              if (remoteUid == null)
                Center(
                  child: JoinCallIndicator(
                    call,
                    loadingColor:
                        photoUrl.isEmpty ? Colors.white : primaryColor,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
