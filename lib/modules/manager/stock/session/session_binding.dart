import 'package:get/get.dart';
import 'session_controler.dart';

class SessionBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<SessionController>(() => SessionController());
  }
}