import 'package:get/get.dart';

enum UpdateType { created, added, removed, left, details, none }

class GroupUpdate {
  final bool asAdmin;
  final int members;
  final String memberId;

  const GroupUpdate({
    this.asAdmin = false,
    this.members = 1,
    this.memberId = '',
  });

  factory GroupUpdate.froMap(Map<String, dynamic> data) {
    return GroupUpdate(
      asAdmin: data['asAdmin'] ?? false,
      members: data['members'] ?? 1,
      memberId: data['memberId'] ?? '',
    );
  }

  @override
  String toString() {
    return "GroupUpdate(asAdmin: $asAdmin, members: $members, memberId: $memberId)";
  }

  static UpdateType getType(String? type) {
    return UpdateType.values.firstWhereOrNull((el) => el.name == type) ??
        UpdateType.none;
  }

  Map<String, dynamic> toMap() {
    return {
      'asAdmin': asAdmin,
      'members': members,
      'memberId': memberId,
    };
  }
}
