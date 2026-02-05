import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/stock_controller.dart';
import '../../../services/urlBase.dart';
import '../../../loading/loading.dart'; 
import 'package:nafa_pro/routes/app_routes.dart';

class ProduitsTab extends GetView<StockController> {
  const ProduitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          _buildProductDropdown(),
          Expanded(
            child: Obx(() {
              if (controller.depotStock.isEmpty) {
                return const Center(child: LoadingWidget(text: "Chargement des produits..."));
              }

              final filteredList = controller.filteredStock;

              if (filteredList.isEmpty) {
                return const Center(
                  child: Text("Aucun produit trouvé",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredList.length,
                itemBuilder: (context, index) => _buildProductRow(context, filteredList[index]),
              );
            }),
          ),
        ],
      ),
      
      // --- BOUTON FLOTTANT POUR LES PRODUITS ÉPUISÉS (GRISÉS) ---
      floatingActionButton: Obx(() {
        // On compte les produits où (Plein + Vide + Avarie) == 0
        int countGris = controller.depotStock.where((item) {
          return (item.fullCount.value + item.emptyCount.value + item.damagedCount.value) <= 0;
        }).length;

        // Si aucun produit n'est grisé, on ne montre pas le bouton
        if (countGris == 0) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () {
            // Optionnel : Scroller vers le premier produit épuisé ou afficher une alerte
            Get.snackbar(
              "Alerte Stock",
              "$countGris produit(s) sont actuellement en rupture totale.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.withOpacity(0.9),
              colorText: Colors.white,
              margin: const EdgeInsets.all(15),
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
            );
          },
          backgroundColor: Colors.grey[800],
          elevation: 4,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.inventory_2_outlined, color: Colors.white),
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    "$countGris",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          label: const Text("ÉPUISÉS", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        );
      }),
    );
  }

  Widget _buildProductRow(BuildContext context, StockItem item) {
    return Obx(() {
      int stockPlein = item.fullCount.value;
      int stockVide = item.emptyCount.value;
      int stockAvarie = item.damagedCount.value;

      // Un produit est grisé si la somme de ses stocks est 0
      bool hasStock = (stockPlein + stockVide + stockAvarie) > 0;

      final String fullImageUrl = (item.imageUrl != null && item.imageUrl!.isNotEmpty)
          ? "${ApiUrlPage.baseUrl}${item.imageUrl}"
          : "";

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.DETAILPRODUIT, arguments: item.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasStock ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasStock ? Colors.transparent : Colors.grey.shade300, 
              width: 1
            ),
            boxShadow: [
              if (hasStock) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
            ],
          ),
          child: Opacity(
            opacity: hasStock ? 1.0 : 0.6, // Effet visuel grisé
            child: Row(
              children: [
                // IMAGE
                Container(
                  height: 90, width: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[50], 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(fullImageUrl, fit: BoxFit.contain)
                      : const Icon(Icons.propane_tank, color: Colors.grey),
                ),
                const SizedBox(width: 15),

                // INFOS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(item.brand.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          ),
                          if (!hasStock)
                            const Text("RUPTURE", 
                              style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(item.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _priceIndicator(stockPlein, item.price, Colors.green, "RECHARGE"),
                          _priceIndicator(stockVide, item.priceVente, Colors.orange, "VENTE"),
                          _priceIndicator(stockAvarie, item.priceEchange, Colors.red, "ECHANGE"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _priceIndicator(int count, double price, Color color, String label) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(price > 0 ? "${formatter.format(price)} F" : "-", 
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
        Text("$count disp.", 
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildProductDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Obx(() {
        List<String> brands = controller.depotStock.map((e) => e.brand).toSet().toList();
        if (!brands.contains("TOUS LES PRODUITS")) brands.insert(0, "TOUS LES PRODUITS");

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: controller.selectedBrand.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 28),
              items: brands.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, 
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) controller.updateSelectedBrand(v);
              },
            ),
          ),
        );
      }),
    );
  }
}