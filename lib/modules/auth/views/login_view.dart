import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../appColors/appColors.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
            child: Column(
              children: [
                // --- LOGO : CAMION AVEC BOUTEILLE ORANGE + TEXTE ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Le Camion Transportant la Bouteille Orange
                    Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/nafagaz_truck_orange.png", // Image du camion avec gaz orange
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.local_shipping,
                            color: Color(0xFF003317),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // NAFAGAZ en Vert et Orange
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                        children: [
                          TextSpan(
                            text: "NAFA",
                            style: TextStyle(color: Color(0xFF003317)), // Vert Profond
                          ),
                          TextSpan(
                            text: "GAZ",
                            style: TextStyle(color: Color(0xFFFF5722)), // Orange Bouteille
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Text(
                  "L'ÉNERGIE QUI VOUS RAPPROCHE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 60),

                Text(
                  "Bienvenue sur Nafa Pro",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Espace de gestion des opérations",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),

                const SizedBox(height: 50),

                // Champ Matricule
                _buildModernField(child: _buildMatriculeField()),

                const SizedBox(height: 20),

                // Champ Mot de passe
                _buildModernField(child: _buildPasswordField()),

                const SizedBox(height: 40),

                // Bouton Se connecter
                _buildSubmitButton(),

                const SizedBox(height: 40),

                // Connexion Biométrique
                _buildFingerprintAction(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildAppSource("By Elite IT Partners"),
    );
  }

  // --- COMPOSANTS UI MODERNES ---

  Widget _buildModernField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMatriculeField() {
    return TextField(
      controller: controller.matriculeController,
      decoration: _inputDecoration(
        label: "Téléphone",
        hint: "Ex: LIV01, MGR01",
        icon: Icons.phone_android,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => TextField(
      controller: controller.passwordController,
      obscureText: controller.isPasswordHidden.value,
      decoration: _inputDecoration(
        label: "Mot de passe",
        hint: "••••••••",
        icon: Icons.lock_outline_rounded,
        suffix: IconButton(
          icon: Icon(
            controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF003317).withOpacity(0.7),
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
      ),
    ));
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003317).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003317),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          "Se connecter",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFingerprintAction() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
           Icon(Icons.fingerprint, color: AppColors.generalColor, size: 55),
          const SizedBox(height: 10),
          Text(
            "Utiliser l'empreinte digitale",
            style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSource(String appSource) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          appSource.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
    );
  }

 InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    hintText: hint,
    labelText: label,
    prefixIcon: Icon(icon, color:AppColors.generalColor, size: 24),
    suffixIcon: suffix,

    // ⚡ Bordure normale (pas focus)
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: AppColors.generalColor, // couleur quand pas focus
        width: 1,                      // épaisseur
      ),
    ),

    // ⚡ Bordure quand le champ est focus
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: AppColors.generalColor, // couleur quand focus
        width: 1,
      ),
    ),

    // Label normal
    labelStyle: TextStyle(
      color: Colors.grey[700],
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),

    // Label flottant
    floatingLabelStyle: TextStyle(
      color: AppColors.generalColor, // couleur quand le label flotte
      fontWeight: FontWeight.w700,
      fontSize: 14,
    ),
  );
}

}