import 'package:flutter/material.dart';
import 'package:get/get.dart';

// MODÈLE DE CONFIGURATION PRODUIT
class ProductConfig {
  String id;
  String brand;      // Ex: Sodigaz
  String type;       // Ex: B12
  var buyPrice = 0.obs;    // Prix Achat Usine
  var sellPrice = 0.obs;   // Prix Vente Client
  var driverCommission = 0.obs; // Commission Livreur

  ProductConfig({
    required this.id, 
    required this.brand, 
    required this.type, 
    required int buy, 
    required int sell, 
    required int comm
  }) {
    buyPrice.value = buy;
    sellPrice.value = sell;
    driverCommission.value = comm;
  }

  // Calcul de la marge nette dépôt
  int get netMargin => sellPrice.value - buyPrice.value - driverCommission.value;
}

class SettingsController extends GetxController {
  // LISTE DES PRODUITS CONFIGURÉS
  var products = <ProductConfig>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadConfigs();
  }

  void _loadConfigs() {
    // Données initiales (Prix du marché approx)
    products.value = [
      ProductConfig(id: "1", brand: "Sodigaz", type: "B12", buy: 5500, sell: 6000, comm: 100),
      ProductConfig(id: "2", brand: "Sodigaz", type: "B6", buy: 2700, sell: 3000, comm: 50),
      ProductConfig(id: "3", brand: "Total", type: "B12", buy: 5600, sell: 6100, comm: 100),
      ProductConfig(id: "4", brand: "Oryx", type: "B12", buy: 5500, sell: 6000, comm: 100),
    ];
  }

  // MODIFIER UN PRIX
  void openEditModal(ProductConfig product) {
    // Contrôleurs pour le formulaire
    final buyCtrl = TextEditingController(text: product.buyPrice.value.toString());
    final sellCtrl = TextEditingController(text: product.sellPrice.value.toString());
    final commCtrl = TextEditingController(text: product.driverCommission.value.toString());

    // Variable réactive pour afficher la marge en temps réel dans le formulaire
    var previewMargin = product.netMargin.obs;

    // Fonction locale de calcul
    void recalculate() {
      int b = int.tryParse(buyCtrl.text) ?? 0;
      int s = int.tryParse(sellCtrl.text) ?? 0;
      int c = int.tryParse(commCtrl.text) ?? 0;
      previewMargin.value = s - b - c;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("CONFIGURER ${product.brand} ${product.type}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              
              // 1. PRIX ACHAT
              TextField(
                controller: buyCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => recalculate(),
                decoration: const InputDecoration(labelText: "Prix Achat Usine (Coût)", suffixText: "FCFA", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              // 2. PRIX VENTE
              TextField(
                controller: sellCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => recalculate(),
                decoration: const InputDecoration(labelText: "Prix Vente Client (Public)", suffixText: "FCFA", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              // 3. COMMISSION
              TextField(
                controller: commCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => recalculate(),
                decoration: const InputDecoration(labelText: "Commission Livreur", suffixText: "FCFA", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // APERÇU MARGE
              Obx(() {
                bool isPositive = previewMargin.value > 0;
                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: isPositive ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Marge Nette Dépôt :", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${previewMargin.value} FCFA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isPositive ? Colors.green : Colors.red)),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    product.buyPrice.value = int.tryParse(buyCtrl.text) ?? 0;
                    product.sellPrice.value = int.tryParse(sellCtrl.text) ?? 0;
                    product.driverCommission.value = int.tryParse(commCtrl.text) ?? 0;
                    Get.back();
                    Get.snackbar("Succès", "Prix mis à jour pour ${product.brand}.", backgroundColor: Colors.green, colorText: Colors.white);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
                  child: const Text("SAUVEGARDER"),
                ),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true
    );
  }

  // AJOUTER UN NOUVEAU PRODUIT
  void addProduct() {
    Get.defaultDialog(
      title: "Nouveau Produit",
      content: const Column(children: [
        TextField(decoration: InputDecoration(labelText: "Marque (ex: Shell)")),
        TextField(decoration: InputDecoration(labelText: "Type (ex: B12)")),
      ]),
      textConfirm: "Créer",
      confirmTextColor: Colors.white,
      onConfirm: () {
        products.add(ProductConfig(id: DateTime.now().toString(), brand: "Nouveau", type: "B12", buy: 0, sell: 0, comm: 0));
        Get.back();
      }
    );
  }
}
