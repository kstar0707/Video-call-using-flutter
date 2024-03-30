import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'components/camera_action_button.dart';
import 'components/camera_display.dart';
import 'components/camera_permission_failed.dart';
import 'components/switch_action_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Variables
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  int _selectedCamera = 0;
  bool _isRearCamera = true;
  bool _isFlashOn = false;
  bool _isVideo = false;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _permissionsAllowed = true;
  int _videoCounter = 0;
  Timer? _videoDurationTimer, _timer;
  final Duration _videoDuration = const Duration(seconds: 30);

  // Handle init camera
  Future<void> _initializeCamera() async {
    try {
      PermissionState state = await PhotoManager.requestPermissionExtend();
      if (!state.hasAccess || !state.isAuth) {
        _permissionsAllowed = false;
        return;
      }
      _permissionsAllowed = true;
      _cameras = await availableCameras();
      if (!mounted) return;
      _cameraController =
          CameraController(_cameras[_selectedCamera], ResolutionPreset.high);
      await _cameraController.initialize();
      _isInitialized = true;
    } catch (e) {
      _permissionsAllowed = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  // Update flash status
  void _toggleFlash() {
    // Update UI
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    // Update flash
    _cameraController
        .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  // Switch to front/rear camera
  void _switchCamera() async {
    // Update values
    _isRearCamera = !_isRearCamera;
    _selectedCamera = _isRearCamera ? 0 : 1;

    // Update camera controller
    _cameraController =
        CameraController(_cameras[_selectedCamera], ResolutionPreset.high);
    await _cameraController.initialize();
    // Update UI
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePhoto(BuildContext context) async {
    XFile file = await _cameraController.takePicture();
    if (mounted) {
      Future(() => Navigator.of(context).pop<File>(File(file.path)));
    }
  }

  Future<void> _stopVideoRecording(BuildContext context) async {
    // Get recorded file
    XFile file = await _cameraController.stopVideoRecording();

    // Cancel the timers
    _timer?.cancel();
    _videoDurationTimer?.cancel();
    _timer = null;
    _videoDurationTimer = null;

    // Close this screen
    if (mounted) {
      Future(() => Navigator.of(context).pop<File>(File(file.path)));
    }
  }

  // Count video duration
  void _startVideoTimer() {
    // Count duration
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _videoCounter++;
      });
    });
    // Stop recording video based on duration
    _videoDurationTimer = Timer.periodic(_videoDuration, (Timer timer) {
      if (_isRecording) {
        if (!mounted) return;
        // Stop video recording
        _stopVideoRecording(context);
      }
    });
  }

  @override
  void initState() {
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _videoDurationTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: _buildCameraPreview());
  }

  // Build camera preview
  Widget _buildCameraPreview() {
    // Check permition status
    if (_permissionsAllowed) {
      // Check camera state
      if (!_isInitialized) return _loadingProgress();

      // Build camera body
      return _cameraBody();
    } else {
      return const CameraPermissionFailed();
    }
  }

  Widget _cameraBody() {
    return Stack(
      children: [
        // Camera Preview
        CameraDisplay(_cameraController),
        // AppBar
        _buildAppBar(),
        // Camera actions
        _cameraActions(),
        // Bottom actions
        _bottomActions(),
      ],
    );
  }

  // Build Camera Actions
  Widget _cameraActions() {
    return Positioned(
      bottom: 100,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
        ),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: _isRecording
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            // Open Gallery
            if (!_isRecording)
              CameraActionButton(
                icon: const Icon(IconlyBold.image, color: Colors.white),
                onTap: () async {
                  // Go to Gallery
                  final File? file = await MediaHelper.pickMediaFromGallery(
                    type: RequestType.common,
                  );

                  // Cloee the camera screen
                  if (mounted) {
                    Navigator.of(context).pop<File?>(file);
                  }
                },
              ),

            // <--- Capture photo/video button --->
            CameraActionButton(
              onTap: () async {
                // Check recording status
                if (_isRecording) {
                  // Stop video recording and close the screen
                  _stopVideoRecording(context);
                } else if (_isVideo) {
                  // Update value
                  _isRecording = true;
                  // <-- Record video -->
                  await _cameraController.startVideoRecording();
                  // Count video duration
                  _startVideoTimer();
                  // Update UI
                  setState(() {});
                } else {
                  // <-- Take photo and close the screen -->
                  _takePhoto(context);
                }
              },
              padding: 0,
              color: _isRecording ? Colors.red : Colors.white,
              icon: Stack(
                children: [
                  Icon(
                    _isRecording
                        ? Icons.stop_circle_outlined
                        : Icons.radio_button_on,
                    color: _isRecording ? Colors.red : Colors.white,
                    size: 80,
                  ),
                  Offstage(
                    offstage: !_isRecording,
                    child: const Icon(Icons.radio_button_off,
                        size: 80, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Switch camera
            if (!_isRecording)
              CameraActionButton(
                onTap: _switchCamera,
                icon: RotatedBox(
                  quarterTurns: _selectedCamera,
                  child: const Icon(
                    IconlyBold.camera,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bottomActions() {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        color: const Color(0xFF0a1419),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchActionButton(
              'Photo',
              isSelected: !_isVideo,
              onTap: () async {
                // Check recording status
                if (_isRecording) {
                  _stopVideoRecording(context);
                }
                // Update UI
                if (mounted) {
                  setState(() {
                    _isVideo = false;
                    _isRecording = false;
                  });
                }
              },
            ),
            SwitchActionButton(
              'Video',
              isSelected: _isVideo,
              onTap: () {
                // Update UI
                setState(() => _isVideo = true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: _isVideo
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : Colors.black26,
                  borderRadius: BorderRadius.circular(defaultPadding)),
              child: Text(
                // <--- Show recording timer --->
                _isRecording
                    ? MediaHelper.formatDuration(
                        Duration(seconds: _videoCounter),
                      )
                    : '00:00',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close),
      ),
      actions: [
        IconButton(
          onPressed: _toggleFlash,
          icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
        ),
      ],
    );
  }

  Widget _loadingProgress() {
    return Container(color: Colors.black);
    // return const Center(
    //   child: SvgIcon(
    //     'assets/icons/camera.svg',
    //     color: primaryColor,
    //     width: 100,
    //     height: 100,
    //   ),
    // );
  }
}
