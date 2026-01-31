import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/routes/app_routes.dart';
import '../controllers/manager_controller.dart';
import '../../root/manager_root_controller.dart';
import '../../../appColors/appColors.dart';

class ManagerView extends GetView<ManagerController> {
  const ManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final rootController = Get.find<ManagerRootController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("TABLEAU DE BORD", style: TextStyle(fontSize: 12, letterSpacing: 1, color: Colors.white70)),
            Text(controller.depotName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor:AppColors.generalColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // LIEN CRM (CLIENTS)
          IconButton(
            icon: const Icon(Icons.people_alt), 
            onPressed: () => Get.toNamed(Routes.MANAGER_CLIENTS),
            tooltip: "Clients & CRM",
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Get.toNamed(Routes.MANAGER_SETTINGS)),
          IconButton(icon: const Icon(Icons.logout), onPressed: controller.logout),
        ],
      ),
      // ... Le reste du Dashboard reste identique (Je ne le répète pas pour abréger, mais le fichier doit contenir tout le body du dashboard précédent)
      body: SingleChildScrollView(
        child: Column(
          children: [
            // REPRISE DU CODE DASHBOARD PRÉCÉDENT
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              decoration: BoxDecoration(
                color: AppColors.generalColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CAISSE DU JOUR", style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 5),
                          Obx(() => Text("${controller.formatCurrency(controller.cashBalance.value)} F", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.trending_up, color: Colors.greenAccent, size: 30))
                    ],
                  ),
                  const SizedBox(height: 25),
                  Obx(() {
                    double progress = controller.dailyBottleSales.value / controller.dailyTarget;
                    return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Objectif Vente (${controller.dailyBottleSales}/${controller.dailyTarget})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.black26, color: Colors.greenAccent))]);
                  })
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: Obx(() => _buildActionCard("${controller.activeIssues.value}", "Anomalies", Icons.warning_amber_rounded, Colors.red, () { rootController.changePage(1); controller.goToDispatch(initialTab: 2); }))),
                    const SizedBox(width: 15),
                    Expanded(child: Obx(() => _buildActionCard("${controller.pendingOrders.value}", "En Attente", Icons.timer, Colors.orange, () { rootController.changePage(1); controller.goToDispatch(initialTab: 0); }))),
                    const SizedBox(width: 15),
                    Expanded(child: Obx(() => _buildActionCard("${controller.activeTricycles}", "En Ligne", Icons.electric_rickshaw, Colors.blue, () { rootController.changePage(2); }))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("STOCK CRITIQUE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), InkWell(onTap: () => rootController.changePage(3), child: const Text("Voir Stock >", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)))]),
                  const SizedBox(height: 10),
                  Obx(() => SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: controller.lowStockItems.length, itemBuilder: (context, index) { var item = controller.lowStockItems[index]; return Container(width: 140, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade100)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(item["name"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 5), Text(item["qty"]!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))])); }))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("ACTIVITÉ RÉCENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 15), Obx(() => ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: controller.recentActivities.length, separatorBuilder: (c, i) => const Divider(height: 25), itemBuilder: (context, index) { final act = controller.recentActivities[index]; return Row(children: [Column(children: [Text(act.time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))]), const SizedBox(width: 15), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: act.color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(act.icon, size: 20, color: act.color)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(act.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(act.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))]))]); }))]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String value, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 5))]), child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 10), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))])));
  }
}
 