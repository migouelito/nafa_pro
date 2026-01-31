import 'package:get/get.dart';
import '../controllers/driver_root_controller.dart';
// Controllers des sous-pages
import '../../home/controllers/driver_home_controller.dart';
import '../../missions/controllers/missions_controller.dart'; // A créer
import '../../wallet/controllers/wallet_controller.dart';     // A créer
import '../../truck/controllers/truck_controller.dart';       // A créer

class DriverRootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverRootController>(() => DriverRootController());
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
    Get.lazyPut<MissionsController>(() => MissionsController());
    Get.lazyPut<WalletController>(() => WalletController());
    Get.lazyPut<TruckController>(() => TruckController());
  }
}
