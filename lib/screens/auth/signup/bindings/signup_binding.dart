import 'package:get/get.dart';
import 'package:chat_messenger/screens/auth/signup/controllers/signup_controller.dart';

class SignUpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController());
  }
}
