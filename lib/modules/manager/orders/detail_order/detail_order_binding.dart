import 'package:get/get.dart';
import 'detail_order_controller.dart';

class DetailOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailOrderController>(() => DetailOrderController());
  }
}