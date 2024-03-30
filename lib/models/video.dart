class Video {
  final String videoUrl;
  final String thumbnailUrl;
  final int views;
  final DateTime? createdAt;

  const Video({
    this.videoUrl = '',
    this.thumbnailUrl = '',
    this.views = 0,
    this.createdAt,
  });

  @override
  String toString() {
    return "Video(videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, views: $views, createdAt: $createdAt)";
  }

  factory Video.fromMap(Map<String, dynamic> data) {
    return Video(
      videoUrl: data['videoUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      views: data['views'] ?? 0,
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap({isNew = true}) {
    return {
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'views': views,
      'createdAt': isNew ? DateTime.now() : createdAt,
    };
  }

  Video copyWith({
    String? videoUrl,
    String? thumbnailUrl,
    int? views,
  }) {
    return Video(
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      views: views ?? this.views,
    );
  }

  Video incrementViews() {
    return copyWith(views: views + 1);
  }
}
