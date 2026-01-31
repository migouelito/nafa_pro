import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/apiServices.dart';
import '../../../loading/loading.dart';
import '../../../alerte/alerte.dart';


// Modèle pour capturer les saisies du formulaire de clôture
class ClotureItemInput {
  final String id; // Ajout de l'ID technique de l'item
  final String stockId;
  final TextEditingController qPleine;
  final TextEditingController qVide;
  final TextEditingController qVendu;
  final TextEditingController qEchange; // Ajout du champ échange

  ClotureItemInput({
    required this.id,
    required this.stockId, 
    required this.qPleine, 
    required this.qVide, 
    required this.qVendu,
    required this.qEchange,
  });
}

class DetailSessionController extends GetxController {
  final ApiService apiService = ApiService();
  
  var session = Rxn<Map<String, dynamic>>();
  var isLoading = true.obs;

  // Liste observable pour stocker les contrôleurs de saisie du modal
  var clotureItems = <ClotureItemInput>[].obs;

  @override
  void onInit() {
    super.onInit();
    final String? sessionId = Get.arguments;
    if (sessionId != null) {
      fetchDetails(sessionId);
    }
  }

  Future<void> fetchDetails(String id) async { 
    try {
      isLoading(true);
      final data = await apiService.detailSession(id);
      if (data != null) {
        session.value = data;
      }


      print("======================$data");
    } catch (e) {
      print("Erreur fetchDetails: $e");
    } finally {
      isLoading(false);
    }
  }


  // Initialise les champs de texte pour chaque produit de la session
 void prepareClotureFields() {
    final items = session.value?['items'] as List? ?? [];
    clotureItems.assignAll(items.map((item) => ClotureItemInput(
      id: item['id']?.toString() ?? "", 
      stockId: item['stock']?.toString() ?? "",
      qPleine: TextEditingController(text: "0"),
      qVide: TextEditingController(text: "0"),
      qVendu: TextEditingController(text: "0"),
      qEchange: TextEditingController(text: "0"),
    )).toList());
  }

 Future<void> submitCloture() async {
  final String? sessionId = session.value?['id'];
  if (sessionId == null) return;

  // --- VALIDATION DES DONNÉES ---
  for (var item in clotureItems) {
    if (item.qPleine.text.isEmpty ||
        item.qVide.text.isEmpty ||
        item.qVendu.text.isEmpty ||
        item.qEchange.text.isEmpty) {
      Alerte.show(
        title: "Validation requise",
        message: "Veuillez remplir tous les champs",
        imagePath: "assets/images/error.png",
        color: Colors.red,
      );
      return;
    }
  }

  try {
    LoadingModal.show();

    // --- BODY À ENVOYER ---
    final Map<String, dynamic> dataToSend = {
      "items": clotureItems.map((item) => {
            "id": item.id,
            "stock": item.stockId,
            "quantite_cloture_charger":
                int.tryParse(item.qPleine.text) ?? 0,
            "quantite_cloture_vide":
                int.tryParse(item.qVide.text) ?? 0,
            "quantite_vendu":
                int.tryParse(item.qVendu.text) ?? 0,
            "quantite_echanger":
                int.tryParse(item.qEchange.text) ?? 0,
          }).toList()
    };

    final result =
        await apiService.clotureSession(sessionId, dataToSend);
    
    LoadingModal.hide();

    if (result != null) {
      Get.back();
      Alerte.show(
        title: "Succès",
        message: "Session clôturée avec succès",
        imagePath: "assets/images/success.png",
        color: Colors.green,
      );
      fetchDetails(sessionId);
    } else {
      Alerte.show(
        title: "Erreur",
        message: "Échec de la clôture de la session",
        imagePath: "assets/images/error.png",
        color: Colors.red,
      );
    }
  } catch (e) {
    LoadingModal.hide();
    Alerte.show(
      title: "Erreur",
      message: "Erreur lors de la clôture",
      imagePath: "assets/images/error.png",
      color: Colors.red,
    );
  }
}


  // --- UTILITAIRES ---

  String formatQty(dynamic qty) {
    if (qty == null) return "0";
    // Gestion de l'overflow backend (-9223372036854776000)
    if (qty is int && (qty < -1000000 || qty > 1000000)) return "0";
    return qty.toString();
  }
}