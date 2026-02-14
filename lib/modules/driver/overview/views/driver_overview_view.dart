import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/routes/app_routes.dart';
import 'package:nafa_pro/modules/driver/home/controllers/driver_home_controller.dart';
import 'package:nafa_pro/modules/driver/dashboard/controllers/driver_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../appColors/appColors.dart';

class DriverOverviewView extends GetView<DriverHomeController> {
  const  DriverOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final mapCtrl = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(PhosphorIcons.truck(PhosphorIconsStyle.fill), color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            const Text("NAFAGAZ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 0.5)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          _buildNotificationIcon(),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            const SizedBox(height: 25),
            _buildOnlineStatusCard(mapCtrl),
            const SizedBox(height: 25),
            _buildStockCard(),
            const SizedBox(height: 25),
            const Text("Tableau de bord", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436))),
            const SizedBox(height: 15),
            _buildPerformanceGrid(),
            const SizedBox(height: 25),
            _buildRouteMapCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: Colors.black, size: 28),
          onPressed: () => Get.toNamed(Routes.DRIVER_NOTIFICATIONS),
        ),
        Positioned(
          right: 12, top: 12,
          child: Container(
            height: 10, width: 10,
            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
          ),
        )
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bonjour, ${controller.driverName.split(' ')[0]} 👋", 
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text("Prêt à rouler ?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildOnlineStatusCard(DriverController mapCtrl) {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mapCtrl.isOnline.value ? AppColors.generalColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mapCtrl.isOnline.value ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: mapCtrl.isOnline.value ? AppColors.generalColor.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 15, offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(
              mapCtrl.isOnline.value ? PhosphorIcons.broadcast(PhosphorIconsStyle.fill) : PhosphorIcons.cloudSlash(PhosphorIconsStyle.fill),
              color: mapCtrl.isOnline.value ? Colors.white : Colors.grey, size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mapCtrl.isOnline.value ? "EN LIGNE" : "HORS LIGNE", 
                  style: TextStyle(color: mapCtrl.isOnline.value ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 18)),
                Text(mapCtrl.isOnline.value ? "Courses activées" : "Mode repos", 
                  style: TextStyle(color: mapCtrl.isOnline.value ? Colors.white70 : Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Switch(
            value: mapCtrl.isOnline.value,
            activeColor: Colors.white,
            activeTrackColor: Colors.white30,
            inactiveThumbColor: Colors.grey.shade400,
            onChanged: (val) => mapCtrl.toggleStatus(val),
          )
        ],
      ),
    ));
  }

  Widget _buildStockCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(18)),
            child: Icon(PhosphorIcons.package(PhosphorIconsStyle.fill), color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("STOCK TRICYCLE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Obx(() => RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16),
                    children: [
                      TextSpan(text: "${controller.totalFullBottles}", style: TextStyle(color: AppColors.generalColor)),
                      const TextSpan(text: " Pleines  •  "),
                      TextSpan(text: "${controller.totalEmptyBottles}", style: const TextStyle(color: Colors.grey)),
                      const TextSpan(text: " Vides"),
                    ],
                  ),
                )),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: controller.showStockDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, foregroundColor: Colors.white,
              elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("DÉTAILS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _buildStatCard(
            "Bonus Dispo", 
            "${controller.availableBonus.value} F", 
            PhosphorIcons.handCoins(PhosphorIconsStyle.fill), 
             AppColors.Orange,
            isBonus: true,
          )),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Obx(() => _buildStatCard(
            "Total Courses", 
            "${controller.completedTrips}", 
            PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill), 
            Colors.blue,
          )),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, {bool isBonus = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              if (isBonus && controller.availableBonus.value >= 5000)
                GestureDetector(
                  onTap: controller.requestBonusWithdrawal,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_upward, color: Colors.white, size: 12),
                  ),
                )
            ],
          ),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRouteMapCard() {
  return InkWell(
    onTap: () => controller.changeTab(1),
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Row(
        children: [
          // Icône avec fond léger coloré
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:Colors.black.withOpacity(0.1), 
              shape: BoxShape.circle
            ),
            child: Icon(
              PhosphorIcons.mapPin(PhosphorIconsStyle.fill), 
              color: Colors.black, 
              size: 26
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FEUILLE DE ROUTE", 
                  style: TextStyle(
                    color: const Color(0xFF2D3436), 
                    fontWeight: FontWeight.w900, 
                    fontSize: 16,
                    letterSpacing: 0.5
                  )
                ),
                const SizedBox(height: 2),
                const Text(
                  "Suivre vos livraisons en cours", 
                  style: TextStyle(
                    color: Colors.grey, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w500
                  )
                ),
              ],
            ),
          ),
          // Flèche de navigation
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded, 
              size: 14, 
              color: Colors.grey.shade400
            ),
          ),
        ],
      ),
    ),
  );
}
}