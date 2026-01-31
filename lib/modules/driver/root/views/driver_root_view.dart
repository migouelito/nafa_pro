import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_root_controller.dart';
import '../../home/views/driver_home_view.dart';
import '../../missions/views/missions_view.dart';
import '../../truck/views/truck_view.dart';
import '../../wallet/views/wallet_view.dart';

class DriverRootView extends GetView<DriverRootController> {
  const DriverRootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          DriverHomeView(), // 0: Accueil (Statut)
          MissionsView(),   // 1: Courses
          TruckView(),      // 2: Stock Tricycle
          WalletView(),     // 3: Portefeuille Gains
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange, // Couleur Livreur (Orange/Noir)
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.electric_rickshaw), label: 'Go'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Missions'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Gains'),
          ],
        ),
      )),
    );
  }
}
