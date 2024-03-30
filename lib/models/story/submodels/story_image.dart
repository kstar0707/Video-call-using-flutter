import 'seen_by.dart';

class StoryImage {
  final String imageUrl;
  List<SeenBy> seenBy;
  final DateTime createdAt;

  StoryImage({
    required this.imageUrl,
    this.seenBy = const [],
    required this.createdAt,
  });

  factory StoryImage.fromMap(Map<String, dynamic> data) {
    return StoryImage(
      imageUrl: data['imageUrl'] as String,
      seenBy: SeenBy.seenByFrom(data['seenBy']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'seenBy': seenBy.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static List<StoryImage> imagesFrom(List listOfMaps) {
    final images = List<Map<String, dynamic>>.from(listOfMaps);
    return List<StoryImage>.from(
      images.map((item) => StoryImage.fromMap(item)),
    );
  }
}