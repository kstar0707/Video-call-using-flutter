import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/plugins/video-editor/screens/video_editor_screen.dart';

class RecordVideoController extends GetxController {
  // Variables
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  final RxInt selectedCamera = 0.obs;
  final RxBool isRearCamera = true.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isCameraInitialized = false.obs;
  final RxBool hasCameraAccess = false.obs;
  final RxBool isCameraDeniedForever = false.obs;
  final RxBool hasMicrophoneAccess = false.obs;
  final RxBool isMicDeniedForever = false.obs;
  final RxInt videoCounter = 0.obs;
  Timer? _videoDurationTimer, _timer;

  bool get permissionsGranted =>
      hasCameraAccess.value && hasMicrophoneAccess.value;

  @override
  void onInit() async {
    await _checkPermissions();
    // Check permissions
    if (permissionsGranted) {
      _initializeCamera();
    }
    super.onInit();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    _videoDurationTimer?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> _checkPermissions() async {
    hasCameraAccess.value = await Permission.camera.status.isGranted;
    hasMicrophoneAccess.value = await Permission.microphone.status.isGranted;
  }

  Future<void> openSettings({required bool isCamera}) async {
    await openAppSettings();
    if (isCamera) {
      isCameraDeniedForever.value = false;
    } else {
      isMicDeniedForever.value = false;
    }
  }

  // Handle init camera
  Future<void> _initializeCamera() async {
    try {
      // Check permissions
      if (!permissionsGranted) {
        await _checkPermissions();
      }

      // Check result
      if (!permissionsGranted) {
        return;
      }
      cameras = await availableCameras();
      cameraController = CameraController(
          cameras[selectedCamera.value], ResolutionPreset.high);
      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'failed_to_open_camera'.trParams({'error': e.toString()}),
        duration: 5,
      );
    }
  }

  Future<void> requestCameraPermission() async {
    final cameraStatus = await Permission.camera.status;

    // Check result
    if (cameraStatus.isGranted) {
      hasCameraAccess.value = true;
    } else if (cameraStatus.isPermanentlyDenied) {
      isCameraDeniedForever.value = true;
    } else {
      final cameraRequest = await Permission.camera.request();
      hasCameraAccess.value = cameraRequest.isGranted;
      isCameraDeniedForever.value = cameraRequest.isPermanentlyDenied;
    }

    // Init camera if granted
    _initializeCamera();
  }

  Future<void> requestMicPermission() async {
    final microphoneStatus = await Permission.microphone.status;
    // Check result
    if (microphoneStatus.isGranted) {
      hasMicrophoneAccess.value = true;
    } else if (microphoneStatus.isPermanentlyDenied) {
      isMicDeniedForever.value = true;
    } else {
      final microphoneRequest = await Permission.microphone.request();
      hasMicrophoneAccess.value = microphoneRequest.isGranted;
      isMicDeniedForever.value = microphoneRequest.isPermanentlyDenied;
    }
    // Init camera if granted
    _initializeCamera();
  }

  // Update recording status
  void updateRecording(bool value) => isRecording.value = value;

  /// Get formatted duration with two digits: (min:sec)
  String formatDuration() {
    final Duration duration = Duration(seconds: videoCounter.value);

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Update flash status
  void toggleFlash() {
    isFlashOn.toggle();
    // Update flash
    cameraController!
        .setFlashMode(isFlashOn.value ? FlashMode.torch : FlashMode.off);
  }

  // Switch to front/rear camera
  Future<void> switchCamera() async {
    // Update values
    isCameraInitialized.value = false;
    isRearCamera.toggle();
    selectedCamera.value = isRearCamera.value ? 0 : 1;

    // Update camera controller
    cameraController =
        CameraController(cameras[selectedCamera.value], ResolutionPreset.high);
    await cameraController!.initialize();
    isCameraInitialized.value = true;
  }

  Future<void> startVideoRecording() async {
    // Update value
    isRecording.value = true;
    // <-- Record video -->
    await cameraController!.startVideoRecording();
    // Count video duration
    _startVideoTimer();
  }

  Future<void> stopVideoRecording() async {
    // Get recorded video file
    final XFile videoFile = await cameraController!.stopVideoRecording();

    // Updates
    isRecording.value = false;
    videoCounter.value = 0;
    _timer?.cancel();
    _videoDurationTimer?.cancel();
    _timer = null;
    _videoDurationTimer = null;

    // Open Video Editor
    openVideoEditor(File(videoFile.path));
  }

  Future<void> openVideoEditor(File videoFile) async {
    cameraController!.setFlashMode(FlashMode.off);

    // Go to Video Editor Screen
    final File? editedVideo = await Get.to(
      () => VideoEditorScreen(file: videoFile),
    );

    // Close Video Editor Screen
    Get.back(result: editedVideo);
  }

  // Count video duration
  void _startVideoTimer() {
    // Count duration
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      videoCounter.value++;
    });
  }
}
