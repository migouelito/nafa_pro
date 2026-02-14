import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'password_forget_controller.dart';
import '../appColors/appColors.dart';

class PasswordForgetView extends GetView<ForgotPasswordController> {
  const PasswordForgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("RÉCUPÉRATION MOT DE PASSE",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Entrez votre numéro de téléphone. Un code de vérification (OTP) vous sera envoyé pour réinitialiser votre accès.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),

            // --- CHAMP TÉLÉPHONE AVEC OBX ---
            Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (val) => controller.phoneError.value = "", // Efface l'erreur quand on tape
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: _buildInputDecoration(
                  label: "Téléphone",
                  hint: "Ex: 01020304",
                  icon: Icons.phone_android,
                  errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
                ),
              ),
            )),

            const Spacer(), 

            // --- BOUTON D'ACTION ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => controller.sendOtp(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.generalColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "Envoyer le code",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? errorText, // Ajout du paramètre
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      hintText: hint,
      labelText: label,
      errorText: errorText,
      // --- STYLE DE L'ERREUR EN ROUGE ---
      errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      prefixIcon: Icon(icon, color: AppColors.generalColor, size: 22),
      
      // Bordures en cas d'erreur
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.generalColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.generalColor, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
      floatingLabelStyle: TextStyle(color: AppColors.generalColor, fontWeight: FontWeight.bold),
    );
  }
}