import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../order_list/order_list_controller.dart';
import '../../../appColors/appColors.dart';
import '../../../../routes/app_routes.dart';
import '../../../loading/loading.dart';

class OrderDeliveView extends GetView<OrderListController> {
  const OrderDeliveView ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Obx(() => FutureBuilder<List<dynamic>?>(
        future: controller.futureCommandes.value,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(text: "Récupération des archives");
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }

          // --- FILTRAGE : Uniquement les commandes LIVRÉES ---
          List<dynamic> filteredOrders = snapshot.data!.where((cmd) {
            return cmd['etat'] == "LIVREE";
          }).toList();
          
          // Tri par date décroissante
          filteredOrders.sort((a, b) {
            DateTime dateA = DateTime.tryParse(a['created'] ?? "") ?? DateTime(2000);
            DateTime dateB = DateTime.tryParse(b['created'] ?? "") ?? DateTime(2000);
            return dateB.compareTo(dateA); 
          });

          if (filteredOrders.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: controller.handleRefresh,
            color: AppColors.generalColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
            ),
          );
        },
      )),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> cmd) {
    final String dateStr = cmd['created'] ?? DateTime.now().toIso8601String();
    final String formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'fr_FR').format(DateTime.parse(dateStr));
    final List items = cmd['items'] ?? [];
    final String status = cmd['etat'] ?? "LIVRE";
    
    int totalQty = 0;
    for (var item in items) {
      totalQty += (item['quantity'] as num).toInt();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Get.toNamed(Routes.ORDERDETAIL, arguments: cmd),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 52, width: 52,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:  Icon(PhosphorIcons.package(PhosphorIconsStyle.fill), 
                        color: Colors.green, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("N° ${cmd['id'].toString().substring(0, 8).toUpperCase()}", 
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.blueGrey, letterSpacing: 0.5)),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text("$totalQty ${totalQty > 1 ? 'bouteilles' : 'bouteille'}", 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 4),
                          Text("Livré le $formattedDate", style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Note: Le bouton d'assignation a été supprimé ici car la commande est déjà livrée

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${cmd['montant_total']} F CFA", 
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 16)),
                    Row(
                      children: [
                        Text("Détails archive", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String etat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.checkCircle(), size: 12, color: Colors.green),
          const SizedBox(width: 4),
          Text(etat.replaceAll("_", " "), 
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(PhosphorIcons.archive(PhosphorIconsStyle.fill), size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          const Text("Aucune commande livrée",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), size: 50, color: Colors.redAccent.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("Une erreur est survenue", style: TextStyle(fontWeight: FontWeight.w900)),
          TextButton.icon(
            onPressed: controller.handleRefresh, 
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
            style: TextButton.styleFrom(foregroundColor: AppColors.generalColor),
          )
        ],
      ),
    );
  }
}