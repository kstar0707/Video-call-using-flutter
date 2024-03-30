import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/models/call.dart';

class CallController extends GetxController {
  // Parameter
  final Call call;

  // Constructor
  CallController({required this.call});

  // Vars
  Timer? _timer;
  RxInt seconds = RxInt(0);
  Rxn<int> remoteUid = Rxn();
  RxBool isLocalUserJoined = RxBool(false);
  RxBool speaker = RxBool(true);
  RxBool mute = RxBool(false);
  RxBool switchCamera = RxBool(false);
  // Agora SDK engine
  late RtcEngine engine;

  @override
  void onInit() {
    _initAgora();
    super.onInit();
  }

  @override
  void onClose() {
    engine.release();
    _timer = null;
    _stopRingtone();
    super.onClose();
  }

  Future<void> _initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
    // Play the ringtone sound ASAP.
    _playRingtone();

    //create the engine
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: AppConfig.agoraAppID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // debugPrint("local user ${connection.localUid} joined");
          isLocalUserJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          // debugPrint("remote user $uid joined");
          remoteUid.value = uid;
          _startTimer();
          _stopRingtone();
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          // debugPrint("remote user $uid left channel");
          remoteUid.value = null;
          seconds.value = 0;
          _timer?.cancel();
          // Close the call page
          Future(() => Get.back());
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          // debugPrint(
          //     '[onTokenPrivilegeWillExpire] conn:${connection.toJson()}, token: $token');
        },
      ),
    );

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    // Check the call type
    if (call.isVideo) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.enableAudio();
    }
    await engine.joinChannel(
      token: AppConfig.agoraToken,
      channelId: call.callerId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  // Toggle phone speaker
  void onToggleSpeaker() {
    final bool newValue = speaker.value = !speaker.value;
    engine.setEnableSpeakerphone(newValue);
  }

  // Toggle mute
  void onToggleMute() {
    final bool newValue = mute.value = !mute.value;
    engine.muteLocalAudioStream(newValue);
  }

  // Switch Camera -> front/rear
  void onSwitchCamera() {
    switchCamera.value = !switchCamera.value;
    engine.switchCamera();
  }

  // Count the call duration
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => seconds.value++);
  }

  // End the call and pass the value
  void onEndCall() {
    Get.back(result: remoteUid.value);
  }

  // Play Ringtone for outgoing call
  Future<void> _playRingtone() async {
    if (call.isCaller) {
      await FlutterRingtonePlayer().play(
        fromAsset: 'assets/sounds/phone-calling.mp3',
        looping: true, // Android only - API >= 28
        volume: 1.0, // Android only - API >= 28
      );
      // debugPrint('Ringtone played!');
    }
  }

  Future<void> _stopRingtone() async {
    if (call.isCaller) {
      await FlutterRingtonePlayer().stop();
      // debugPrint('Ringtone stopped!');
    }
  }
}
