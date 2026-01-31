import 'package:get/get.dart';
// Importez tous les contrôleurs
import 'manager_root_controller.dart';
import '../dashboard/controllers/manager_controller.dart';
import '../orders/dispatch_controller.dart';
import '../fleet/controllers/fleet_controller.dart';
import '../stock/controllers/stock_controller.dart';
import '../finance/controllers/finance_controller.dart';
import '../settings/controllers/settings_controller.dart';

class ManagerRootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerRootController>(() => ManagerRootController());
    
    // On injecte les contrôleurs des sous-pages ici pour qu'ils soient prêts
    Get.lazyPut<ManagerController>(() => ManagerController());
    Get.lazyPut<DispatchController>(() => DispatchController());
    Get.lazyPut<FleetController>(() => FleetController());
    Get.lazyPut<StockController>(() => StockController());
    Get.lazyPut<FinanceController>(() => FinanceController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
