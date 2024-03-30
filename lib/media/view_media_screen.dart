import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:video_player/video_player.dart';

class ViewMediaScreen extends StatefulWidget {
  const ViewMediaScreen({
    super.key,
    required this.fileUrl,
    this.isVideo = false,
  });

  final String fileUrl;
  final bool isVideo;

  @override
  State<ViewMediaScreen> createState() => _ViewMediaScreenState();
}

class _ViewMediaScreenState extends State<ViewMediaScreen> {
  // Controllers
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  void _loadVideo() async {
    // Check video
    if (!widget.isVideo) return;

    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.fileUrl));
    await _videoController?.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
    );
    setState(() {});
  }

  @override
  void initState() {
    _loadVideo();
    super.initState();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          IconButton(
            onPressed: () => AppHelper.downloadFile(widget.fileUrl),
            icon: const Icon(
              IconlyLight.download,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Builder(builder: (_) {
          // Check status
          final bool isInitialized = _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized;

          if (widget.isVideo) {
            if (isInitialized) {
              return Chewie(
                controller: _chewieController!,
              );
            }
            return const LoadingIndicator(size: 35);
          }
          return Hero(
            tag: widget.fileUrl,
            child: Container(
              alignment: Alignment.center,
              width: double.maxFinite,
              height: double.maxFinite,
              child: CachedCardImage(widget.fileUrl),
            ),
          );
        }),
      ),
    );
  }
}
