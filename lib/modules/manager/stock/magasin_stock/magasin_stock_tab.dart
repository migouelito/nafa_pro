import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
import 'magasin_stock_controller.dart';
import '../../../services/urlBase.dart';
import '../../../loading/loading.dart'; 
import 'package:nafa_pro/routes/app_routes.dart';

class MagasinStockTab extends GetView<MagasinStockController> {
  const MagasinStockTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          _buildProductDropdown(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.depotStock.isEmpty) {
                return const Center(child: LoadingWidget(text: "Chargement du stock..."));
              }
              final filteredList = controller.filteredStock;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredList.length,
                itemBuilder: (context, index) => _buildProductRow(context, filteredList[index]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        int alertCount = controller.countInAlert;
        if (alertCount == 0) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Get.snackbar("Alerte", "$alertCount articles en alerte"),
          backgroundColor: Colors.red,
          icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
          label: Text("ALERTES ($alertCount)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }),
    );
  }

  Widget _buildProductRow(BuildContext context, Map<String, dynamic> item) {
    final int qteRecharge = (item['quantite_recharge_charger'] ?? 0).toInt();
    final int qteEchange = (item['quantite_echange_charger'] ?? 0).toInt();
    final int qteVente = (item['quantite_vente'] ?? 0).toInt();
    final int total = (item['nombre_total'] ?? 0).toInt();
    final int seuil = (item['seuil_alerte'] ?? 0).toInt();

    final bool isUnderSeuil = total <= seuil;
    final bool isZero = total <= 0;

    final String? imgPath = item['produit_image'];
    final String fullImageUrl = (imgPath != null && imgPath.startsWith('http')) 
        ? imgPath : "${ApiUrlPage.baseUrl}$imgPath";

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.DETAILMAGASINSTOCK, arguments: item['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            // --- CONTENU PRINCIPAL ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isZero ? Colors.grey.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: isUnderSeuil ? Colors.red.withOpacity(0.3) : Colors.transparent, 
                    width: 1.5
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  // IMAGE DU PRODUIT
                  Container(
                    height: 75, width: 75,
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imgPath != null 
                          ? Image.network(fullImageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.propane_tank))
                          : const Icon(Icons.propane_tank, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // INFORMATIONS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10), // Espace pour ne pas chevaucher les badges du haut
                        Text(item['produit_nom']?.toString().toUpperCase() ?? "PRODUIT",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2D3436))),
                        const SizedBox(height: 4),
                        Text("Seuil d'alerte : $seuil", style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _indicator(qteRecharge, Colors.green, "RECHARGE"),
                            _indicator(qteEchange, Colors.orange, "ÉCHANGE"),
                            _indicator(qteVente, Colors.blue, "VENTE"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- BADGE TOTAL (ALIGNE À GAUCHE DANS LA CASE) ---
            if (!isZero)
              Positioned(
                top: 8,
                left: 12,
                child: _badge("TOTAL: $total", AppColors.generalColor),
              ),

            // --- BADGE ALERTE / RUPTURE (ALIGNE À DROITE DANS LA CASE) ---
            if (isUnderSeuil)
              Positioned(
                top: 8,
                right: 12,
                child: _badge(isZero ? "RUPTURE" : "SOUS SEUIL", Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color, 
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
      ],
    ),
    child: Text(
      label, 
      style: const TextStyle(
        color: Colors.white, 
        fontSize: 7, 
        fontWeight: FontWeight.w900, 
        letterSpacing: 0.5
      )
    ),
  );

  Widget _indicator(int count, Color color, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 7, color: Colors.blueGrey, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(count.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
    ],
  );

  Widget _buildProductDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
      child: Obx(() {
        List<String> brands = controller.depotStock
            .map((e) => e['produit_nom']?.toString() ?? "Inconnu")
            .toSet().toList();
        if (!brands.contains("TOUS LES PRODUITS")) brands.insert(0, "TOUS LES PRODUITS");

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: controller.selectedBrand.value,
              isExpanded: true,
              items: brands.map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)))).toList(),
              onChanged: (v) => controller.updateSelectedBrand(v!),
            ),
          ),
        );
      }),
    );
  }
}