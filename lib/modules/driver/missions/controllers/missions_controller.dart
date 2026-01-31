import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../wallet/controllers/wallet_controller.dart'; // Pour créditer le gain

class Mission {
  final String id;
  final String client;
  final String address;
  final String details;
  final int commission;
  var status; // 'PENDING', 'DELIVERED'
  Mission(this.id, this.client, this.address, this.details, this.commission, {this.status = 'PENDING'});
}

class MissionsController extends GetxController {
  var missions = <Mission>[].obs;

  @override
  void onInit() {
    super.onInit();
    missions.value = [
      Mission("CMD-885", "Maquis Le Verdoyant", "Ouaga 2000", "5x Sodigaz B12", 150),
      Mission("CMD-886", "Mme Traoré", "Pissy", "1x Total B6", 50),
    ];
  }

  void completeMission(Mission m) {
    Get.defaultDialog(
      title: "VALIDER LIVRAISON",
      content: const Column(children: [Text("Confirmez-vous la livraison ?"), SizedBox(height: 5), Text("Le gain sera ajouté à votre solde.", style: TextStyle(fontSize: 10, color: Colors.grey))]),
      textConfirm: "LIVRÉ",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        m.status = 'DELIVERED';
        missions.refresh();
        
        // Créditer le Wallet (Simulation)
        try {
          Get.find<WalletController>().balance.value += m.commission;
          Get.find<WalletController>().transactions.insert(0, Transaction("Mission ${m.client}", m.commission, DateTime.now()));
        } catch (e) { print("Wallet controller not ready yet"); }

        Get.back();
        Get.snackbar("Bravo !", "+${m.commission} F ajoutés à vos gains.", backgroundColor: Colors.green, colorText: Colors.white);
      }
    );
  }

  void openMap(Mission m) {
    Get.snackbar("GPS", "Navigation vers ${m.address}...", icon: const Icon(Icons.map, color: Colors.white), backgroundColor: Colors.blue, colorText: Colors.white);
  }
}
