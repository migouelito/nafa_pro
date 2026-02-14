import 'package:get/get.dart';
import 'finances_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceController>(() => FinanceController());
  }
}
