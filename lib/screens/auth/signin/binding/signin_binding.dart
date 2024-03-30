import 'package:get/get.dart';
import 'package:chat_messenger/screens/auth/signin/controller/signin_controller.dart';

class SignInBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignInController());
  }
}
