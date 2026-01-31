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

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  bool validateFields() {
    if (matriculeController.text.trim().isEmpty) {
      Get.snackbar("Erreur", "Veuillez entrer votre matricule",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar("Erreur", "Veuillez entrer votre mot de passe",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    return true;
  }

 Future<void> login() async {
  if (!validateFields()) return;

  try {
    LoadingModal.show();

    final dataconnexion = {
      "phone": "+226${matriculeController.text.trim().toUpperCase()}",
      "password": passwordController.text.trim(),
    };

    final result = await apiService.login(dataconnexion);
      print(result);
    print("Résultat login: $result");

    if (result) {
      // Succès : on ferme le loader et on change de page
      LoadingModal.hide();
      Get.offAllNamed('/manager/home');
    } else {
      LoadingModal.hide(); 
      Alerte.show(
        title: "Erreur d'authentification",
        message: "Matricule ou mot de passe incorrect",
        imagePath: "assets/images/error.png",
        color: Colors.red,
      );
    }
  } catch (e) {
    LoadingModal.hide();
    Alerte.show(
      title: "Erreur de connexion",
      message: "Problème de communication avec le serveur.",
      imagePath: "assets/images/error.png",
      color: Colors.red,
    );
  }
}
  @override
  void onClose() {
    matriculeController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}