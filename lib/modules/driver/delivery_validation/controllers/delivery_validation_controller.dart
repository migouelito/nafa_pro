import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../dashboard/controllers/driver_controller.dart';
import '../../home/controllers/driver_home_controller.dart';

class DeliveryValidationController extends GetxController {
  
  late DeliveryMission mission;

  // --- VARIABLES ---
  var hasCollectedEmptyBottle = false.obs;
  var selectedActions = <String>[].obs; 
  
  // NOUVEAU : Contrôleur pour le champ texte
  final observationController = TextEditingController();

  final List<String> interventionTypes = [
    "Livraison Standard (Échange)",
    "Installation Nouveau Kit",
    "Changement Flexible / Détendeur",
    "Maintenance / Fuite réglée",
    "Formation Client Sécurité"
  ];

  String expectedEmptyBottle = "Aucune";

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      mission = Get.arguments as DeliveryMission;
      
      if (mission.details.contains("Recharge") || mission.details.contains("Echange")) {
        expectedEmptyBottle = "1x Bouteille Vide (${mission.details.split(' ')[1]})";
      } else {
        expectedEmptyBottle = "Aucune (Nouveau Kit)";
        hasCollectedEmptyBottle.value = true;
      }
      
      if (mission.details.contains("Kit")) {
        selectedActions.add("Installation Nouveau Kit");
      } else {
        selectedActions.add("Livraison Standard (Échange)");
      }
    }
  }

  @override
  void onClose() {
    observationController.dispose(); // Nettoyage mémoire
    super.onClose();
  }

  void toggleEmptyBottleCollection(bool? val) => hasCollectedEmptyBottle.value = val ?? false;

  void toggleAction(String action) {
    if (selectedActions.contains(action)) {
      selectedActions.remove(action);
    } else {
      selectedActions.add(action);
    }
  }

  void startQRScan() {
    if (!hasCollectedEmptyBottle.value) {
      Get.snackbar("Oubli", "Confirmez la récupération de la vide.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    if (selectedActions.isEmpty) {
      Get.snackbar("Oubli", "Veuillez sélectionner au moins une action.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.defaultDialog(
      title: "SCANNER CLIENT",
      content: Column(children: [
        Container(height: 150, width: 150, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 80)),
        const SizedBox(height: 15),
        const Text("Visez le QR Code client.", textAlign: TextAlign.center),
      ]),
      textConfirm: "QR DÉTECTÉ ✅", textCancel: "Annuler", confirmTextColor: Colors.white, buttonColor: const Color(0xFF00A86B),
      onConfirm: () {
        Get.back();
        _finalizeDelivery();
      }
    );
  }

  void _finalizeDelivery() {
    try {
      final driverCtrl = Get.find<DriverController>();
      
      // On récupère le commentaire
      String comment = observationController.text;
      if (comment.isNotEmpty) {
        print("Observation enregistrée: $comment");
      }

      Get.back();
      driverCtrl.completeCurrentMission(); 
      
      Get.snackbar("Validé", "Mission clôturée avec succès.", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print("Erreur finalisation: $e");
    }
  }
}
