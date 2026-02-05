import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/apiServices.dart';
import '../../../loading/loading.dart';
import '../../../alerte/alerte.dart';

class ClotureItemInput {
  final String id;
  final String stockId;
  final String productName; 
  final TextEditingController qPleineRecharge;
  final TextEditingController qVideRecharge;
  final TextEditingController qPleineEchange;
  final TextEditingController qVideEchange;
  final TextEditingController qPleineVente;
  final TextEditingController qVideVente;

  ClotureItemInput({
    required this.id,
    required this.stockId,
    required this.productName,
    required this.qPleineRecharge,
    required this.qVideRecharge,
    required this.qPleineEchange,
    required this.qVideEchange,
    required this.qPleineVente,
    required this.qVideVente,
  });
}

class DetailSessionController extends GetxController {
  final ApiService apiService = ApiService();
  var session = Rxn<Map<String, dynamic>>();
  var isLoading = true.obs;
  var clotureItems = <ClotureItemInput>[].obs;

  @override
  void onInit() {
    super.onInit();
    final String? sessionId = Get.arguments;
    if (sessionId != null) fetchDetails(sessionId);
  }

  Future<void> fetchDetails(String id) async {
    try {
      isLoading(true);
      final data = await apiService.detailSession(id);

      print("=============detail$data");
      if (data != null) session.value = data;
    } catch (e) {
      print("Erreur fetchDetails: $e");
    } finally {
      isLoading(false);
    }
  }

 void prepareClotureFields() {
  final items = session.value?['items'] as List? ?? [];
  clotureItems.assignAll(items.map((item) {
    return ClotureItemInput(
      id: item['id']?.toString() ?? "",
      stockId: item['stock']?.toString() ?? "",
      productName: item['produit_nom'] ?? "Produit",
      // REMPLISSAGE AVEC LES DONNÉES RÉELLES DE CLÔTURE DU JSON
      qPleineRecharge: TextEditingController(text: formatQty(item['quantite_cloture_recharge_charger'])),
      qVideRecharge: TextEditingController(text: formatQty(item['quantite_cloture_recharge_vide'])),
      qPleineEchange: TextEditingController(text: formatQty(item['quantite_cloture_echange_charger'])),
      qVideEchange: TextEditingController(text: formatQty(item['quantite_cloture_echange_vide'])),
      qPleineVente: TextEditingController(text: formatQty(item['quantite_cloture_vente_charger'])),
      qVideVente: TextEditingController(text: formatQty(item['quantite_cloture_vente_vide'])),
    );
  }).toList());
}

  Future<void> submitCloture() async {
    final String? sessionId = session.value?['id'];
    if (sessionId == null) return;

    try {
      LoadingModal.show();
      final Map<String, dynamic> dataToSend = {
        "items": clotureItems.map((item) => {
          "id": item.id,
          "stock": item.stockId,
          "quantite_cloture_recharge_charger": int.tryParse(item.qPleineRecharge.text) ?? 0,
          "quantite_cloture_recharge_vide": int.tryParse(item.qVideRecharge.text) ?? 0,
          "quantite_cloture_echange_charger": int.tryParse(item.qPleineEchange.text) ?? 0,
          "quantite_cloture_echange_vide": int.tryParse(item.qVideEchange.text) ?? 0,
          "quantite_cloture_vente_charger": int.tryParse(item.qPleineVente.text) ?? 0,
          "quantite_cloture_vente_vide": int.tryParse(item.qVideVente.text) ?? 0,
        }).toList()
      };
      print('=========================data$dataToSend');
      final result = await apiService.clotureSession(sessionId, dataToSend);
      LoadingModal.hide();

      if (result != null) {
        Get.back();
        Alerte.show(title: "Succès", message: "Clôture enregistrée", color: Colors.green, imagePath: "assets/images/success.png");
        fetchDetails(sessionId);
      }
    } catch (e) {
      LoadingModal.hide();
      Alerte.show(title: "Erreur", message: "Erreur technique", color: Colors.red, imagePath: "assets/images/error.png");
    }
  }

  String formatQty(dynamic qty) {
    if (qty == null) return "0";
    String val = qty.toString();
    if (val.startsWith("-922337")) return "0"; 
    return val;
  }
}