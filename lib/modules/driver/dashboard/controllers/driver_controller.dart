import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nafa_pro/routes/app_routes.dart';
import 'package:nafa_pro/modules/driver/delivery_validation/views/delivery_validation_view.dart';
import 'package:nafa_pro/modules/driver/home/controllers/driver_home_controller.dart';

// MODÈLE COMMANDE
class DeliveryMission {
  final String id;
  final String clientName;
  final String phoneNumber; // NOUVEAU
  final String address;
  final String details;
  final LatLng location;
  bool isCompleted;

  DeliveryMission({
    required this.id,
    required this.clientName,
    this.phoneNumber = "70000000", // Par défaut pour test
    required this.address,
    required this.details,
    required this.location,
    this.isCompleted = false,
  });
}

class DriverController extends GetxController {
  var isOnline = false.obs;         
  var isSafetyCheckDone = false.obs; 
  
  var currentPosition = const LatLng(12.3714, -1.5197).obs;
  var missions = <DeliveryMission>[].obs;
  var activeMission = Rxn<DeliveryMission>();
  final mapController = MapController();

  @override
  void onInit() {
    super.onInit();
    fetchAssignedMissions();
  }

  void toggleStatus(bool val) {
    if (val == true && !isSafetyCheckDone.value) {
      Get.toNamed(Routes.DRIVER_SAFETY);
      return; 
    }
    isOnline.value = val;
  }

  void validateSafetyCheck() {
    isSafetyCheckDone.value = true;
    isOnline.value = true;
  }

  void fetchAssignedMissions() {
    missions.value = [
      DeliveryMission(id: "CMD-001", clientName: "Moussa Koné", phoneNumber: "76543210", address: "Patte d'oie", details: "1x Sodigaz 12kg (Recharge)", location: const LatLng(12.3580, -1.5050)),
      DeliveryMission(id: "CMD-002", clientName: "Maquis Le Verdoyant", phoneNumber: "70203040", address: "Ouaga 2000", details: "3x Total 12kg (Pro)", location: const LatLng(12.3400, -1.4900)),
      DeliveryMission(id: "CMD-003", clientName: "Famille Ouedraogo", phoneNumber: "68112233", address: "Pissy", details: "1x Oryx 6kg (Kit)", location: const LatLng(12.3650, -1.5500)),
    ];
  }

  void startMission(DeliveryMission mission) {
    activeMission.value = mission;
    mapController.move(mission.location, 15.0);
  }

  void cancelNavigation() {
    activeMission.value = null;
    mapController.move(currentPosition.value, 13.0);
  }

  void arriveAtClient() {
    if (activeMission.value != null) {
      Get.to(() => const DeliveryValidationView(), arguments: activeMission.value);
    }
  }

  void completeCurrentMission() {
    try {
      final homeCtrl = Get.find<DriverHomeController>();
      homeCtrl.completedTrips.value++;
      homeCtrl.availableBonus.value += 100;
    } catch (e) {}
    missions.removeWhere((m) => m.id == activeMission.value?.id);
    activeMission.value = null;
    mapController.move(currentPosition.value, 13.0);
    Get.snackbar("Succès", "Mission terminée et enregistrée !", backgroundColor: Colors.green, colorText: Colors.white);
  }

  // --- NOUVEAU : FONCTION APPELER ---
  void callClient(String phone) {
    // Utilisation de url_launcher en réalité
    // launch("tel:$phone");
    Get.snackbar("Appel", "Composition du +226 $phone...", backgroundColor: Colors.green, colorText: Colors.white, icon: const Icon(Icons.phone_in_talk, color: Colors.white));
  }

  // --- NOUVEAU : SIGNALER UN PROBLÈME ---
  void reportIssue() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.report_problem, size: 50, color: Colors.orange),
            const SizedBox(height: 10),
            const Text("SIGNALER UNE ANOMALIE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("Pourquoi ne pouvez-vous pas livrer ?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            _buildIssueButton("Client Absent / Ne répond pas", Icons.person_off),
            _buildIssueButton("Adresse introuvable", Icons.wrong_location),
            _buildIssueButton("Client refuse la commande", Icons.cancel),
            _buildIssueButton("Problème Tricycle / Panne", Icons.build),
            const SizedBox(height: 10),
            TextButton(onPressed: () => Get.back(), child: const Text("Annuler", style: TextStyle(color: Colors.grey)))
          ],
        ),
      )
    );
  }

  Widget _buildIssueButton(String reason, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(reason),
      onTap: () {
        Get.back(); // Ferme le menu
        _processFailure(reason);
      },
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  void _processFailure(String reason) {
    // Logique : On retire la mission de la liste active, mais on la marque "Échouée" en base
    missions.removeWhere((m) => m.id == activeMission.value?.id);
    activeMission.value = null;
    mapController.move(currentPosition.value, 13.0);
    
    Get.snackbar(
      "Signalé", 
      "Retour au dépôt requis pour cette commande.\nRaison : $reason", 
      backgroundColor: Colors.orange, 
      colorText: Colors.black,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.warning, color: Colors.black)
    );
  }
}
