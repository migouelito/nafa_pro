import 'package:get/get.dart';
import 'package:nafa_pro/modules/driver/dashboard/controllers/driver_controller.dart';

class SafetyController extends GetxController {
  // On regroupe pour ne pas fatiguer le livreur, mais on est explicite dans le texte
  var epiChecked = false.obs;      // Casque, Chaussures, Gants
  var vehicleChecked = false.obs;  // Freins, Pneus, Lumières
  var loadChecked = false.obs;     // Extincteur, Arrimage, Fuites

  bool get isValid => epiChecked.value && vehicleChecked.value && loadChecked.value;

  void toggleEpi() => epiChecked.toggle();
  void toggleVehicle() => vehicleChecked.toggle();
  void toggleLoad() => loadChecked.toggle();

  void submitSafetyCheck() {
    if (isValid) {
      final driverCtrl = Get.find<DriverController>();
      driverCtrl.validateSafetyCheck();
      Get.back();
      Get.snackbar(
        "Sécurité Validée", 
        "Vous êtes responsable de votre chargement. Bonne route !", 
        backgroundColor: Get.theme.primaryColor, 
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 4)
      );
    }
  }
}
