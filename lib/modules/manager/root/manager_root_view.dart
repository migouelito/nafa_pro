import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manager_root_controller.dart';
import '../dashboard/views/manager_view.dart';
import '../orders/dispatch_view.dart';
import '../fleet/views/fleet_view.dart';
import '../stock/views/stock_view.dart';
import '../finance/views/finance_view.dart';
import '../dashboard/controllers/manager_controller.dart';
import '../orders/dispatch_controller.dart';
import '../fleet/controllers/fleet_controller.dart';
import '../stock/controllers/stock_controller.dart';
import '../finance/controllers/finance_controller.dart';
import '../../appColors/appColors.dart';
import '../profil/profil_view.dart';
import '../profil/profil_controller.dart';

class ManagerRootView extends GetView<ManagerRootController> {
  const ManagerRootView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.generalColor;
    const isDarkMode = false; 

    // Listes mises à jour avec "Profil"
    final List<String> _titles = ['Accueil', 'Dispatch', 'Flotte', 'Stock', 'Finance', 'Profil'];
    final List<IconData> _activeIcons = [
      Icons.home, 
      Icons.alt_route, 
      Icons.map, 
      Icons.inventory_2, 
      Icons.account_balance_wallet,
      Icons.person // Icône Profil active
    ];
    final List<IconData> _inactiveIcons = [
      Icons.home_outlined, 
      Icons.alt_route_outlined, 
      Icons.map_outlined, 
      Icons.inventory_2_outlined, 
      Icons.account_balance_wallet_outlined,
      Icons.person_outline // Icône Profil inactive
    ];

    return Obx(
      () => Scaffold(
        body: _getPage(controller.currentIndex.value),
        
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changePage,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              elevation: 0,
              items: List.generate(_titles.length, (i) => 
                _buildNavItem(i, controller.currentIndex.value, isDarkMode, primaryColor, _titles, _activeIcons, _inactiveIcons)
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(int itemIndex, int selectedIndex, bool isDarkMode, Color primaryColor, List<String> titles, List<IconData> activeIcons, List<IconData> inactiveIcons) {
    final bool isSelected = itemIndex == selectedIndex;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          isSelected ? activeIcons[itemIndex] : inactiveIcons[itemIndex],
          size: 24,
        ),
      ),
      label: titles[itemIndex],
    ); 
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        Get.lazyPut<ManagerController>(() => ManagerController());
        return const ManagerView();
      case 1:
        Get.lazyPut<DispatchController>(() => DispatchController());
        return const DispatchView();
      case 2:
        Get.lazyPut<FleetController>(() => FleetController());
        return const FleetView();
      case 3:
        Get.lazyPut<StockController>(() => StockController());
        return const StockView();
      case 4:
        Get.lazyPut<FinanceController>(() => FinanceController());
        return const FinanceView();
      case 5: // Ajout du cas Profil
        Get.lazyPut<ProfilController>(() => ProfilController());
        return const ProfilView();
      default:
        return const Center(child: Text("Page Inconnue"));
    }
  }
}