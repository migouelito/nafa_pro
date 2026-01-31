import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart'; // RETIRÉ POUR ÉVITER L'ERREUR

// MODÈLE CLIENT
class Client {
  final String id;
  final String name;
  final String type; // Maquis, Ménage, Revendeur
  final String phone;
  final String location;
  final int totalSpent; // Total dépensé à vie
  final DateTime lastOrderDate;
  
  // Segmentation automatique
  bool get isVIP => totalSpent > 500000;
  bool get isChurning => DateTime.now().difference(lastOrderDate).inDays > 15; // Inactif > 15 jours

  Client(this.id, this.name, this.type, this.phone, this.location, this.totalSpent, this.lastOrderDate);
}

class ClientsController extends GetxController {
  var allClients = <Client>[].obs;
  var filteredClients = <Client>[].obs;
  final searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadClients();
  }

  void _loadClients() {
    allClients.value = [
      Client("1", "Maquis Le Verdoyant", "Maquis", "70 00 00 01", "Ouaga 2000", 1250000, DateTime.now().subtract(const Duration(days: 2))),
      Client("2", "Mme Traoré", "Ménage", "76 00 00 02", "Pissy", 45000, DateTime.now().subtract(const Duration(days: 20))), // Risque de départ
      Client("3", "Resto du Bonheur", "Restaurant", "78 00 00 03", "Karpala", 850000, DateTime.now().subtract(const Duration(days: 5))),
      Client("4", "Boutique Oumar", "Revendeur", "75 00 00 04", "Gounghin", 200000, DateTime.now().subtract(const Duration(days: 30))), // Inactif
    ];
    filteredClients.value = allClients;
  }

  void filterClients(String query) {
    if (query.isEmpty) {
      filteredClients.value = allClients;
    } else {
      filteredClients.value = allClients.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  // APPELER LE CLIENT (Version Simulée sans Erreur)
  void callClient(Client client) {
    // On simule l'action au lieu d'appeler le package manquant
    Get.snackbar(
      "Appel en cours", 
      "Composition du numéro ${client.phone}...", 
      backgroundColor: Colors.green, 
      colorText: Colors.white,
      icon: const Icon(Icons.phone_in_talk, color: Colors.white),
      duration: const Duration(seconds: 3)
    );
  }

  // VOIR HISTORIQUE
  void showHistory(Client client) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Historique : ${client.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            _historyRow("20 Janv", "5x Sodigaz B12", "Livré"),
            _historyRow("05 Janv", "5x Sodigaz B12", "Livré"),
            _historyRow("20 Dec", "3x Total B6", "Livré"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Get.back(); Get.snackbar("Info", "Nouvelle commande pour ${client.name}"); }, 
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("CRÉER UNE COMMANDE"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
              ),
            )
          ],
        ),
      )
    );
  }

  Widget _historyRow(String date, String desc, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(desc, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
