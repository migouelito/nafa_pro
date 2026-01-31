import 'package:get/get.dart';
import '../controllers/manager_controller.dart';

class ManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerController>(() => ManagerController());
  }
}
