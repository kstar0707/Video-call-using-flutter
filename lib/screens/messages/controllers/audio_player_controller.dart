import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioPlayerController extends GetxController {
  final String fileUrl;
  final bool isRecording;

  AudioPlayerController({required this.fileUrl, this.isRecording = false});

  // Variables
  final _audioPlayer = AudioPlayer();
  RxBool isPlaying = false.obs;
  Rx<Duration> duration = Rx(Duration.zero);
  Rx<Duration> position = Rx(Duration.zero);

  // Load the Audio URL
  void _loadAudioUrl() async {
    // Set audio URL
    if (isRecording) {
      _audioPlayer.setSourceDeviceFile(fileUrl);
    } else {
      _audioPlayer.setSourceUrl(fileUrl);
    }
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    final Duration? audioDuration = await _audioPlayer.getDuration();
    if (audioDuration != null) {
      duration.value = audioDuration;
    }
  }

  // Get audio updates
  void _audioPlayerEvents() {
    // Listen to: playing, paused, stopped
    _audioPlayer.onPlayerStateChanged.listen((event) {
      isPlaying.value = event == PlayerState.playing;
    });

    // Listen to "duration" changes
    _audioPlayer.onDurationChanged.listen((Duration d) {
      duration.value = d;
    });

    // Listen to "position" changes
    _audioPlayer.onPositionChanged.listen((Duration p) {
      position.value = p;
    });
  }

  void playAudio() {
    if (isPlaying.value) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
    // Play audio if was paused
    await _audioPlayer.resume();
  }

  @override
  void onInit() {
    _loadAudioUrl();
    _audioPlayerEvents();
    super.onInit();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
