import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../appColors/appColors.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // --- HEADER IMAGE ---
                    _buildHeaderImage(context),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildWelcomeText(),
                          const SizedBox(height: 40),
                          _buildModernField(child: _buildPhoneField()),
                          const SizedBox(height: 15),
                          _buildModernField(child: _buildPasswordField()),
                          
                          // --- BOUTON MOT DE PASSE OUBLIÉ ---
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.PASSWORDFORGET);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Mot de passe oublié ?",
                                style: TextStyle(
                                  color: AppColors.generalColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),

                    // --- FOOTER (Poussé vers le bas) ---
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: _buildAppSource("By Elite IT Partners"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- COMPONENT WIDGETS ---

  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.30,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/pub2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    const subtitleStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w800,
      color: Colors.grey,
      letterSpacing: 1.2,
    );
    return Column(
      children: [
        Text(
          "Bienvenue sur NAFAGAZ",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(height: 5),
        const Text("L'ÉNERGIE QUI VOUS RAPPROCHE", style: subtitleStyle),
        const Text("ESPACE DE GESTION DES OPÉRATIONS", style: subtitleStyle),
      ],
    );
  }

  Widget _buildModernField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: child,
    );
  }

  // Champ Téléphone mis à jour
  Widget _buildPhoneField() {
    return Obx(() => TextField(
      controller: controller.matriculeController,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration(
          label: "Téléphone", 
          hint: "Votre numéro", 
          icon: Icons.phone_android,
          errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
      ),
    ));
  }

  // Champ Mot de passe mis à jour
  Widget _buildPasswordField() {
    return Obx(() => TextField(
          controller: controller.passwordController,
          obscureText: controller.isPasswordHidden.value,
          decoration: _inputDecoration(
            label: "Mot de passe",
            hint: "••••••••",
            icon: Icons.lock_outline_rounded,
            errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
            suffix: IconButton(
              icon: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ));
  }

  InputDecoration _inputDecoration({
    required String label, 
    required String hint, 
    required IconData icon, 
    Widget? suffix,
    String? errorText, 
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      hintText: hint,
      labelText: label,
      errorText: errorText, // Affiche le message en rouge en bas
      errorStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10,color: Colors.red), // Style du message rouge
      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10),
      prefixIcon: Icon(icon, color: AppColors.generalColor, size: 22),
      suffixIcon: suffix,
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: AppColors.generalColor.withOpacity(0.3))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: AppColors.generalColor, width: 1.5)),
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
      floatingLabelStyle: TextStyle(color: AppColors.generalColor, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: AppColors.generalColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.generalColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: const Text("Se connecter",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppSource(String appSource) {
    return Text(
      appSource.toUpperCase(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 8,
        color: Colors.grey,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  
}