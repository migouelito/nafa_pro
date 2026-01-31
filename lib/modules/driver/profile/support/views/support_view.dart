import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("URGENCE & SUPPORT"), backgroundColor: Colors.red, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSosButton("APPELER LA POLICE (17)", Icons.local_police, Colors.red, () => Get.snackbar("Appel", "Composition du 17...")),
            const SizedBox(height: 15),
            _buildSosButton("APPELER LES POMPIERS (18)", Icons.medical_services, Colors.orange, () => Get.snackbar("Appel", "Composition du 18...")),
            
            const Divider(height: 50),
            
            const Text("Problème avec l'application ou une commande ?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.chat, color: Colors.white)),
              title: const Text("Support WhatsApp"),
              subtitle: const Text("Réponse en moins de 5 min"),
              onTap: () => Get.snackbar("WhatsApp", "Ouverture de WhatsApp..."),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.phone, color: Colors.white)),
              title: const Text("Appeler le Responsable Dépôt"),
              subtitle: const Text("M. Ouedraogo"),
              onTap: () => Get.snackbar("Appel", "Appel du responsable..."),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      ),
    );
  }
}
