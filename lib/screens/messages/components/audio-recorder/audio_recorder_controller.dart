import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/screens/messages/controllers/audio_player_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderController extends GetxController {
  final String? receiverId;

  AudioRecorderController(this.receiverId);

  late FlutterSoundRecorder _recorder;
  RxBool isRecording = false.obs;
  RxString audioPath = ''.obs;
  RxBool isPaused = false.obs;
  Rx<int> recordingDuration = 0.obs;
  Timer? _recordingTimer;

  @override
  void onInit() {
    _recorder = FlutterSoundRecorder();
    super.onInit();
  }

  // Get recording progress
  Stream<RecordingDisposition>? get recordingProgress => _recorder.onProgress;

  Future<void> startRecording() async {
    // Request audio recording permission
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      DialogHelper.showAlertDialog(
        titleColor: errorColor,
        title: Text('permission_denied'.tr),
        content: Text('microphone_permission_denied'.tr),
        actionText: 'open_settings'.tr,
        action: () {
          Get.back();
          Geolocator.openAppSettings();
        },
      );
      return;
    }

    // Open the Recorder session.
    await _recorder.openRecorder();

    // Check pause status
    if (isPaused.value) {
      // Resume recording if it was paused
      await _recorder.resumeRecorder();
    } else {
      // Start a new recording
      final Directory tempDir = await getTemporaryDirectory();
      final appName = AppConfig.appName.replaceAll(' ', '_').toLowerCase();
      final String date = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      audioPath.value = '${tempDir.path}/recording_${date}_$appName.aac';

      await _recorder.startRecorder(
        toFile: audioPath.value,
        codec: Codec.aacADTS,
      );
    }

    _startRecordingTimer();
    isRecording.value = true;
    if (receiverId != null) {
      UserApi.updateUserRecordingStatus(true, receiverId!);
    }

    isPaused.value = false;
  }

  Future<void> pauseRecording() async {
    await _recorder.pauseRecorder();
    _recordingTimer?.cancel();
    isPaused.value = true;
    isRecording.value = false;
    // Clear the player controller to init with valid duration
    Get.delete<AudioPlayerController>(tag: 'recording_playback', force: true);
  }

  void _startRecordingTimer() {
    // Cancel existing timer if any
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration.value += 1;
    });
  }

  String get formattedRecordingDuration {
    int totalSeconds = recordingDuration.value;
    int minutes = (totalSeconds ~/ 60);
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  //
  // <-- Send the recorded audio -->
  //
  Future<void> sendAudio() async {
    final File? audioFile = audioPath.isNotEmpty ? File(audioPath.value) : null;
    if (audioFile == null) {
      DialogHelper.showSnackbarMessage(
          SnackMsgType.error, 'Please record the Audio to send.');
      return;
    }
    debugPrint('sendAudio() -> path: $audioFile');
    Get.back(result: audioFile);
    // Free up resources
    _stopRecording();
  }

  Future<void> _stopRecording() async {
    _recorder.stopRecorder();
    _recorder.closeRecorder();
    _recordingTimer?.cancel();
  }

  @override
  void onClose() {
    _stopRecording();
    super.onClose();
  }
}
