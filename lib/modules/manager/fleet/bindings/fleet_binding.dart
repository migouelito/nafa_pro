import 'package:get/get.dart';
import '../controllers/fleet_controller.dart';

class FleetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FleetController>(() => FleetController());
  }
}
