import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/apiServices.dart';
import '../../../loading/loading.dart';
import '../../../alerte/alerte.dart';
import '../../../appColors/appColors.dart';

class SessionController extends GetxController {
  final apiService = ApiService();
  var isLoading = false.obs;
  
  var sessionsList = <Map<String, dynamic>>[].obs;
  var chargementStock = <Map<String, dynamic>>[].obs;

  var countersRecharge = <String, TextEditingController>{}.obs;
  var countersEchange = <String, TextEditingController>{}.obs;
  var countersVente = <String, TextEditingController>{}.obs;
  var selectedProducts = <String, RxBool>{}.obs;
  final drivers = ["Amadou O. (TVS King)", "Seydou K. (Bajaj)", "Moussa T. (TVS King)"].obs;
  var selectedDriver = "Amadou O. (TVS King)".obs;
  var selectedLivreur = "TOUS LES LIVREURS".obs;

  @override
  void onReady() {
    super.onReady();
    loadSessions();
    getAvailableStock();
  }

  Future<void> loadSessions() async {
    try {
      isLoading(true);
      final response = await apiService.getSession();
      print("=======================$response");
      if (response != null && response is List) {
        sessionsList.assignAll(List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      print("Erreur sessions: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> getAvailableStock() async {
    try {
      final response = await apiService.getStocks();
      if (response != null && response is List) {
        chargementStock.assignAll(List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      print("Erreur stock: $e");
    }
  }

  List<Map<String, dynamic>> get filteredSessions {
    if (selectedLivreur.value == "TOUS LES LIVREURS") {
      return sessionsList.toList();
    } else {
      return sessionsList.where((s) => s['agent_livraison_name'] == selectedLivreur.value).toList();
    }
  }

  void updateSelectedLivreur(String name) => selectedLivreur.value = name;

 
  void prepareNewSession() {
    countersRecharge.clear();
    countersEchange.clear();
    countersVente.clear();
    selectedProducts.clear(); // On réinitialise les sélections

    for (var item in chargementStock) {
      String id = item['id'].toString();
      countersRecharge[id] = TextEditingController(text: "0");
      countersEchange[id] = TextEditingController(text: "0");
      countersVente[id] = TextEditingController(text: "0");
      selectedProducts[id] = false.obs; // Par défaut, non coché
    }
  }
  
  void toggleProduct(String id, bool value) {
    selectedProducts[id]?.value = value;
    if (!value) {
      countersRecharge[id]?.text = "0";
      countersEchange[id]?.text = "0";
      countersVente[id]?.text = "0";
    }
  }


int get selectedCount =>
    selectedProducts.values.where((e) => e.value).length;

  Future<void> submitSession() async {
    List<Map<String, dynamic>> itemsToShip = [];

    for (var item in chargementStock) {
      String id = item['id'].toString();
      int qR = int.tryParse(countersRecharge[id]?.text ?? "0") ?? 0;
      int qE = int.tryParse(countersEchange[id]?.text ?? "0") ?? 0;
      int qV = int.tryParse(countersVente[id]?.text ?? "0") ?? 0;

      // Validation stricte par rapport au stock réel
      int maxR = int.tryParse(item['quantite_recharge_charger']?.toString() ?? "0") ?? 0;
      int maxE = int.tryParse(item['quantite_echange_charger']?.toString() ?? "0") ?? 0;
      int maxV = int.tryParse(item['quantite_vente']?.toString() ?? "0") ?? 0;

      if(qR > maxR || qE > maxE || qV > maxV) {
        Alerte.show(title: "Erreur Stock", message: "Quantité saisie supérieure au stock pour ${item['produit_nom']}", color: Colors.red);
        return;
      }

      if (qR > 0 || qE > 0 || qV > 0) {
        itemsToShip.add({
          "stock": id,
          "quantite_ouverture_recharge": qR,
          "quantite_ouverture_echange": qE,
          "quantite_ouverture_vente": qV
        });
      }
    }

    if (itemsToShip.isEmpty) {
      Alerte.show(title: "Attention", message: "Saisissez au moins une quantité", imagePath: "assets/images/error.png", color: Colors.red);
      return;
    }

    try {
      LoadingModal.show();
      final bool success = await apiService.createSession(items: itemsToShip);
      LoadingModal.hide();
      if (success) {
        if (Get.isBottomSheetOpen ?? false) Get.back();
        Alerte.show(title: "Succès", message: "Chargement validé",imagePath: "assets/images/success.png", color: AppColors.generalColor);
        await loadSessions();
      }
    } catch (e) {
      LoadingModal.hide();
      Alerte.show(title: "Erreur", message: "Échec de l'envoi", color: Colors.red);
    }
  }
}



