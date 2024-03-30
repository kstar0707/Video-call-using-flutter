import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/user.dart';

import 'submodels/story_text.dart';
import 'submodels/story_image.dart';
import 'submodels/story_video.dart';

enum StoryType { text, video, image }

class Story {
  User? user;
  String id;
  String userId;
  StoryType type;
  List<StoryText> texts;
  List<StoryImage> images;
  List<StoryVideo> videos;
  List<String> viewers;
  DateTime? updatedAt;

  Story({
    this.user,
    this.id = '',
    this.userId = '',
    required this.type,
    this.texts = const [],
    this.videos = const [],
    this.images = const [],
    this.viewers = const [],
    required this.updatedAt,
  });

  bool get isOwner => userId == AuthController.instance.currentUser.userId;

  factory Story.fromMap({
    required User user,
    required Map<String, dynamic> data,
  }) {
    return Story(
      user: user,
      viewers: List<String>.from(data['viewers'] ?? []),
      id: data['id'] as String,
      userId: data['userId'] as String,
      type: StoryType.values.firstWhere((e) => e.name == data['type']),
      texts: StoryText.textsFrom(data['texts']),
      images: StoryImage.imagesFrom(data['images']),
      videos: StoryVideo.videosFrom(data['videos']),
      updatedAt: data['updatedAt'] != null
          ? data['updatedAt']!.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final String userId = AuthController.instance.currentUser.userId;
    return {
      'id': userId,
      'userId': userId,
      'type': type.name,
      'texts': texts.map((text) => text.toMap()).toList(),
      'images': images.map((image) => image.toMap()).toList(),
      'videos': videos.map((video) => video.toMap()).toList(),
      'viewers': [],
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> toUpdateMap({
    required StoryType type,
    required List<Map<String, dynamic>> values,
  }) {
    return {
      '${type.name}s': values,
      'type': type.name,
      'viewers': [],
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
