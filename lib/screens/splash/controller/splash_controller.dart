import 'package:get/get.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';

class SplashController extends GetxController {
  // Init Auth controller
  final auth = Get.put(AuthController(), permanent: true);

  @override
  void onInit() async {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    // Auth user account
    await auth.checkUserAccount();
  }
}
