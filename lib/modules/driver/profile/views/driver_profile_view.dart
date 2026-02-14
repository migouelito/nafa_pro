import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
import 'package:nafa_pro/routes/app_routes.dart';
import '../../home/controllers/driver_home_controller.dart';

class DriverProfileView extends GetView<DriverHomeController> {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("MON PROFIL"),  elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             CircleAvatar(radius: 50, backgroundColor: AppColors.generalColor, child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 15),
            Text(controller.driverName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Livreur Tricycle ⭐ 4.8", style: TextStyle(color: Colors.grey.shade600)),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.electric_rickshaw, color: Colors.black87), // ICÔNE TRICYCLE
                  const SizedBox(width: 15),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Véhicule assigné", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(controller.vehicleInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])
                ],
              ),
            ),

            const SizedBox(height: 30),

            // LIENS VERS LES NOUVELLES PAGES
            _buildMenuItem("Historique des courses", Icons.history, () => Get.toNamed(Routes.DRIVER_HISTORY)),
            _buildMenuItem("Mes Performances", Icons.bar_chart, () => Get.toNamed(Routes.DRIVER_PERFORMANCE)),
            _buildMenuItem("Support & Urgence", Icons.headset_mic, () => Get.toNamed(Routes.DRIVER_SUPPORT)),
            
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 55, child: OutlinedButton.icon(onPressed: controller.logout, icon: const Icon(Icons.logout, color: Colors.red), label: const Text("SE DÉCONNECTER", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
            const SizedBox(height: 20),
            const Text("Version 2.2.0 (Pro - Tricycle)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
