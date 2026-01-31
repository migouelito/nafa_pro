import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import 'package:flutter/material.dart';

class InventoryController extends GetxController {
  // On accède au controller principal pour manipuler les données globales
  final StockController stockController = Get.find<StockController>();

  // Getter pratique pour la vue
  List<StockItem> get products => stockController.depotStock;

  // Logique de signalement d'avarie déplacée ici
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