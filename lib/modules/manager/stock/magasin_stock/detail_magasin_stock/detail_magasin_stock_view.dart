import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../services/urlBase.dart';
import '../../../../loading/loading.dart';
import 'detail_magasin_stock_controller.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';

class DetailMagasinStockView extends GetView<DetailMagasinStockController> {
  const DetailMagasinStockView({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text("DÉTAILS DU STOCK", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.item.isEmpty) {
          return const LoadingWidget(text: "Analyse du stock...");
        }

        final data = controller.item;
        final details = data['produit_details'] ?? {};
        final tarif = details['tarif'] ?? {};
        
        final String? imgPath = data['produit_image'] ?? details['image'];
        final String fullImageUrl = (imgPath != null && imgPath.startsWith('http')) 
            ? imgPath : "${ApiUrlPage.baseUrl}$imgPath";

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // --- HEADER IMAGE ---
                    Container(
                      width: double.infinity,
                      height: 220,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                      ),
                      child: Center(
                        child: imgPath != null 
                          ? Image.network(fullImageUrl, fit: BoxFit.contain)
                          : Icon(PhosphorIcons.package(), size: 80, color: Colors.grey.shade300),
                      ),
                    ),

                    // --- INFOS CARD ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(details, data),
                          const SizedBox(height: 25),

                          // --- STOCK PLEIN (CHARGÉ) ---
                          _sectionTitle("STOCK PLEIN (CHARGÉ)"),
                          const SizedBox(height: 12),
                          _buildGrid([
                            _infoBox("Recharge", data['quantite_recharge_charger'], Colors.green, PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill)),
                            _infoBox("Échange", data['quantite_echange_charger'], AppColors.Orange, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill)),
                            _infoBox("Vente", data['quantite_vente'], Colors.blue, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill)),
                          ]),
                             
                          const SizedBox(height: 20),

                          // --- STOCK VIDE ---
                          _sectionTitle("STOCK VIDE"),
                          const SizedBox(height: 12),
                          _buildGrid([
                            _infoBox("Recharge Vide", data['quantite_recharge_vide'], Colors.green, PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill)),
                            _infoBox("Échange Vide", data['quantite_echange_vide'], AppColors.Orange, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill)),
                            _infoBox("Total Vide", (data['quantite_recharge_vide'] ?? 0) + (data['quantite_echange_vide'] ?? 0), Colors.blueGrey, PhosphorIcons.trash(PhosphorIconsStyle.fill)),
                          ]),

                          const SizedBox(height: 25),

                          // --- TARIFS ---
                          _sectionTitle("GRILLE TARIFAIRE"),
                          const SizedBox(height: 12),
                          _buildGrid([
                            _infoBox("Recharge", tarif['price_recharge'], Colors.green, PhosphorIcons.tag(PhosphorIconsStyle.fill), isPrice: true, fmt: formatter),
                            _infoBox("Échange", tarif['price_echange'], AppColors.Orange, PhosphorIcons.tag(PhosphorIconsStyle.fill), isPrice: true, fmt: formatter),
                            _infoBox("Complet", tarif['price_vente'], Colors.blue, PhosphorIcons.tag(PhosphorIconsStyle.fill), isPrice: true, fmt: formatter),
                          ]),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- SECTION BOUTONS FIXES EN BAS ---
            _buildBottomActionButtons(),
          ],
        );
      }),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _showAvarieSheet(),
                icon: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 22),
                label: const Text("SIGNALER UNE AVARIE", 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> details, Map<String, dynamic> data) {
    final bool isAlert = (data['nombre_total'] ?? 0) <= (data['seuil_alerte'] ?? 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(details['marque_name']?.toString().toUpperCase() ?? "PRODUIT",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D3436))),
              Text("Poids: ${details['poids_value'] ?? '0'} kg | Magasin: ${data['magasin_nom'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isAlert ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "TOTAL: ${data['nombre_total']}",
            style: TextStyle(
              color: isAlert ? Colors.red : Colors.green,
              fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(
    title, 
    style: const TextStyle(
      fontSize: 11, 
      fontWeight: FontWeight.w900, 
      color: Colors.black, 
      letterSpacing: 0.8
    ),
  );

  Widget _buildGrid(List<Widget> children) => Row(children: children);

  Widget _infoBox(String label, dynamic value, Color color, IconData icon, {bool isPrice = false, NumberFormat? fmt}) {
    String display = "0";
    if (isPrice && fmt != null) {
      double val = double.tryParse(value?.toString() ?? "0") ?? 0;
      display = "${fmt.format(val)} F";
    } else {
      display = value?.toString() ?? "0";
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            FittedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(display, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvarieSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("DÉCLARER UN PRODUIT DÉFECTUEUX", 
              textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 20),
            _optionTile("Bouteille Pleine (Avarie Pleine)", Colors.green, PhosphorIcons.checkCircle(), () => controller.signalerAvarie(true)),
            const SizedBox(height: 12),
            _optionTile("Bouteille Vide", AppColors.Orange, PhosphorIcons.xCircle(), () => controller.signalerAvarie(false)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(String title, Color color, IconData icon, VoidCallback onTap) => ListTile(
    onTap: () { Get.back(); onTap(); },
    tileColor: color.withOpacity(0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    leading: Icon(icon, color: color, size: 24),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
    trailing: Icon(PhosphorIcons.caretRight(), size: 16, color: color),
  );
}