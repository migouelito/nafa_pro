import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/routes/app_routes.dart';
import '../../../questionModal/questionModal.dart';

// MODÈLE SIMPLE POUR LE STOCK
class StockItem {
  final String brand; // Sodigaz, Total, Oryx
  final String type;  // B6, B12
  final bool isFull;  // true = Pleine, false = Vide
  int quantity;

  StockItem(this.brand, this.type, this.isFull, this.quantity);
}

class DriverHomeController extends GetxController {
  var currentIndex = 0.obs;
  final String driverName = "Amadou Ouédraogo";
  final String vehicleInfo = "Tricycle TVS King - 11 GG 4488";
  
  // STATS
  var completedTrips = 55.obs; 
  var availableBonus = 5500.obs;

  // --- NOUVEAU : STOCK EMBARQUÉ ---
  var truckStock = <StockItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialStock(); // Simulation du chargement au dépôt
  }

  // Simulation : Ce que le gestionnaire a mis dans le tricycle ce matin
  void _loadInitialStock() {
    truckStock.value = [
      // PLEINES (À vendre)
      StockItem("Sodigaz", "B12", true, 5),
      StockItem("Sodigaz", "B6", true, 3),
      StockItem("Total", "B12", true, 4),
      StockItem("Oryx", "B6", true, 2),
      
      // VIDES (Déjà récupérées ou stock tampon)
      StockItem("Sodigaz", "B12", false, 1), 
    ];
  }

  // Calculs rapides pour l'affichage
  int get totalFullBottles => truckStock.where((i) => i.isFull).fold(0, (sum, i) => sum + i.quantity);
  int get totalEmptyBottles => truckStock.where((i) => !i.isFull).fold(0, (sum, i) => sum + i.quantity);

  void changeTab(int index) => currentIndex.value = index;

  // --- AFFICHER LE DÉTAIL DU STOCK (BOTTOM SHEET) ---
  void showStockDetails() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("INVENTAIRE TRICYCLE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Text("Total: ${totalFullBottles + totalEmptyBottles} Bouteilles", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // ONGLETS VISUELS
            Row(
              children: [
                Expanded(child: _buildStockHeader("PLEINES (À Livrer)", totalFullBottles, Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _buildStockHeader("VIDES (Consignes)", totalEmptyBottles, Colors.orange)),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            
            // LISTE DÉTAILLÉE
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Détails par Marque", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  ...truckStock.map((item) {
                    if (item.quantity == 0) return const SizedBox.shrink();
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: item.isFull ? Colors.green.shade50 : Colors.orange.shade50,
                        child: Icon(item.isFull ? Icons.propane : Icons.sync_alt, color: item.isFull ? Colors.green : Colors.orange, size: 20),
                      ),
                      title: Text("${item.brand} ${item.type}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(
                        "x${item.quantity}", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: item.isFull ? Colors.black : Colors.grey)
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Get.back(), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text("FERMER")),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStockHeader(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text("$count", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ... (LOGIQUE RETRAIT INCHANGÉE) ...
  void requestBonusWithdrawal() {
    if (availableBonus.value < 5000) {
      Get.snackbar("Seuil non atteint", "Minimum 5 000 F requis.", backgroundColor: Colors.red, colorText: Colors.white, icon: const Icon(Icons.block, color: Colors.white));
      return;
    }
    final passwordController = TextEditingController();
    Get.defaultDialog(
      title: "SÉCURITÉ",
      content: Column(children: [const Icon(Icons.fingerprint, size: 50, color: Color(0xFF00A86B)), const SizedBox(height: 20), TextField(controller: passwordController, obscureText: true, textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Code PIN"))]),
      textConfirm: "VALIDER", textCancel: "Annuler", confirmTextColor: Colors.white, buttonColor: Colors.black,
      onConfirm: () { if (passwordController.text == "1234") { Get.back(); _showWithdrawalConfirmation(); } else { Get.snackbar("Erreur", "Code incorrect", backgroundColor: Colors.red, colorText: Colors.white); } }
    );
  }
  void _showWithdrawalConfirmation() {
    Get.defaultDialog(title: "VALIDATION", content: Column(children: [const Icon(Icons.verified, size: 60, color: Colors.green), Text("${availableBonus.value} F", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))]), textConfirm: "ENCAISSER", textCancel: "Annuler", confirmTextColor: Colors.white, buttonColor: const Color(0xFF00A86B), onConfirm: () { availableBonus.value = 0; Get.back(); Get.snackbar("Succès", "Retrait effectué."); });
  }
void logout() {
  DialogLogout.show(
    title: "Déconnexion",
    message: "Voulez-vous vraiment vous déconnecter de votre compte NAFA PRO ?",
    imagePath: "assets/images/logout.png", // Utilisation de votre image test.png
    color: const Color(0xFF00A86B), // Vert Nafa pour le bouton "Oui"
    onConfirm: () {
      // Redirection vers l'écran de login
      Get.offAllNamed(Routes.LOGIN);
    },
  );

}
}
