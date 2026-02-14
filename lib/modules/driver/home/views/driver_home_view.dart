import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/modules/driver/home/controllers/driver_home_controller.dart';
import 'package:nafa_pro/modules/driver/overview/views/driver_overview_view.dart';
import 'package:nafa_pro/modules/driver/dashboard/views/driver_view.dart';
import 'package:nafa_pro/modules/driver/profile/views/driver_profile_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../appColors/appColors.dart';

class DriverHomeView extends GetView<DriverHomeController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: [
          const DriverOverviewView(),
          const DriverView(),
          const DriverProfileView(),
        ],
      )),
      bottomNavigationBar: Obx(() => NavigationBar(
        backgroundColor: Color(0XFFFFFFFF),
        selectedIndex: controller.currentIndex.value,
        onDestinationSelected: controller.changeTab,
        indicatorColor: AppColors.generalColor.withOpacity(0.2),
        destinations:  [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house()),
            selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill), color:AppColors.generalColor),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color:AppColors.generalColor),
            label: 'Missions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.generalColor),
            label: 'Profil',
          ),
        ],
      )),
    );
  }
}
