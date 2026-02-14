import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/manager_controller.dart';
import '../../root/manager_root_controller.dart';
import '../../../appColors/appColors.dart';

class ManagerView extends GetView<ManagerController> {
  const ManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final rootController = Get.find<ManagerRootController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), 
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tableau de bord", style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
            Text(controller.depotName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
        backgroundColor: AppColors.generalColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // --- CLOCHE DE NOTIFICATIONS STYLISÉE ---
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 5),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child:  Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: Colors.white, size: 30),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderCaisse(),
            _buildActionCards(rootController),
            _buildStockCritique(rootController),
            const SizedBox(height: 25),
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCaisse() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: BoxDecoration(
        color: AppColors.generalColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CAISSE DU JOUR", style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    "${controller.formatCurrency(controller.cashBalance.value)} F CFA", 
                    style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)
                  )),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.greenAccent, size: 20),
              )
            ],
          ),
          const SizedBox(height: 30),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      double progress = (controller.dailyBottleSales.value / controller.dailyTarget).clamp(0.0, 1.0);
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Objectif Vente (${controller.dailyBottleSales}/${controller.dailyTarget})", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, 
              minHeight: 10, 
              backgroundColor: Colors.white.withOpacity(0.1), 
              color: Colors.greenAccent,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionCards(ManagerRootController rootController) {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(child: Obx(() => _buildActionCard("${controller.activeIssues.value}", "Anomalies", Icons.warning_amber_rounded, Colors.red, () { rootController.changePage(1); controller.goToDispatch(initialTab: 2); }))),
            const SizedBox(width: 12),
            Expanded(child: Obx(() => _buildActionCard("${controller.pendingOrders.value}", "En Attente", Icons.pending_actions_rounded, Colors.orange, () { rootController.changePage(1); controller.goToDispatch(initialTab: 0); }))),
            const SizedBox(width: 12),
            Expanded(child: Obx(() => _buildActionCard("${controller.activeTricycles}", "En Ligne", Icons.delivery_dining_rounded, Colors.blue, () { rootController.changePage(2); }))),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCritique(ManagerRootController rootController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              const Text("STOCK CRITIQUE", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D3436), fontSize: 13, letterSpacing: 0.5)), 
              TextButton(
                onPressed: () => rootController.changePage(3), 
                child: const Text("Tout voir", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold))
              )
            ]
          ),
          Obx(() => SizedBox(
            height: 95, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal, 
              itemCount: controller.lowStockItems.length, 
              itemBuilder: (context, index) { 
                var item = controller.lowStockItems[index]; 
                return Container(
                  width: 150, 
                  margin: const EdgeInsets.only(right: 12, bottom: 5), 
                  padding: const EdgeInsets.all(15), 
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: Colors.red.shade50)
                  ), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Text(item["name"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3436))), 
                      const SizedBox(height: 5), 
                      Text(item["qty"]!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16))
                    ]
                  )
                ); 
              }
            )
          )),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)), 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Text("ACTIVITÉ RÉCENTE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D3436))), 
          const SizedBox(height: 25), 
          Obx(() => ListView.separated(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(), 
            itemCount: controller.recentActivities.length, 
            separatorBuilder: (c, i) => const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, thickness: 0.5)), 
            itemBuilder: (context, index) { 
              final act = controller.recentActivities[index]; 
              return Row(
                children: [
                  Text(act.time, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 15), 
                  Container(
                    padding: const EdgeInsets.all(10), 
                    decoration: BoxDecoration(color: act.color.withOpacity(0.1), shape: BoxShape.circle), 
                    child: Icon(act.icon, size: 18, color: act.color)
                  ), 
                  const SizedBox(width: 15), 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(act.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF2D3436))), 
                        const SizedBox(height: 2),
                        Text(act.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))
                      ]
                    )
                  )
                ]
              ); 
            }
          )),
          const SizedBox(height: 20),
        ]
      ),
    );
  }

  Widget _buildActionCard(String value, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20), 
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(25), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10))]
        ), 
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12), 
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)), 
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.w900, letterSpacing: 0.5))
          ]
        )
      )
    );
  }
}