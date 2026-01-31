import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/routes/app_routes.dart';
import 'package:nafa_pro/modules/driver/home/controllers/driver_home_controller.dart';
import 'package:nafa_pro/modules/driver/dashboard/controllers/driver_controller.dart';

class DriverOverviewView extends GetView<DriverHomeController> {
  const DriverOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final mapCtrl = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("NAFA OPS"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 1),
        actions: [
           IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28), onPressed: () => Get.toNamed(Routes.DRIVER_NOTIFICATIONS)),
          //  Padding(padding: const EdgeInsets.only(right: 20), child: CircleAvatar(backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.black)))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bonjour, ${controller.driverName.split(' ')[0]} 👋", style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 5),
            const Text("Prêt à rouler ?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 30),

            // 1. STATUT
            Obx(() => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: mapCtrl.isOnline.value ? const Color(0xFF00A86B) : Colors.black87, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: mapCtrl.isOnline.value ? Colors.green.withOpacity(0.4) : Colors.black26, blurRadius: 10, offset: const Offset(0, 5))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(mapCtrl.isOnline.value ? "EN LIGNE" : "HORS LIGNE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 5),
                    Text(mapCtrl.isOnline.value ? "Vous recevez des courses" : "Passez en ligne pour commencer", style: const TextStyle(color: Colors.white70)),
                  ]),
                  Switch(value: mapCtrl.isOnline.value, activeColor: Colors.white, activeTrackColor: Colors.white24, inactiveThumbColor: Colors.grey, onChanged: (val) => mapCtrl.toggleStatus(val))
                ],
              ),
            )),

            const SizedBox(height: 20),

            // 2. NOUVEAU : MON STOCK TRICYCLE
            GestureDetector(
              onTap: controller.showStockDetails,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [BoxShadow(color: Colors.blue.shade50, blurRadius: 5)]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.propane_tank, color: Colors.blue),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Stock Tricycle", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Obx(() => Text("${controller.totalFullBottles} Pleines • ${controller.totalEmptyBottles} Vides", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                      child: const Text("VOIR", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. STATS
            const Text("Performance du Mois", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: Obx(() => Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: controller.availableBonus.value >= 5000 ? Colors.amber.shade100 : Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Icon(Icons.savings, color: controller.availableBonus.value >= 5000 ? Colors.amber : Colors.grey, size: 28),
                      InkWell(
                        onTap: controller.requestBonusWithdrawal,
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: controller.availableBonus.value >= 5000 ? Colors.white : Colors.grey.shade300, borderRadius: BorderRadius.circular(20)), child: Text("RETIRER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: controller.availableBonus.value >= 5000 ? Colors.black : Colors.grey))),
                      )
                    ]),
                    const SizedBox(height: 10),
                    Text("${controller.availableBonus.value} F", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const Text("Bonus Dispo", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ]),
                ))),
                const SizedBox(width: 15),
                Expanded(child: Obx(() => _buildStatCard("Total Courses", "${controller.completedTrips}", Icons.check_circle, Colors.blue))),
              ],
            ),

            const SizedBox(height: 30),

            // 4. RACCOURCI CARTE
            GestureDetector(
              onTap: () => controller.changeTab(1),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                child: Row(children: const [
                  Icon(Icons.map, color: Color(0xFF00A86B), size: 30),
                  SizedBox(width: 15),
                  Expanded(child: Text("Voir ma Feuille de Route", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    );
  }
}
