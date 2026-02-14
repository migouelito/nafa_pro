import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  // Contrôleurs de texte
  final nameController = TextEditingController(text: "Moussa Koné");
  final emailController = TextEditingController();
  final whatsappController = TextEditingController();
  final phoneController = TextEditingController(text: "+226 70 12 34 56");

  void updateProfile() {
    // Logique de sauvegarde API ici
    Get.back();
    Get.snackbar(
      "Succès", 
      "Profil mis à jour avec succès !",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
    );
  }

  void pickImage() {
    Get.snackbar("Photo", "Ouverture de la galerie...");
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    whatsappController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}