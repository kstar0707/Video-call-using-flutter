import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';

enum CallType { incoming, outgoing, missed }

class CallHistory {
  User receiver;
  bool isVideo;
  CallType type;
  bool isNew;
  DateTime? ceatedAt;
  DocumentReference<Map<String, dynamic>>? docRef;

  CallHistory({
    required this.receiver,
    required this.isVideo,
    required this.isNew,
    required this.type,
    this.ceatedAt,
    this.docRef,
  });

  factory CallHistory.fromMap({
    required User receiver,
    required Map<String, dynamic> data,
    required DocumentReference<Map<String, dynamic>> docRef,
  }) {
    return CallHistory(
      docRef: docRef,
      receiver: receiver,
      isNew: data['isNew'] ?? false,
      isVideo: data['isVideo'] ?? false,
      type: CallType.values.firstWhere((type) => type.name == data['type']),
      ceatedAt: data['ceatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isVideo': isVideo,
      'isNew': isNew,
      'type': type.name,
      'ceatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> viewCall() async {
    if (docRef != null && isNew) {
      await docRef!.update({'isNew': false});
    }
  }

  Future<void> clearCallLog() async {
    if (docRef != null) {
      await docRef!.delete();
    }
  }
}
