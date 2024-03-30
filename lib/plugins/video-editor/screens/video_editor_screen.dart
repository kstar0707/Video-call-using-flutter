import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:video_editor/video_editor.dart';

import '../components/app_bar_tools.dart';
import '../components/trim_slider_tab.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key, required this.file});

  final File file;

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 30),
  );

  @override
  void initState() {
    super.initState();
    // Load the video
    _controller.initialize().then((_) => setState(() {})).catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    await _controller.exportVideo(
      preset: VideoExportPreset.veryfast,
      customInstruction: "-crf 28",
      onProgress: (stats, value) => _exportingProgress.value = value,
      onError: (e, s) => _showErrorSnackBar(
        "failed_to_export_video".trParams(
          {'error': e.toString()},
        ),
      ),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;
        // Close the editor screen and pass the video file
        Navigator.of(context).pop(file);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildEditorBody,
      ),
    );
  }

  // Build Editor Body
  Widget get _buildEditorBody {
    // Check status
    if (!_controller.initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // <-- Top App Bar Tools -->
              ValueListenableBuilder(
                valueListenable: _isExporting,
                builder: (_, bool export, __) {
                  return Opacity(
                    opacity: export ? 0.5 : 1,
                    child: AppBarTools(
                      _controller,
                      exportVideo: _exportVideo,
                      isExporting: export,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Build Tabs -->
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Video & Crop TabBarView
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // <-- CropGridViewer -->
                                CropGridViewer.preview(controller: _controller),
                                AnimatedBuilder(
                                  animation: _controller.video,
                                  builder: (_, __) {
                                    if (_controller.isPlaying) {
                                      return const SizedBox.shrink();
                                    }
                                    return GestureDetector(
                                      onTap: _controller.video.play,
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            // <-- Cover Viewer -->
                            CoverViewer(controller: _controller),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // <-- Show Trim Slider -->
                      ValueListenableBuilder(
                        valueListenable: _isExporting,
                        builder: (_, bool export, __) {
                          if (export) {
                            return const SizedBox.shrink();
                          }
                          return TrimSliderTab(_controller);
                        },
                      ),

                      // <-- Export video progress -->
                      ValueListenableBuilder(
                        valueListenable: _isExporting,
                        builder: (_, bool export, __) {
                          if (!export) {
                            return const SizedBox.shrink();
                          }
                          return AlertDialog(
                            title: ValueListenableBuilder(
                              valueListenable: _exportingProgress,
                              builder: (_, double value, __) => Column(
                                children: [
                                  Text(
                                    "optimizing_video".trParams({
                                      'percentage': "${(value * 100).ceil()}%"
                                    }),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text('please_wait'.tr)
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
