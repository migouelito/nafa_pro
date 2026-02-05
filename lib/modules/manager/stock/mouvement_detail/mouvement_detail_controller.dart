import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/apiServices.dart';
import '../../../loading/loading.dart';
import '../../../alerte/alerte.dart';

class MouvementDetailController extends GetxController {
  final apiService = ApiService();
  var mouvement = Rxn<Map<String, dynamic>>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final String? moveId = Get.arguments;
    if (moveId != null) {
      getMouvementDetail(moveId);
    }
  }

  Future<void> getMouvementDetail(String id) async {
    try {
      isLoading(true);
      final response = await apiService.getMouvementDetail(id);
      if (response != null) {
        mouvement.value = response;
      }
    } catch (e) {
      print("Erreur détails: $e");
    } finally {
      isLoading(false);
    }
  }

Future<void> updateMouvement({
    required String type, 
    required Map<String, dynamic> body
  }) async {
    final String? currentId = mouvement.value?['id'];
    
    // Si ce n'est pas un remboursement, on a besoin de l'ID actuel pour modifier
    if (type != "REMBOURSEMENT" && currentId == null) return;

    try {
      LoadingModal.show();
      
      bool success = false;

      if (type == "REMBOURSEMENT") {
        // --- CAS Spécifique : REMBOURSEMENT ---
        // On appelle l'API de création (POST) au lieu de modification (PUT/PATCH)
        success = await apiService.createMouvement(body);
      } else {
        // --- CAS GÉNÉRAL : MODIFICATION ---
        success = await apiService.updateMouvement(currentId!, body);
      }

      LoadingModal.hide();

      if (success) {
        Get.back(); // Ferme le modal ou la vue actuelle
        
        Alerte.show(
          title: "Succès",
          message: type == "REMBOURSEMENT" 
              ? "Remboursement enregistré" 
              : "Mise à jour effectuée",
          imagePath: "assets/images/success.png",
          color: Colors.green,
        );

        // Si c'est une modification, on rafraîchit les détails
        if (type != "REMBOURSEMENT" && currentId != null) {
          getMouvementDetail(currentId);
        }
        
        // Optionnel : Si c'est un remboursement, rafraîchir la liste globale
        // Get.find<MouvementController>().refreshList(); 

      } else {
        Alerte.show(
          title: "Erreur",
          message: "L'opération a échoué",
          imagePath: "assets/images/error.png",
          color: Colors.red,
        );
      }
    } catch (e) {
      LoadingModal.hide();
      Alerte.show(
        title: "Erreur",
        message: e.toString(),
        imagePath: "assets/images/error.png",
        color: Colors.red,
      );
    }
  }
}