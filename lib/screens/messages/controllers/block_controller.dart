import 'package:chat_messenger/api/block_api.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:get/get.dart';

class BlockController extends GetxController {
  // Constructor
  BlockController(this.otherUserId);

  final String? otherUserId;

  // Obx vars
  RxBool isLoading = false.obs;
  RxBool isUserBlocked = false.obs;
  RxBool isCurrentUserBlocked = false.obs;

  @override
  void onInit() {
    if (otherUserId != null) {
      checkBlockedStatus(otherUserId!);
    }
    super.onInit();
  }

  Future<void> checkBlockedStatus(String userId) async {
    final User currentUser = AuthController.instance.currentUser;

    isLoading.value = true;
    //
    final List<bool> results = await Future.wait([
      // Check other user status
      BlockApi.isBlocked(
        userId1: currentUser.userId,
        userId2: userId,
      ),
      // Check current user status
      BlockApi.isBlocked(
        userId1: userId,
        userId2: currentUser.userId,
      ),
    ]);
    isLoading.value = false;

    // Get the results
    isUserBlocked.value = results.first;
    isCurrentUserBlocked.value = results.last;
  }

  Future<void> blockUser() async {
    final User currentUser = AuthController.instance.currentUser;

    isUserBlocked.value = await BlockApi.blockUser(
      currentUserId: currentUser.userId,
      otherUserId: otherUserId!,
    );
  }

  Future<void> unblockUser() async {
    final User currentUser = AuthController.instance.currentUser;

    final bool result = await BlockApi.unblockUser(
      currentUserId: currentUser.userId,
      otherUserId: otherUserId!,
    );
    isUserBlocked.value = !result;
  }
}
