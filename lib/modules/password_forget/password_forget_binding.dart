import 'package:get/get.dart';
import 'password_forget_controller.dart';

class PasswordForgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}