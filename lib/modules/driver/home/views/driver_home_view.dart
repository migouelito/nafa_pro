import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/modules/driver/home/controllers/driver_home_controller.dart';
import 'package:nafa_pro/modules/driver/overview/views/driver_overview_view.dart';
import 'package:nafa_pro/modules/driver/dashboard/views/driver_view.dart';
import 'package:nafa_pro/modules/driver/profile/views/driver_profile_view.dart';

class DriverHomeView extends GetView<DriverHomeController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: [ // J'ai retiré le const ici pour éviter l'erreur de compilation
          const DriverOverviewView(),
          const DriverView(),
          const DriverProfileView(),
        ],
      )),
      bottomNavigationBar: Obx(() => NavigationBar(
        backgroundColor: Color(0XFFFFFFFF),
        selectedIndex: controller.currentIndex.value,
        onDestinationSelected: controller.changeTab,
        indicatorColor: const Color(0xFF00A86B).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            selectedIcon: Icon(Icons.grid_view, color: Color(0xFF00A86B)),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Color(0xFF00A86B)),
            label: 'Missions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF00A86B)),
            label: 'Profil',
          ),
        ],
      )),
    );
  }
}
