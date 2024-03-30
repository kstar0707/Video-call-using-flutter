import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

enum LoginProvider { email, google, apple }

class User {
  String userId;
  String fullname;
  String username;
  String photoUrl;
  String email;
  String bio;
  bool isOnline;
  DateTime? lastActive;
  String deviceToken;
  String status;
  LoginProvider loginProvider;
  bool isTyping;
  String typingTo;
  bool isRecording;
  String recordingTo;
  List<String> mutedGroups;

  User({
    this.userId = '',
    this.fullname = '',
    this.username = '',
    this.photoUrl = '',
    this.email = '',
    this.bio = '',
    this.isOnline = false,
    this.lastActive,
    this.deviceToken = '',
    this.status = 'active',
    this.loginProvider = LoginProvider.email,
    this.isTyping = false,
    this.typingTo = '',
    this.isRecording = false,
    this.recordingTo = '',
    this.mutedGroups = const [],
  });

  // Get User first name
  String get firstName => fullname.split(' ').first;

  @override
  String toString() {
    return 'User(userId: $userId, fullname: $fullname, username:$username, photoUrl: $photoUrl, bio: $bio, isOnline: $isOnline, lastActive: $lastActive, deviceToken: $deviceToken, isTyping: $isTyping, typingTo: $typingTo)';
  }

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      userId: data['userId'] ?? '',
      fullname: data['fullname'] ?? '',
      username: data['username'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      isOnline: data['isOnline'] ?? false,
      lastActive: DateTime.fromMillisecondsSinceEpoch(data['lastActive'] ?? 0),
      deviceToken: data['deviceToken'] ?? '',
      status: data['status'] ?? '',
      loginProvider: LoginProvider.values
              .firstWhereOrNull((el) => el.name == data['loginProvider']) ??
          LoginProvider.email,
      isTyping: data['isTyping'] ?? false,
      typingTo: data['typingTo'] ?? '',
      isRecording: data['isRecording'] ?? false,
      recordingTo: data['recordingTo'] ?? '',
      mutedGroups: List.from(data['mutedGroups'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullname': fullname,
      'username': username,
      'photoUrl': photoUrl,
      'email': email,
      'bio': bio,
      'isOnline': isOnline,
      'lastActive': lastActive?.millisecondsSinceEpoch,
      'deviceToken': deviceToken,
      'status': status,
      'isTyping': isTyping,
      'typingTo': typingTo,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
