import 'seen_by.dart';

class StoryVideo {
  final String videoUrl;
  final String thumbnailUrl;
  List<SeenBy> seenBy;
  final DateTime createdAt;

  StoryVideo({
    required this.videoUrl,
    required this.thumbnailUrl,
    this.seenBy = const [],
    required this.createdAt,
  });

  factory StoryVideo.fromMap(Map<String, dynamic> data) {
    return StoryVideo(
      videoUrl: data['videoUrl'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String,
      seenBy: SeenBy.seenByFrom(data['seenBy']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'seenBy': seenBy.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static List<StoryVideo> videosFrom(List listOfMaps) {
    final videos = List<Map<String, dynamic>>.from(listOfMaps);
    return List<StoryVideo>.from(
      videos.map((item) => StoryVideo.fromMap(item)),
    );
  }
}