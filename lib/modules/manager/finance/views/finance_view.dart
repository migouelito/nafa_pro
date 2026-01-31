import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/finance_controller.dart';
import '../../../appColors/appColors.dart';

class FinanceView extends GetView<FinanceController> {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text("ERP FINANCE"),
          backgroundColor: AppColors.generalColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.amber, labelColor: Colors.white, unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: "ANALYSE"), // Bénéfice, Stats Marque, Stats Livreur
              Tab(text: "CHARGES"), // Fournisseurs, Dépenses
              Tab(text: "GUICHET"), // Paie Livreurs, Trésorerie
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnalyticsTab(),
            _buildChargesTab(),
            _buildCashierTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.addExpense,
          backgroundColor: Colors.red,
          child: const Icon(Icons.remove, color: Colors.white),
          tooltip: "Nouvelle Dépense",
        ),
      ),
    );
  }

  // --- ONGLET 1 : ANALYSE (Vue d'ensemble) ---
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. P&L (Bénéfice)
          Row(
            children: [
              Expanded(child: Obx(() => _kpiCard("CHIFFRE D'AFFAIRES", controller.totalRevenue, Colors.blue))),
              const SizedBox(width: 10),
              Expanded(child: Obx(() => _kpiCard("BÉNÉFICE NET", controller.netProfit, Colors.green))),
            ],
          ),
          const SizedBox(height: 20),
          
          // 2. PAR MARQUE (Situation Stock/Vente)
          const Text("VENTES PAR MARQUE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Obx(() => ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.productStats.length,
            itemBuilder: (context, index) {
              final stat = controller.productStats[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(stat.brand[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  title: Text("${stat.brand} ${stat.type}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${stat.quantitySold} vendues"),
                  trailing: Text("+ ${controller.formatCurrency(stat.totalMargin)} F", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          )),

          const SizedBox(height: 20),

          // 3. PAR LIVREUR (Performance)
          const Text("PERFORMANCE LIVREURS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Obx(() => ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.driverStats.length,
            itemBuilder: (context, index) {
              final stat = controller.driverStats[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.amber.shade100, child: Text("#${index+1}", style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold))),
                  title: Text(stat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${stat.bottlesSold} bouteilles"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(controller.formatCurrency(stat.revenueGenerated), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text("CA Généré", style: TextStyle(fontSize: 8, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  // --- ONGLET 2 : CHARGES (Dettes & Dépenses) ---
  Widget _buildChargesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOURNISSEURS
          const Text("FACTURES FOURNISSEURS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Obx(() => ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.supplierInvoices.length,
            itemBuilder: (context, index) {
              final inv = controller.supplierInvoices[index];
              bool isLate = inv.dueDate.isBefore(DateTime.now()) && !inv.isPaid.value;
              return Obx(() => Opacity(
                opacity: inv.isPaid.value ? 0.5 : 1.0,
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.factory, color: isLate ? Colors.red : Colors.indigo),
                    title: Text(inv.supplier, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Échéance: ${DateFormat('dd/MM').format(inv.dueDate)}"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${controller.formatCurrency(inv.amount)} F", style: const TextStyle(fontWeight: FontWeight.bold)),
                        if(!inv.isPaid.value) 
                          InkWell(
                            onTap: () => controller.paySupplier(inv),
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(4)), child: const Text("PAYER", style: TextStyle(color: Colors.white, fontSize: 10))),
                          )
                        else
                          const Text("PAYÉ", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              ));
            },
          )),

          const SizedBox(height: 20),

          // DÉPENSES
          const Text("DÉPENSES OPÉRATIONNELLES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Obx(() => ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.expenses.length,
            itemBuilder: (context, index) {
              final exp = controller.expenses[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  title: Text(exp.category),
                  subtitle: Text(exp.description),
                  trailing: Text("- ${controller.formatCurrency(exp.amount)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  // --- ONGLET 3 : GUICHET (Trésorerie & Paie) ---
  Widget _buildCashierTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ÉTAT DES CAISSES
          Row(
            children: [
              Expanded(child: Obx(() => _cashCard("VIRTUEL", controller.virtualBalance.value, Colors.cyan))),
              const SizedBox(width: 10),
              Expanded(child: Obx(() => _cashCard("COFFRE", controller.physicalCash.value, Colors.orange))),
            ],
          ),
          const SizedBox(height: 20),

          // 2. DEMANDES DE RETRAIT (URGENT)
          const Text("DEMANDES DE RETRAIT (GAINS)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.pendingWithdrawals.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Aucune demande en attente."))));
            return ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.pendingWithdrawals.length,
              itemBuilder: (context, index) {
                final req = controller.pendingWithdrawals[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.green)),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.attach_money, color: Colors.white)),
                    title: Text(req.driverName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('HH:mm').format(req.time)),
                    trailing: ElevatedButton(
                      onPressed: () => controller.processWithdrawal(req),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: Text("PAYER ${controller.formatCurrency(req.amount)}"),
                    ),
                  ),
                );
              },
            );
          }),

          const SizedBox(height: 20),

          // 3. SOLDES À PAYER
          const Text("SOLDES LIVREURS (NON RÉCLAMÉS)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Obx(() => ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.driverWallets.length,
            itemBuilder: (context, index) {
              final w = controller.driverWallets[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.grey),
                  title: Text(w.name),
                  trailing: Text("${controller.formatCurrency(w.availableBalance.value)} F", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  // WIDGETS HELPERS
  Widget _kpiCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text("${controller.formatCurrency(value)} F", style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))]),
    );
  }
  Widget _cashCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text("${controller.formatCurrency(value)} F", style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))]),
    );
  }
}
