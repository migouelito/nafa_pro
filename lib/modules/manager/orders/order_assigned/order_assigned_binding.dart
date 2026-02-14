import 'package:get/get.dart';
import 'order_assigned_controller.dart';

class OrderAssignedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderAssignedController>(() => OrderAssignedController(), );
  }
}