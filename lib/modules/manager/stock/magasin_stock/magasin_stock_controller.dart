import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/apiServices.dart';

class MagasinStockController extends GetxController {
  final apiService = ApiService();
  var depotStock = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedBrand = "TOUS LES PRODUITS".obs;

  @override
  void onInit() {
    super.onInit();
    getProduits();
  }

  Future<void> getProduits() async {
    try {
      isLoading.value = true;
      final response = await apiService.getStocks(); 
      if (response != null && response is List) {
        depotStock.assignAll(List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      debugPrint("Erreur Stock: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredStock {
    if (selectedBrand.value == "TOUS LES PRODUITS") return depotStock;
    return depotStock.where((item) => item['produit_nom'] == selectedBrand.value).toList();
  }

  void updateSelectedBrand(String brand) => selectedBrand.value = brand;

  int get countInAlert {
    return depotStock.where((item) {
      final total = (item['nombre_total'] ?? 0);
      final seuil = (item['seuil_alerte'] ?? 0);
      return total <= seuil;
    }).length;
  }
}