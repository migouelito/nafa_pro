import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
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
  var selectedTypeFilter = "TOUS LES MOUVEMENTS".obs; 

  List<StockMovement> get filteredMouvements {
    return movementHistory.where((m) {
      // Filtre par texte
      final matchesText = m.type.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
                          m.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          m.target.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      // Filtre par type Dropdown
      bool matchesType = true;
      if (selectedTypeFilter.value != "TOUS LES MOUVEMENTS") {
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
        vente: (item['quantite_vente'] as num?)?.toInt() ?? 0, 
        echangeFull: (item['quantite_echange_charger'] as num?)?.toInt() ?? 0,
        echangeEmpty: (item['quantite_echange_vide'] as num?)?.toInt() ?? 0, 
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
          case 'APPROVISIONNEMENT': moveColor = Colors.green; break;
          case 'REMBOURSEMENT': moveColor = Colors.red; break;
          default: moveColor = Colors.blue;
        }

        return StockMovement(
          item['id']?.toString() ?? "", 
          typeStr,
          item['magasin_source_name'] ?? 'Inconnu',
          item['produit_name'] ?? "",
          moveColor,
          destinationName: item['magasin_destination_name'],
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
    // 1. Récupération et conversion des valeurs
    int qRecCharger = int.tryParse(qRechargeCharger.text) ?? 0;
    int qRecVide = int.tryParse(qRechargeVide.text) ?? 0;
    int qVnt = int.tryParse(qVente.text) ?? 0;
    int qEchCharger = int.tryParse(qEchangeCharger.text) ?? 0;
    int qEchVide = int.tryParse(qEchangeVide.text) ?? 0;

    // 2. Vérification si TOUS les champs sont à zéro ou nuls
    if (qRecCharger == 0 && qRecVide == 0 && qVnt == 0 && qEchCharger == 0 && qEchVide == 0) {
      Alerte.show(
        title: "Champs vides",
        imagePath: "assets/images/error.png",
        message: "Veuillez saisir au moins une quantité supérieure à 0.",
        color: Colors.red,
      );
      return; // On arrête l'exécution ici
    }

    // 3. Vérification des stocks (Source != Destination pour transfert)
    if (type == "TRANSFERT" && selectedStockId.value == selectedDestinationStockId.value) {
      Alerte.show(
        title: "Erreur",
        imagePath: "assets/images/error.png",
        message: "La destination doit être différente de la source",
        color: Colors.red,
      );
      return;
    }

    if (selectedStockId.value.isEmpty) {
      Alerte.show(
        title: "Attention",
        imagePath: "assets/images/error.png",
        message: "Choisissez un produit",
        color: Colors.red,
      );
      return;
    }

    // 4. Exécution de l'appel API
    try {
      LoadingModal.show();
      final body = {
        "type": type,
        "stock": selectedStockId.value,
        if (type == "TRANSFERT") "destination_stock": selectedDestinationStockId.value,
        "quantite_recharge_charger": qRecCharger,
        "quantite_recharge_vide": qRecVide,
        "quantite_vente": qVnt,
        "quantite_echange_charger": qEchCharger,
        "quantite_echange_vide": qEchVide,
      };

      final bool success = await apiService.createMouvement(body);
      LoadingModal.hide();

      if (success) {
        Get.back(); 
        Alerte.show(
          title: "Succès",
          imagePath: "assets/images/success.png",
          message: "Mouvement enregistré",
          color: AppColors.generalColor,
        );
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
  final int full, empty, vente, echangeFull, echangeEmpty; // Ajout des champs
  
  StockItem({
    required this.id, 
    required this.brand, 
    required this.type, 
    this.full = 0, 
    this.empty = 0,
    this.vente = 0,
    this.echangeFull = 0,
    this.echangeEmpty = 0,
  });
}

class StockMovement {
  final String id;
  final DateTime date;
  final String type, target, description;
  final String? destinationName; 
  final Color color;

  StockMovement(
    this.id, 
    this.type, 
    this.target, 
    this.description, 
    this.color, 
    {this.destinationName, DateTime? date} 
  ) : this.date = date ?? DateTime.now();
}