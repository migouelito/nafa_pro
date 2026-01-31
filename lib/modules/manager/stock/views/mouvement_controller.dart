import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/apiServices.dart';
import '../../../loading/loading.dart';
import '../../../alerte/alerte.dart';

class MouvementController extends GetxController {
  final apiService = ApiService();

  var movementHistory = <StockMovement>[].obs;
  var depotStock = <StockItem>[].obs; 
  var selectedStockId = "".obs; 
  var selectedDestinationStockId = "".obs; 
  var selectedEntity = "".obs; 
  var isLoading = false.obs;

  // --- LOGIQUE DE FILTRE ---
  var searchQuery = "".obs;
  var selectedTypeFilter = "TOUS".obs; // Filtre par type (Dropdown)

  List<StockMovement> get filteredMouvements {
    return movementHistory.where((m) {
      // Filtre par texte
      final matchesText = m.type.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
                          m.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          m.target.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      // Filtre par type Dropdown
      bool matchesType = true;
      if (selectedTypeFilter.value != "TOUS") {
        matchesType = m.type.toUpperCase() == selectedTypeFilter.value;
      }

      return matchesText && matchesType;
    }).toList();
  }

  final qRechargeCharger = TextEditingController(text: "0");
  final qRechargeVide = TextEditingController(text: "0");
  final qVente = TextEditingController(text: "0");
  final qEchangeCharger = TextEditingController(text: "0");
  final qEchangeVide = TextEditingController(text: "0");

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading(true);
    await Future.wait([getStocks(), getMouvements()]);
    isLoading(false);
  }

  Future<void> getStocks() async {
    try {
      final response = await apiService.getStocks(); 
      if (response != null && response is List) {
        depotStock.assignAll(response.map((item) => StockItem(
          id: item['id']?.toString() ?? "",
          brand: item['produit_nom'] ?? "Inconnu",
          type: item['magasin_nom'] ?? "Inconnu",
          full: (item['quantite_recharge_charger'] as num?)?.toInt() ?? 0,
          empty: (item['quantite_recharge_vide'] as num?)?.toInt() ?? 0,
        )).toList());
      }
    } catch (e) { print(e); }
  }

  Future<void> getMouvements() async {
    try {
      final response = await apiService.getMouvements(); 
      if (response != null && response is List) {
        List<StockMovement> fetchedMoves = response.map((item) {
          Color moveColor;
          String typeStr = (item['type'] ?? "INCONNU").toUpperCase();

          switch (typeStr) {
            case 'TRANSFERT': moveColor = Colors.blueGrey; break;
            case 'APPROVISIONNEMENT': moveColor = Colors.orange; break;
            case 'REMBOURSEMENT': moveColor = Colors.redAccent; break;
            default: moveColor = Colors.blue;
          }

          return StockMovement(
            item['id']?.toString() ?? "", 
            typeStr,
            "De: ${item['magasin_name'] ?? 'Inconnu'}${item['destination_name'] != null ? ' Vers: ${item['destination_name']}' : ''}",
            item['produit_name'] ?? "",
            moveColor,
            date: DateTime.tryParse(item['modified'] ?? "") ?? DateTime.now(),
          );
        }).toList();
        
        fetchedMoves.sort((a, b) => b.date.compareTo(a.date));
        movementHistory.assignAll(fetchedMoves);
      }
    } catch (e) { print("Erreur getMouvements: $e"); }
  }

  void prepareForm({required String initialEntity}) {
    selectedEntity.value = initialEntity;
    if (depotStock.isNotEmpty) {
      selectedStockId.value = depotStock[0].id;
      selectedDestinationStockId.value = depotStock.length > 1 ? depotStock[1].id : depotStock[0].id;
    }
    qRechargeCharger.text = "0"; qRechargeVide.text = "0";
    qVente.text = "0"; qEchangeCharger.text = "0"; qEchangeVide.text = "0";
  }

  Future<void> createMouvement({required String type, required Color color}) async {
    if (type == "TRANSFERT" && selectedStockId.value == selectedDestinationStockId.value) {
      Alerte.show(title: "Erreur", message: "La destination doit être différente de la source", color: Colors.red);
      return;
    }
    if (selectedStockId.value.isEmpty) {
      Alerte.show(title: "Attention", message: "Choisissez un produit", color: Colors.orange);
      return;
    }
    try {
      LoadingModal.show();
      final body = {
        "type": type,
        "stock": selectedStockId.value,
        if (type == "TRANSFERT") "destination_stock": selectedDestinationStockId.value,
        "quantite_recharge_charger": int.tryParse(qRechargeCharger.text) ?? 0,
        "quantite_recharge_vide": int.tryParse(qRechargeVide.text) ?? 0,
        "quantite_vente": int.tryParse(qVente.text) ?? 0,
        "quantite_echange_charger": int.tryParse(qEchangeCharger.text) ?? 0,
        "quantite_echange_vide": int.tryParse(qEchangeVide.text) ?? 0,
      };
      final bool success = await apiService.createMouvement(body);
      LoadingModal.hide();
      if (success) {
        Get.back(); 
        Alerte.show(title: "Succès", message: "Mouvement enregistré", color: Colors.green);
        refreshData(); 
      }
    } catch (e) {
      LoadingModal.hide();
      Alerte.show(title: "Erreur", message: e.toString(), color: Colors.red);
    }
  }
}

class StockItem {
  final String id, brand, type;
  final int full, empty;
  StockItem({required this.id, required this.brand, required this.type, this.full = 0, this.empty = 0});
}

class StockMovement {
  final String id;
  final DateTime date;
  final String type, target, description;
  final Color color;
  StockMovement(this.id, this.type, this.target, this.description, this.color, {DateTime? date}) 
      : this.date = date ?? DateTime.now();
}