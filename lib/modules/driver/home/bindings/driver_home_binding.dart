import 'package:get/get.dart';
import 'package:nafa_pro/modules/driver/home/controllers/driver_home_controller.dart';
import 'package:nafa_pro/modules/driver/dashboard/controllers/driver_controller.dart';

class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
    Get.lazyPut<DriverController>(() => DriverController());
  }
}
