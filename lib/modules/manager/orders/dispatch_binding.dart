import 'package:get/get.dart';
import 'dispatch_controller.dart';

class DispatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DispatchController>(() => DispatchController());
  }
}
