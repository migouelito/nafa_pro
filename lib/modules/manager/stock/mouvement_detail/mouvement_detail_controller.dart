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
    if (currentId == null) return;

    try {
      LoadingModal.show();
      final bool success = await apiService.updateMouvement(currentId, body);
      LoadingModal.hide();

      if (success) {
        Get.back(); 
          Alerte.show(
            title: "Succès",
            message: "Mise à jour effectuée",
            imagePath: "assets/images/success.png",
            color: Colors.green,
          );
        getMouvementDetail(currentId); 
      } else {
        Alerte.show(
          title: "Erreur",
          message: "Échec de la modification",
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