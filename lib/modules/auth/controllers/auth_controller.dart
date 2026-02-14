import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../loading/loading.dart';
import '../../alerte/alerte.dart';
import '../../services/apiServices.dart';

class AuthController extends GetxController {
  final ApiService apiService = ApiService(); 

  final matriculeController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  
  // Nouveaux observables pour les erreurs
  var phoneError = "".obs;
  var passwordError = "".obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  bool validateFields() {
    // Réinitialiser les erreurs
    phoneError.value = "";
    passwordError.value = "";

    bool isValid = true;

    if (matriculeController.text.trim().isEmpty) {
      phoneError.value = "Veuillez entrer votre numéro";
      isValid = false;
    }
    if (passwordController.text.trim().isEmpty) {
      passwordError.value = "Veuillez entrer votre mot de passe";
      isValid = false;
    }
    return isValid;
  }

  Future<void> login() async {
    if (!validateFields()) return;

    try {
      LoadingModal.show();
      
      phoneError.value = "";
      passwordError.value = "";

      final dataconnexion = {
        "phone": "+226${matriculeController.text.trim()}",
        "password": passwordController.text.trim(),
      };

      final result = await apiService.login(dataconnexion);

      if (result) {
        LoadingModal.hide();
        Get.offAllNamed('/manager/home');
      } else {
        LoadingModal.hide(); 
        phoneError.value = " "; 
        passwordError.value = "Identifiants incorrects";
      }
    } catch (e) {
      LoadingModal.hide();
      Alerte.show(
        title: "Erreur",
        message: "Problème de communication avec le serveur.",
        color: Colors.red,
      );
    }
  }
}