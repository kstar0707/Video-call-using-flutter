import 'package:get/get.dart';
import 'package:intl/intl.dart';

extension DateHelper on DateTime {
  ///
  /// Date Time Helper extension
  ///

  String get formatDateTime {
    // Variables
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime dateTime = DateTime(year, month, day);
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    String difference = '';

    // Check dates
    if (dateTime == today) {
      difference = "${"today".tr} ${_formatLastSeenTime(this)}";
    } else if (dateTime == yesterday) {
      difference = "${"yesterday".tr} ${_formatLastSeenTime(this)}";
    } else {
      difference = DateFormat.yMMMd().format(this);
    }

    return difference;
  }

  String get formatMsgTime {
    return DateFormat.Hm().format(this);
  }

  // Compare two dates
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
  

  // 
  // <-- Format Last seen dates -->
  //
  String get getLastSeenTime {
    DateTime now = DateTime.now();
    Duration difference = now.difference(this);

    if (difference.inDays == 0) {
      // Last seen today
      return '${'last_seen_today_at'.tr} ${_formatLastSeenTime(this)}';
    } else if (difference.inDays == 1) {
      // Last seen yesterday
      return '${'last_seen_yesterday_at'.tr} ${_formatLastSeenTime(this)}';
    } else {
      // Last seen on another date
      return '${'last_seen_at'.tr} ${_formatLastSeenDate(this)}';
    }
  }

  String _formatLastSeenTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  String _formatLastSeenDate(DateTime time) {
    return DateFormat('MMM d,').add_jm().format(time);
  }

  // END.
}
