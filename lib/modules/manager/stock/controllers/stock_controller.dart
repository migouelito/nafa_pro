import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/apiServices.dart';
import '../../../loading/loading.dart';
import '../../../alerte/alerte.dart';

class StockController extends GetxController {
  final apiService = ApiService();
  var depotStock = <StockItem>[].obs;     
  var chargementStock = <StockItem>[].obs;
  var sessionsList = <Map<String, dynamic>>[].obs;
  var movementHistory = <StockMovement>[].obs;

  final drivers = ["Amadou O. (TVS King)", "Seydou K. (Bajaj)", "Moussa T. (TVS King)"];
  var selectedDriver = "".obs;
  final suppliers = ["Usine SODIGAZ", "Usine TOTAL", "Usine ORYX", "SONABHY (Mixte)"];
  var selectedSupplier = "".obs;

  // --- LOGIQUE DE FILTRE PAR DROPDOWN ---
  var selectedBrand = "TOUS LES PRODUITS".obs;
  var searchQuery = "".obs; 

  List<StockItem> get filteredStock {
    if (selectedBrand.value == "TOUS LES PRODUITS") {
      return depotStock;
    } else {
      // Filtre sur la marque sélectionnée dans le dropdown
      return depotStock.where((item) => item.brand == selectedBrand.value).toList();
    }
  }

  void updateSelectedBrand(String brand) => selectedBrand.value = brand;
  // --------------------------------------

  @override
  void onInit() {
    super.onInit();
    selectedDriver.value = drivers[0];
    selectedSupplier.value = suppliers[0];
    getProduits();
    getSessions(); 
  }
  
Future<void> getProduits() async {
  try {
    final response = await apiService.getProduits(); 
    if (response != null && response is List) {  
      List<StockItem> fetchedItems = response.map((item) {
        
        // --- NOUVELLE EXTRACTION DES PRIX (Objet 'tarif' direct) ---
        double pRecharge = 0.0;
        double pVente = 0.0;
        double pEchange = 0.0;

        if (item['tarif'] != null) {
          var t = item['tarif'];
          pRecharge = double.tryParse(t['price_recharge']?.toString() ?? '0') ?? 0.0;
          pVente    = double.tryParse(t['price_vente']?.toString() ?? '0') ?? 0.0;
          pEchange  = double.tryParse(t['price_echange']?.toString() ?? '0') ?? 0.0;
        }

        // --- EXTRACTION DES STOCKS ---
        int qtePlein = 0;
        int qteVide = 0;
        int qteAvarie = 0;

        if (item['stock'] != null) {
          var s = item['stock'];
          qtePlein  = int.tryParse(s['recharge']?.toString() ?? '0') ?? 0;
          qteVide   = int.tryParse(s['vente']?.toString() ?? '0') ?? 0;
          qteAvarie = int.tryParse(s['echange']?.toString() ?? '0') ?? 0;
        }

        return StockItem(
          id: item['id'].toString(), 
          brand: item['marque_name'] ?? item['name'] ?? "Inconnu",
          type: "${item['poids_value'] ?? '0'} kg",
          full: qtePlein,
          empty: qteVide,
          damaged: qteAvarie,
          imageUrl: item['image'], 
          price: pRecharge, 
          priceVente: pVente,
          priceEchange: pEchange,
        );
      }).toList();
      
      depotStock.assignAll(fetchedItems);
    }
  } catch (e) {
    print("Erreur mapping: $e");
    Alerte.show(title: "Erreur", message: "Problème de lecture des prix", color: Colors.red);
  }
}

  Future<void> getStocks() async {
    try {
      LoadingModal.show();
      final response = await apiService.getStocks(); 
      if (response != null && response is List) {
        List<StockItem> fetchedItems = response.map((item) {
          return StockItem(
            id: item['id'].toString(),
            brand: item['produit_nom'] ?? "Produit inconnu",
            type: "Gaz", 
            full: (item['quantite_recharge_charger'] as num).toInt(), 
            empty: (item['quantite_recharge_vide'] as num).toInt(),   
            damaged: 0,
            imageUrl: item['produit_image'], 
            price: (item['produit_tarif'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
        chargementStock.assignAll(fetchedItems); 
      }
    } catch (e) {
      Alerte.show(title: "Erreur", message: e.toString(), color: Colors.red, imagePath: "assets/images/error.png");
    } finally {
      LoadingModal.hide();
    }
  }

  Future<void> getSessions() async {
    try {
      final response = await apiService.getSession(); 
      if (response != null && response is List) {
        sessionsList.assignAll(List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      print("Erreur sessions: $e");
    }
  }

  Future<void> createSession({required List<Map<String, dynamic>> items}) async {
    try {
      LoadingModal.show();
      final bool success = await apiService.createSession(items: items);
      if (success) {
        LoadingModal.hide();
        Alerte.show(
          title: "Opération réussie",
          message: "La session de chargement a été créée avec succès.",
          imagePath: "assets/images/success.png", 
          color: Colors.green,
        );
        await getProduits(); 
      } else {
       LoadingModal.hide();
        Alerte.show(title: "Erreur", message: "Échec de création.", imagePath: "assets/images/error.png", color: Colors.red);
      }
    } catch (e) {
      LoadingModal.hide();
      Alerte.show(title: "Erreur réseau", message: "Problème serveur.", imagePath: "assets/images/error.png", color: Colors.red);
    } finally {
      LoadingModal.hide();
    }
  }

  void logMovement(String type, String target, String desc, Color color) {
    movementHistory.insert(0, StockMovement(type, target, desc, color));
  }

  void processDamage(StockItem item, bool isFull) {
    if (isFull && item.fullCount.value > 0) {
      item.fullCount.value--;
      item.damagedCount.value++;
      logMovement("AVARIE", "Interne", "Pleine isolée", Colors.red);
    } else if (!isFull && item.emptyCount.value > 0) {
      item.emptyCount.value--;
      item.damagedCount.value++;
      logMovement("AVARIE", "Interne", "Vide isolée", Colors.red);
    }
  }

  void pl(Map<String,int> q) { 
    q.forEach((k,v){if(v>0){var p=k.split('_'); depotStock.firstWhere((i)=>i.brand==p[0]&&i.type==p[1]).fullCount.value-=v;}}); 
    logMovement("CHARGEMENT", selectedDriver.value, "Sortie Stock", Colors.blue); 
  }
}

class StockItem {
  final String id, brand, type;
  final String? imageUrl;
  final double price;        // Prix recharge
  final double priceVente;   // Prix bouteille complète
  final double priceEchange; // Prix échange
  var fullCount = 0.obs;
  var emptyCount = 0.obs;
  var damagedCount = 0.obs;

  StockItem({
    required this.id, 
    required this.brand, 
    required this.type, 
    required int full, 
    required int empty, 
    required int damaged, 
    this.imageUrl, 
    this.price = 0.0,
    this.priceVente = 0.0,
    this.priceEchange = 0.0,
  }) {
    fullCount.value = full;
    emptyCount.value = empty;
    damagedCount.value = damaged;
  }
}

class StockMovement {
  final DateTime date;
  final String type, target, description;
  final Color color;
  StockMovement(this.type, this.target, this.description, this.color, {DateTime? date}) : this.date = date ?? DateTime.now();
}