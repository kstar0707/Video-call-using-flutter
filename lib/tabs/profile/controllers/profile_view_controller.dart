import 'package:chat_messenger/api/block_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';

class ProfileViewController extends GetxController {
  final String userId;

  ProfileViewController(this.userId);

  final RxBool isBlocked = RxBool(false);

  @override
  void onInit() {
    _checkBlockedUser();
    super.onInit();
  }

  Future<void> _checkBlockedUser() async {
    final User currentUser = AuthController.instance.currentUser;

    isBlocked.value = await BlockApi.isBlocked(
      userId1: currentUser.userId,
      userId2: userId,
    );
  }

  Future<void> toggleBlockUser() async {
    final User currentUser = AuthController.instance.currentUser;

    if (isBlocked.value) {
      BlockApi.unblockUser(
          currentUserId: currentUser.userId, otherUserId: userId);
    } else {
      BlockApi.blockUser(
          currentUserId: currentUser.userId, otherUserId: userId);
    }
    isBlocked.toggle();
  }
}
