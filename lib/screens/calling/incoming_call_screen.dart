import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/call.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/config/theme_config.dart';

import '../../components/circle_button.dart';

class IncommingCallScreen extends StatefulWidget {
  const IncommingCallScreen({super.key, required this.call});

  final Call call;

  @override
  State<IncommingCallScreen> createState() => _IncommingCallScreenState();
}

class _IncommingCallScreenState extends State<IncommingCallScreen> {
  @override
  void initState() {
    // Play Ringtone for incoming call
    FlutterRingtonePlayer().play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.electronic,
      looping: true, // Android only - API >= 28
      volume: 1.0, // Android only - API >= 28
      asAlarm: true, // Android only - all APIs
    );
    super.initState();
  }

  @override
  void dispose() {
    FlutterRingtonePlayer().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String photoUrl = widget.call.callerPhotoUrl;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur
          CachedCardImage(photoUrl),
          // Apply a blur effect to the background image
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

                  Text(
                    widget.call.isVideo
                        ? 'incomming_video_call'.tr
                        : 'incomming_voice_call'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Profile name
                  Text(
                    widget.call.callerName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Message
                      CircleButton(
                        icon: const Icon(
                          IconlyBold.chat,
                          color: Colors.white,
                        ),
                        onPress: () async {
                          // Get caller user
                          final User? user =
                              await UserApi.getUser(widget.call.callerId);

                          // Check user account
                          if (user == null) {
                            DialogHelper.showSnackbarMessage(
                              SnackMsgType.error,
                              'user_account_not_found'.tr,
                            );
                            // Close this page
                            Get.back();
                            return;
                          }

                          // Go to messages page
                          RoutesHelper.toMessages(user: user);
                        },
                      ),
                      const SizedBox(width: 16),

                      SizedBox(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 0,
                          ),
                          onPressed: () {
                            // Check the call type
                            if (widget.call.isVideo) {
                              // Go to video call page
                              Get.offNamed(AppRoutes.videoCall, arguments: {
                                'call': widget.call,
                              });
                            } else {
                              // Go to voice call page
                              Get.offNamed(AppRoutes.voiceCall, arguments: {
                                'call': widget.call,
                              });
                            }
                          },
                          child: Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: greyColor,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  IconlyBold.call,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'answer_call'.tr,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // End call
                      CircleButton(
                        icon: const Icon(
                          IconlyBold.callMissed,
                          color: Colors.redAccent,
                        ),
                        onPress: () => Get.back(),
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
  }
}
