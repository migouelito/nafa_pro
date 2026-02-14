import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'detail_order_controller.dart';
import '../../../appColors/appColors.dart';
import '../../../services/urlBase.dart';
import '../../../loading/loading.dart';
import '../../../../routes/app_routes.dart';

class DetailOrderView extends GetView<DetailOrderController> {
  const DetailOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Obx(() => Text("Commande #${controller.shortId}", 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.order.isEmpty) {
          return const Center(child: LoadingWidget(text: "Chargement..."));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusHeader(),
                    const SizedBox(height: 25),
                    
                    _buildSectionHeader("Contenu de la commande", PhosphorIcons.package()),
                    _buildProductsExpansionTile(),
                    
                    const SizedBox(height: 20),
                    _buildSectionHeader("Récapitulatif financier", PhosphorIcons.creditCard()),
                    _buildFinanceCard(),

                    const SizedBox(height: 20),
                    _buildSectionHeader("Informations de livraison", PhosphorIcons.mapPin()),
                    _buildDeliveryCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Bouton d'action si nécessaire
            if (controller.canModify) _buildBottomAction(),
          ],
        );
      }),
    );
  }

  Widget _buildProductsExpansionTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(PhosphorIcons.shoppingCart(), color: AppColors.generalColor),
          title: Text(
            "${controller.items.length} article(s) commandé(s)",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          children: [
            const Divider(height: 1),
            ...controller.items.map((item) => _buildProductItemCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              // RÉCUPÉRATION DE L'ID DEPUIS LE CONTROLLER
              final orderId = {'orderId': controller.order['id']};
              Get.toNamed(Routes.ORDERASSIGNED, arguments: orderId);
            },
            icon: Icon(PhosphorIcons.userPlus(PhosphorIconsStyle.bold), size: 18),
            label: const Text("Assigner à un livreur", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.generalColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSectionHeader(String t, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Row(children: [
      Icon(i, size: 14, color: Colors.blueGrey),
      const SizedBox(width: 6),
      Text(t.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey))
    ]),
  );

  Widget _buildStatusHeader() {
    String etat = controller.order['etat'] ?? "INCONNU";
    Color statusColor = _getStatusColor(etat);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          Text(etat.replaceAll("_", " "), 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 5),
          Text(controller.formattedDate, 
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductItemCard(Map<String, dynamic> item) {
    final double prixUnitaire = double.tryParse(item['prix_unitaire']?.toString() ?? "0") ?? 0;
    final int quantite = int.tryParse(item['quantity']?.toString() ?? "0") ?? 0;
    final double sousTotal = prixUnitaire * quantite;
    final String typeCommerce = item['type_commerce']?.toString().toUpperCase() ?? "VENTE";
    
    final String? imageUrl = item['produit_image'];
    final String fullImageUrl = imageUrl != null && imageUrl.startsWith('http') 
        ? imageUrl : "${ApiUrlPage.baseUrl}$imageUrl";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            height: 45, width: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(PhosphorIcons.package(), size: 18),
                    )
                  : Icon(PhosphorIcons.package(), size: 18),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['produit_name'] ?? "Produit", 
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                Row(
                  children: [_buildTypeBadge(typeCommerce), const SizedBox(width: 8),
                    Text("x$quantite", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))],
                ),
              ],
            ),
          ),
          Text("${sousTotal.toInt()} F", 
              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.generalColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    switch (type) {
      case "RECHARGE": color = Colors.green; break;
      case "ECHANGE": color = Colors.orange; break;
      default: color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(type, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildFinanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildInfoRow(PhosphorIcons.truck(), "Livraison", "${controller.order['prix_livraison']} F"),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TOTAL À PAYER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.blueGrey)),
              Text("${controller.order['montant_total']} F", 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildInfoRow(PhosphorIcons.user(), "Client", controller.order['customer_name']),
          const Divider(),
          _buildInfoRow(PhosphorIcons.mapPin(), "Adresse", controller.order['adresse'] ?? "Livraison à domicile"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey.shade300, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value ?? "N/A", style: TextStyle(color: AppColors.generalColor, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String etat) {
    switch (etat) {
      case "EN_ATTENTE": return AppColors.Orange;
      case "LIVRE": return Colors.green;
      case "ANNULE": return Colors.red;
      case "EN_COURS": return Colors.blue;
      default: return Colors.grey;
    }
  }
}