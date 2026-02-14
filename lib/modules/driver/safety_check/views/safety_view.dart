import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/safety_controller.dart';
import '../../../appColors/appColors.dart';

class SafetyView extends GetView<SafetyController> {
  const SafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Fond gris très clair
      appBar: AppBar(
        title: const Text(
          "DÉPART MISSION",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF2D3436),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Check-list Sécurité",
              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              "Vérifiez chaque élément avant de prendre la route.",
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 35),

            // BLOC 1 : PILOTE
            Obx(() => _buildSafetyCard(
              title: "ÉQUIPEMENTS PILOTE",
              description: "Casque attaché, chaussures fermées et téléphone chargé.",
              icon: PhosphorIcons.userFocus(PhosphorIconsStyle.fill),
              isChecked: controller.epiChecked.value,
              onTap: controller.toggleEpi,
              activeColor: Colors.blue,
            )),

            // BLOC 2 : VÉHICULE
            Obx(() => _buildSafetyCard(
              title: "ÉTAT DU TRICYCLE",
              description: "Freins, pneus, phares et clignotants opérationnels.",
              icon: PhosphorIcons.truck(PhosphorIconsStyle.fill),
              isChecked: controller.vehicleChecked.value,
              onTap: controller.toggleVehicle,
              activeColor: AppColors.Orange,
            )),

            // BLOC 3 : CHARGEMENT (CRITIQUE)
            Obx(() => _buildSafetyCard(
              title: "SÉCURITÉ GAZ & FUITE",
              description: "Extincteur présent, bouteilles arrimées, aucune odeur.",
              icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
              isChecked: controller.loadChecked.value,
              onTap: controller.toggleLoad,
              isCritical: true,
              activeColor: AppColors.generalColor,
            )),

            const SizedBox(height: 40),

            // BOUTON ACTION
            Obx(() => Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: controller.isValid ? controller.submitSafetyCheck : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.generalColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                child: const Text(
                  "CERTIFIER & DÉMARRER", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                ),
              ),
            )),
            
            const SizedBox(height: 25),
            const Center(
              child: Text(
                "Toute fausse déclaration engage votre responsabilité.",
                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard({
    required String title, 
    required String description, 
    required IconData icon, 
    required bool isChecked, 
    required VoidCallback onTap,
    required Color activeColor,
    bool isCritical = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isChecked ? activeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isChecked 
                  ? activeColor.withOpacity(0.1) 
                  : Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            // Icone stylisée
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isChecked ? activeColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                isChecked ? PhosphorIcons.check(PhosphorIconsStyle.fill) : icon, 
                color: isChecked ? Colors.white : Colors.grey.shade400, 
                size: 26
              ),
            ),
            const SizedBox(width: 20),
            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      color: const Color(0xFF2D3436), 
                      fontWeight: FontWeight.w900, 
                      fontSize: 15,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description, 
                    style: TextStyle(
                      color: isChecked ? Colors.grey.shade400 : Colors.grey.shade600, 
                      fontSize: 12, 
                      height: 1.4,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),
            ),
            // Checkbox visuelle
            Icon(
              isChecked ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.circle(),
              color: isChecked ? activeColor : Colors.grey.shade300,
              size: 24,
            )
          ],
        ),
      ),
    );
  }
}