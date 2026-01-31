import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../questionModal/questionModal.dart';
import '../../appColors/appColors.dart';
import '../../services/apiServices.dart';

class ProfilController extends GetxController {
  
  final String userName = "Moussa Koné";
  final String userPhone = "+226 70 12 34 56";
  final String version = "1.0.0";
  
  final apiService = ApiService();
  /// FONCTION DE DÉCONNEXION SÉCURISÉE
  void confirmLogout() {
    DialogLogout.show(
      title: "Se déconnecter ?",
      message: "Vous devrez saisir votre PIN ou utiliser votre empreinte pour vous reconnecter.",
      imagePath: "assets/images/logout.png", 
      color: AppColors.generalColor,
      onConfirm: () async {
        try {
          await apiService.logout();
        } catch (e) {
          debugPrint("Erreur lors de la déconnexion API: $e");
        } finally {
        
          Get.offAllNamed(Routes.LOGIN);
        }
      },
    );
  }
}