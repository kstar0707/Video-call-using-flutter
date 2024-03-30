class SeenBy {
  final String userId;
  final String fullname;
  final String photoUrl;
  final DateTime time;

  const SeenBy({
    required this.userId,
    required this.fullname,
    required this.photoUrl,
    required this.time,
  });

  factory SeenBy.fromMap(Map<String, dynamic> data) {
    return SeenBy(
      userId: data['userId'] as String,
      fullname: data['fullname'] as String,
      photoUrl: data['photoUrl'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(data['time'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullname': fullname,
      'photoUrl': photoUrl,
      'time': time.millisecondsSinceEpoch,
    };
  }

  static List<SeenBy> seenByFrom(List listOfMaps) {
    final seenBy = List<Map<String, dynamic>>.from(listOfMaps);
    return List<SeenBy>.from(
      seenBy.map((e) => SeenBy.fromMap(e)).toList(),
    );
  }
}
