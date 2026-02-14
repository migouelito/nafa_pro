import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final phoneController = TextEditingController();
  
  // Observable pour l'erreur
  var phoneError = "".obs;

  void sendOtp() {
    String phone = phoneController.text.trim();
    phoneError.value = ""; // Réinitialiser l'erreur

    if (phone.length >= 8) {
      Get.toNamed('/otp', arguments: phone);
    } else {
      // Afficher l'erreur sous le champ au lieu d'un snackbar
      phoneError.value = "Veuillez entrer un numéro valide";
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}