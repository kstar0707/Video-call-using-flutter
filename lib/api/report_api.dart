import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/user.dart';

enum ReportType { user, group, story }

abstract class ReportApi {
  //
  // ReportApi - CRUD Operations
  //

  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Report user profile or group
  static Future<bool> report({
    required ReportType type,
    required String message,
    String? userId,
    String? groupId,
    Map<String, dynamic>? story,
  }) async {
    // Get current user model
    final User currentUer = AuthController.instance.currentUser;

    try {
      // This approach will save each report per user
      await _firestore.collection('Reports').add({
        'type': type.name,
        'message': message,
        'userId': userId,
        'groupId': groupId,
        'story': story,
        'reportedByuserId': currentUer.userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      DialogHelper.showSnackbarMessage(
          SnackMsgType.success,
          "thanks_for_your_report_we_ll_review_this_case_as_soon_as_possible"
              .tr);
      return true;
    } catch (e) {
      // Show error message
      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        "failed_to_send_report".trParams(
          {'error': e.toString()},
        ),
      );
      return false;
    }
  }
}
