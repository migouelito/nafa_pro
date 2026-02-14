import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../services/urlBase.dart';
import '../../../../loading/loading.dart';
import 'detail_produit_controller.dart';

class ProduitDetailView extends GetView<ProduitDetailController> {
  const ProduitDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Obx(() => Text(
          controller.item['marque_name']?.toString().toUpperCase() ?? "DÉTAILS",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.item.isEmpty) {
          return const LoadingWidget(text: "Chargement...");
        }

        if (controller.item.isEmpty) {
          return const Center(child: Text("Produit introuvable"));
        }

        // SOLUTION : Utiliser .value pour convertir RxMap en Map<dynamic, dynamic>
        // Puis caster en Map<String, dynamic> pour éviter les erreurs de type
        final Map<String, dynamic> item = Map<String, dynamic>.from(controller.item.value);
        
        // Extraction selon ton JSON : 'tarif' au singulier
        final Map<String, dynamic> activeTarif = item['tarif'] ?? {};
        final Map<String, dynamic> stock = item['stock'] ?? {};

        final String fullImageUrl = (item['image'] != null) 
            ? "${ApiUrlPage.baseUrl}${item['image']}" : "";

        return Column(
          children: [
            // IMAGE
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Hero(
                  tag: 'product-${item['id']}',
                  child: Center(
                    child: fullImageUrl.isNotEmpty 
                      ? Image.network(fullImageUrl, fit: BoxFit.contain)
                      : Icon(PhosphorIcons.package(), size: 70, color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            
            // CONTENU
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)]
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(item),
                    
                    // SECTION TARIFS : Ordre Recharge > Échange > Vente
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("TARIFICATIONS"),
                        const SizedBox(height: 10),
                        _buildPriceGrid(activeTarif, formatter),
                      ],
                    ),
                    
                    // SECTION STOCK : Ordre Recharge > Échange > Vente
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("ÉTAT DU STOCK"),
                        const SizedBox(height: 10),
                        _buildStockGrid(stock),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- LES MÉTHODES RESTE IDENTIQUES MAIS AVEC L'ORDRE CORRIGÉ ---

  Widget _sectionLabel(String text) => Text(text, 
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blueGrey, letterSpacing: 0.8));

  Widget _buildTitleSection(Map<String, dynamic> item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(item['marque_name']?.toString() ?? "", 
           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      Text("${item['name'] ?? ''} - ${item['poids_value']} kg", 
           style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
    ],
  );

  Widget _buildPriceGrid(Map<String, dynamic> tarif, NumberFormat fmt) {
    return Row(
      children: [
        _infoCard("Recharge", tarif['price_recharge'], Colors.green, PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill), fmt, isPrice: true),
        const SizedBox(width: 8),
        _infoCard("Échange", tarif['price_echange'], Colors.orange, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill), fmt, isPrice: true),
        const SizedBox(width: 8),
        _infoCard("Vente", tarif['price_vente'], Colors.blue, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill), fmt, isPrice: true),
      ],
    );
  }

  Widget _buildStockGrid(Map<String, dynamic> stock) {
    return Row(
      children: [
        _infoCard("Recharges", stock['recharge'], Colors.green,  PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill), null),
        const SizedBox(width: 8),
        _infoCard("Échanges", stock['echange'], Colors.orange, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill), null),
        const SizedBox(width: 8),
        _infoCard("Ventes", stock['vente'], Colors.blue,  PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill), null),
      ],
    );
  }

  Widget _infoCard(String label, dynamic value, Color color, IconData icon, NumberFormat? fmt, {bool isPrice = false}) {
    String displayValue = "0";
    if (isPrice && fmt != null) {
      double price = double.tryParse(value?.toString() ?? "0") ?? 0;
      displayValue = "${fmt.format(price)} F";
    } else {
      displayValue = value?.toString() ?? "0";
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(displayValue, 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() => Container(
    width: double.infinity,
    height: 55,
    margin: const EdgeInsets.only(bottom: 10),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent, 
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
      ),
      onPressed: () => _showAvarieOptions(),
      icon: Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), color: Colors.white, size: 20),
      label: const Text("SIGNALER UNE AVARIE", 
             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
    ),
  );

  void _showAvarieOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("DÉCLARATION D'AVARIE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 20),
            _avarieTile("Bouteille Pleine", Colors.green, PhosphorIcons.checkCircle(), true),
            const SizedBox(height: 10),
            _avarieTile("Bouteille Vide", Colors.orange, PhosphorIcons.xCircle(), false),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _avarieTile(String title, Color color, IconData icon, bool isFull) => Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: color.withOpacity(0.1))
    ),
    child: ListTile(
      onTap: () { controller.signalerAvarie(isFull); Get.back(); },
      leading: Icon(icon, color: color, size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      trailing: Icon(PhosphorIcons.caretRight(), size: 16, color: color),
    ),
  );
}