import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dispatch_controller.dart';
import '../../appColors/appColors.dart';
class DispatchView extends GetView<DispatchController> {
  const DispatchView({super.key});

  @override
  Widget build(BuildContext context) {
    // RÉCUPÉRATION DE L'ONGLET CIBLE (0 par défaut)
    final int initialIndex = Get.arguments is int ? Get.arguments : 0;

    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex, // C'est ici que la magie opère
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SUPERVISION"),
          backgroundColor: AppColors.generalColor,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            isScrollable: true, 
            tabs: [
              Obx(() => Tab(text: "EN ATTENTE (${controller.pendingOrders.length})")),
              Obx(() => Tab(text: "EN COURS (${controller.assignedOrders.length})")),
              Obx(() => Tab(text: "ANOMALIES (${controller.issueOrders.length})")),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Obx(() => _buildOrderList(controller.pendingOrders, "ASSIGNER", Colors.blue)),
            Obx(() => _buildOrderList(controller.assignedOrders, "SUIVRE", Colors.green)),
            Obx(() => _buildOrderList(controller.issueOrders, "RÉSOUDRE PROBLÈME", Colors.red)),
          ],
        ),
      ),
    );
  }

  // (Le reste de _buildOrderList est identique, je le réécris pour que le fichier soit complet et valide)
  Widget _buildOrderList(List<ManagerOrder> orders, String btnLabel, Color btnColor) {
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox, size: 50, color: Colors.grey.shade300), const Text("Aucune commande ici", style: TextStyle(color: Colors.grey))]));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        bool isIssue = order.status == 'ISSUE';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isIssue ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: isIssue ? Colors.red : Colors.blue.shade50, borderRadius: BorderRadius.circular(5)),
                      child: Text(order.targetZone, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isIssue ? Colors.white : Colors.blue)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(order.client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(order.location, style: const TextStyle(color: Colors.grey)),
                
                if (isIssue) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(5)),
                    child: Row(children: [const Icon(Icons.warning, size: 16, color: Colors.red), const SizedBox(width: 5), Expanded(child: Text("${order.issueReason} (${order.driverName})", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)))]),
                  )
                ],

                const Divider(height: 20),
                Row(children: [const Icon(Icons.propane_tank, size: 16, color: Colors.grey), const SizedBox(width: 5), Text(order.details, style: const TextStyle(fontWeight: FontWeight.w600))]),
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (order.status == 'PENDING') controller.openAssignModal(order);
                      if (order.status == 'ISSUE') controller.openResolveModal(order);
                      if (order.status == 'ASSIGNED') Get.snackbar("Info", "Suivi GPS bientôt disponible");
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: isIssue ? Colors.red : AppColors.generalColor, foregroundColor: Colors.white),
                    child: Text(isIssue ? "GÉRER L'ANOMALIE" : btnLabel),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
