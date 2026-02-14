import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/routes/app_routes.dart';
import '../../../questionModal/questionModal.dart';
import '../../../appColors/appColors.dart';
class ActivityLog {
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  ActivityLog(this.time, this.title, this.subtitle, this.icon, this.color);
}

class ManagerController extends GetxController {
  final String depotName = "Dépôt Central - Pissy";
  
  // KPI FINANCIERS
  var cashBalance = 1250000.obs;
  var dailyBottleSales = 142.obs;
  var dailyTarget = 200; 
  // ALERTES
  var pendingOrders = 3.obs;
  var activeIssues = 1.obs;
  // FLOTTE
  var activeTricycles = 5.obs;
  var totalTricycles = 8.obs;
  // STOCK CRITIQUE (Exemple : Ce qu'il faut commander d'urgence)
  var lowStockItems = <Map<String, String>>[
    {"name": "Total B6", "qty": "Reste 5"},
    {"name": "Oryx B12", "qty": "Reste 2"},
  ].obs;

  // FIL D'ACTUALITÉ (LIVE FEED)
  var recentActivities = <ActivityLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadLiveFeed();
  }

  void _loadLiveFeed() {
    recentActivities.value = [
      ActivityLog("10:42", "Vente Réussie", "Amadou a vendu 5x Sodigaz B12", Icons.check_circle, Colors.green),
      ActivityLog("10:30", "Retour Tricycle", "Seydou est rentré au dépôt", Icons.home, Colors.blue),
      ActivityLog("10:15", "Alerte Stock", "Stock Total B6 critique (<10)", Icons.warning, Colors.orange),
      ActivityLog("09:50", "Départ Course", "Moussa vers Ouaga 2000", Icons.electric_rickshaw, Colors.indigo),
    ];
  }

  // NAVIGATION VIA ALERTES
  void goToDispatch({int initialTab = 0}) => Get.toNamed(Routes.MANAGER_DISPATCH, arguments: initialTab);
  
 void logout() {
  DialogLogout.show(
    title: "Déconnexion",
    message: "Voulez-vous vraiment vous déconnecter de votre compte NAFA PRO ?",
    imagePath: "assets/images/logout.png",
    color: AppColors.generalColor,
    onConfirm: () {
      Get.offAllNamed(Routes.LOGIN);
    },
  );

}

  

  String formatCurrency(int amount) => amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
}
