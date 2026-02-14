import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import 'package:flutter/material.dart';

class ProduitsController extends GetxController {
  // Accès au controller principal
  final StockController stockController = Get.find<StockController>();

  // Marque sélectionnée (local au tunnel de produits)
  var selectedBrand = "TOUS LES PRODUITS".obs;

  // Liste des produits brute venant du StockController
  List<StockItem> get products => stockController.depotStock;

  // Liste filtrée pour la vue
  List<StockItem> get filteredProducts {
    if (selectedBrand.value == "TOUS LES PRODUITS") {
      return products;
    } else {
      return products.where((item) => item.brand == selectedBrand.value).toList();
    }
  }

  // Liste des marques uniques pour le dropdown
  List<String> get availableBrands {
    List<String> brands = products.map((e) => e.brand).toSet().toList();
    if (!brands.contains("TOUS LES PRODUITS")) {
      brands.insert(0, "TOUS LES PRODUITS");
    }
    return brands;
  }

  void updateBrand(String brand) => selectedBrand.value = brand;

  void reportDamage(StockItem item, bool isFull) {
    if (isFull && item.fullCount.value > 0) {
      item.fullCount.value--;
      item.damagedCount.value++;
      stockController.logMovement("AVARIE", "Interne", "Pleine isolée", Colors.red);
    } else if (!isFull && item.emptyCount.value > 0) {
      item.emptyCount.value--;
      item.damagedCount.value++;
      stockController.logMovement("AVARIE", "Interne", "Vide isolée", Colors.red);
    }
  }
}

// import 'package:get/get.dart';
// import '../controllers/stock_controller.dart';
// import 'package:flutter/material.dart';

// class ProduitsController extends GetxController {
//   // On accède au controller principal pour manipuler les données globales
//   final StockController stockController = Get.find<StockController>();

//   // Getter pratique pour la vue
//   List<StockItem> get products => stockController.depotStock;

//   // Logique de signalement d'avarie déplacée ici
//   void reportDamage(StockItem item, bool isFull) {
//     if (isFull && item.fullCount.value > 0) {
//       item.fullCount.value--;
//       item.damagedCount.value++;
//       stockController.logMovement("AVARIE", "Interne", "Pleine isolée", Colors.red);
//     } else if (!isFull && item.emptyCount.value > 0) {
//       item.emptyCount.value--;
//       item.damagedCount.value++;
//       stockController.logMovement("AVARIE", "Interne", "Vide isolée", Colors.red);
//     }
//   }
// }