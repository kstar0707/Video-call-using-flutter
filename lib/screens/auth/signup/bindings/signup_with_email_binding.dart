import 'package:get/get.dart';
import 'package:chat_messenger/screens/auth/signup/controllers/signup_with_email_controller.dart';

class SignUpWithEmailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpWithEmailController());
  }
}
