import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/safety_controller.dart';

class SafetyView extends GetView<SafetyController> {
  const SafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Fond sombre pro
      appBar: AppBar(
        title: const Text("DÉPART MISSION"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vérification Tricycle & Gaz",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Cochez chaque bloc pour certifier la conformité.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // BLOC 1 : PILOTE
            Obx(() => _buildSafetyCard(
              title: "ÉQUIPEMENTS PILOTE (EPI)",
              description: "• Casque attaché\n• Chaussures fermées\n• Téléphone chargé",
              icon: Icons.person,
              isChecked: controller.epiChecked.value,
              onTap: controller.toggleEpi,
            )),

            // BLOC 2 : VÉHICULE
            Obx(() => _buildSafetyCard(
              title: "ÉTAT DU TRICYCLE",
              description: "• Freins fonctionnels\n• Pneus gonflés\n• Phares & Clignotants OK",
              icon: Icons.electric_rickshaw,
              isChecked: controller.vehicleChecked.value,
              onTap: controller.toggleVehicle,
            )),

            // BLOC 3 : CHARGEMENT (CRITIQUE)
            Obx(() => _buildSafetyCard(
              title: "SÉCURITÉ GAZ",
              description: "• Extincteur présent\n• Bouteilles arrimées\n• Aucune odeur de fuite",
              icon: Icons.propane_tank,
              isChecked: controller.loadChecked.value,
              onTap: controller.toggleLoad,
              isCritical: true, // Couleur rouge si pas coché
            )),

            const SizedBox(height: 40),

            // BOUTON ACTION
            Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: controller.isValid ? controller.submitSafetyCheck : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  disabledBackgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: const Text("JE CERTIFIE & JE DÉMARRE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )),
            
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Toute fausse déclaration engage votre responsabilité.",
                style: TextStyle(color: Colors.grey, fontSize: 10),
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
    bool isCritical = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isChecked 
              ? const Color(0xFF00A86B).withOpacity(0.15) 
              : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isChecked 
                ? const Color(0xFF00A86B) 
                : (isCritical ? Colors.red.withOpacity(0.5) : Colors.transparent),
            width: isChecked ? 2 : 1
          )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icone
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF00A86B) : Colors.black,
                shape: BoxShape.circle
              ),
              child: Icon(
                isChecked ? Icons.check : icon, 
                color: Colors.white, 
                size: 24
              ),
            ),
            const SizedBox(width: 15),
            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(description, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
