import 'package:get/get.dart';
import 'fleet_controller.dart';

class FleetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FleetController>(() => FleetController());
  }
}
