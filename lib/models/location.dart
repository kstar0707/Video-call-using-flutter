class Location {
  final double latitude;
  final double longitude;

  const Location({this.latitude = 0.1, this.longitude = 0.1});

  @override
  String toString() {
    return "Location(latitude: $latitude, longitude: $longitude)";
  }

  factory Location.fromMap(Map<String, dynamic> data) {
    return Location(
      latitude: data['latitude'] ?? 0,
      longitude: data['longitude'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
