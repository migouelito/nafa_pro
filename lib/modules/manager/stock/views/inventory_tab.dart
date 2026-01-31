import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/stock_controller.dart';
import '../../../services/urlBase.dart';
import '../../../loading/loading.dart'; 

class InventoryTab extends GetView<StockController> {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // --- DROPDOWN DYNAMIQUE ---
          _buildProductDropdown(),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Obx(() {
                if (controller.depotStock.isEmpty) {
                  return const LoadingWidget(text: "Chargement des produits");
                }

                final filteredList = controller.filteredStock;

                if (filteredList.isEmpty) {
                  return const Center(child: Text("Aucun produit trouvé", style: TextStyle(color: Colors.grey)));
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 0.70, 
                    mainAxisSpacing: 16, 
                    crossAxisSpacing: 16,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) => _buildModernStockCard(filteredList[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDropdown() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Obx(() {
        // Extraction des marques uniques de la liste depotStock
        List<String> brands = controller.depotStock.map((e) => e.brand).toSet().toList();
        if (!brands.contains("TOUS LES PRODUITS")) {
          brands.insert(0, "TOUS LES PRODUITS");
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: controller.selectedBrand.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey),
              items: brands.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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

  Widget _buildModernStockCard(StockItem item) {
    final String fullImageUrl = (item.imageUrl != null && item.imageUrl!.isNotEmpty)
        ? "${ApiUrlPage.baseUrl}${item.imageUrl}" : "";
    final formatter = NumberFormat('#,###');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: fullImageUrl.isNotEmpty 
                        ? Image.network(fullImageUrl, fit: BoxFit.contain) 
                        : Icon(Icons.propane_tank_outlined, size: 60, color: Colors.grey.shade300),
                  ),
                ),
                _buildModernPriceBadge(formatter.format(item.price)),
                _buildModernDamageButton(item),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(item.brand.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                Text(item.type, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildModernStockRow(item),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPriceBadge(String price) => Positioned(
    top: 12, left: 12,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
      child: Text("$price F", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
    ),
  );

  Widget _buildModernDamageButton(StockItem item) => Positioned(
    top: 8, right: 8,
    child: GestureDetector(
      onTap: () => _openDamageDialog(item),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.report_gmailerrorred_rounded, color: Colors.redAccent, size: 18),
      ),
    ),
  );

  Widget _buildModernStockRow(StockItem item) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Obx(() => _buildStockInfo(item.fullCount.value, Colors.green, "PLEIN")),
      Obx(() => _buildStockInfo(item.emptyCount.value, Colors.orange, "VIDE")),
      Obx(() => _buildStockInfo(item.damagedCount.value, Colors.red, "AVARIE")),
    ],
  );

  Widget _buildStockInfo(int count, Color color, String label) => Column(
    children: [
      Text("$count", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
      Text(label, style: TextStyle(fontSize: 7, color: Colors.grey.shade400, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    ],
  );

  void _openDamageDialog(StockItem item) {
    Get.defaultDialog(
      title: "SIGNALER AVARIE", 
      titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 14),
      radius: 20,
      content: Column(
        children: [
          Text("${item.brand} ${item.type}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildDamageBtn(item, isFull: true),
            _buildDamageBtn(item, isFull: false),
          ]),
        ],
      ),
      textCancel: "Annuler",
    );
  }

  Widget _buildDamageBtn(StockItem item, {required bool isFull}) => GestureDetector(
    onTap: () { Get.back(); controller.processDamage(item, isFull); },
    child: Column(children: [
      Container(
        padding: const EdgeInsets.all(20), 
        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle), 
        child: Icon(isFull ? Icons.propane_tank : Icons.crop_square, color: Colors.red, size: 28)
      ),
      const SizedBox(height: 8),
      Text(isFull ? "Bouteille Pleine" : "Bouteille Vide", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))
    ])
  );
}