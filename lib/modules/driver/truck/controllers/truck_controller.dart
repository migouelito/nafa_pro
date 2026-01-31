import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TruckItem {
  final String name;
  var full; 
  var empty;
  TruckItem(this.name, int f, int e) { full = f.obs; empty = e.obs; }
}

class TruckController extends GetxController {
  var items = <TruckItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Simule ce que le Manager a chargé le matin
    items.value = [
      TruckItem("Sodigaz B12", 8, 2),
      TruckItem("Total B12", 5, 0),
      TruckItem("Oryx B6", 10, 0),
    ];
  }

  void reportIssue(TruckItem item) {
    Get.defaultDialog(
      title: "SIGNALER PROBLÈME",
      titleStyle: const TextStyle(color: Colors.red),
      content: Column(
        children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Quel type de problème ?"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _issueBtn("Fuite (Pleine)", Icons.propane_tank, () => _sendReport(item, "Fuite")),
              _issueBtn("Valve HS (Vide)", Icons.crop_square, () => _sendReport(item, "Valve HS")),
            ],
          )
        ],
      ),
      textCancel: "Annuler"
    );
  }

  Widget _issueBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Column(children: [Icon(icon, color: Colors.red, size: 30), Text(label, style: const TextStyle(fontSize: 10))]));
  }

  void _sendReport(TruckItem item, String type) {
    Get.back();
    Get.snackbar("Signalé", "Le Manager a été notifié de l'avarie sur ${item.name}.", backgroundColor: Colors.red, colorText: Colors.white);
    // Côté Manager : Apparait dans Stock > Avarie
  }
}
