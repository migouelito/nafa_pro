import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profil_controller.dart';
import '../../../appColors/appColors.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.generalColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Modifier mon profil",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildAvatarSection(primaryColor),
            const SizedBox(height: 40),
            _buildField(
                label: "Nom complet",
                icon: Icons.person_outline,
                ctrl: controller.nameController),
            const SizedBox(height: 20),
            _buildField(
                label: "Adresse Email",
                icon: Icons.email_outlined,
                ctrl: controller.emailController,
                type: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildField(
                label: "Numéro WhatsApp",
                icon: Icons.chat_outlined,
                ctrl: controller.whatsappController,
                type: TextInputType.phone),
            const SizedBox(height: 20),
            _buildLockedField(),
            const SizedBox(height: 15),
            const Text(
              "Pour changer votre numéro de connexion, veuillez contacter le support.",
              style: TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      // ⚡ LE BOUTON EST DÉPLACÉ ICI POUR RESTER FIXE EN BAS
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
        ),
        child: ElevatedButton(
          onPressed: controller.updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: const Text(
            "ENREGISTRER LES MODIFICATIONS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(Color color) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: color.withOpacity(0.1),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: color,
              child: const Text("MK",
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ]),
                child: const Icon(Icons.camera_alt, color: Colors.grey, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(
      {required String label,
      required IconData icon,
      required TextEditingController ctrl,
      TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.generalColor, size: 22),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                BorderSide(color: AppColors.generalColor, width: 1.5)),
      ),
    );
  }

  Widget _buildLockedField() {
    return TextField(
      controller: controller.phoneController,
      enabled: false,
      decoration: InputDecoration(
        labelText: "Numéro de connexion",
        prefixIcon: const Icon(Icons.phone_locked, color: Colors.grey, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}