import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../modules/appColors/appColors.dart'; 
import '../../../loading/loading.dart';
import 'detail_session_controller.dart';

class DetailSessionView extends GetView<DetailSessionController> {
  const DetailSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Détails de la Session", 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(text: "Analyse du chargement...");
        }

        final s = controller.session.value;
        if (s == null) {
          return const Center(child: Text("Aucun détail disponible"));
        }

        final items = s['items'] as List? ?? [];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(s),
              const SizedBox(height: 20),
              _buildSectionHeader("Inventaire des produits", PhosphorIcons.package(PhosphorIconsStyle.fill)),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildProductCard(items[index]),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final s = controller.session.value;
        if (s != null && s['is_close'] == false) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.generalColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () => _openCloseSessionModal(context),
              child: const Text("CLÔTURER LA SESSION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  // --- FORMATAGE DATES ---
  String _formatRealDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == "null") return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) { return "Format invalide"; }
  }

  Widget _buildHeaderCard(Map<String, dynamic> s) {
    bool isClosed = s['is_close'] ?? false;
    String dateOpenStr = _formatRealDate(s['created']);
    String dateCloseStr = _formatRealDate(s['close_date']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.generalColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.generalColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isClosed ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isClosed ? "SESSION CLÔTURÉE" : "SESSION ACTIVE",
              style: TextStyle(color: isClosed ? Colors.orange : Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(s['agent_livraison_name'] ?? "Livreur inconnu", 
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, color: Colors.white70, size: 14),
              const SizedBox(width: 8),
              Text("Début: $dateOpenStr", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          if (isClosed) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: Colors.white70, size: 14),
                const SizedBox(width: 8),
                Text("Fin: $dateCloseStr", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['produit_nom'] ?? "Produit #${item['stock'].toString().substring(0, 5)}", 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.blueGrey)),
          const Divider(height: 24),
          
          _rowTitle("ÉTAT DU CHARGEMENT (OUVERTURE)"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard("RECHARGE", controller.formatQty(item['quantite_ouverture_recharge']), AppColors.generalColor, PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard("ECHANGE", controller.formatQty(item['quantite_ouverture_echange']), AppColors.generalColor, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard("VENTE", controller.formatQty(item['quantite_ouverture_vente']), AppColors.generalColor, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill))),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _rowTitle("RETOURS PLEINS (CLÔTURE)"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard("RECH.", controller.formatQty(item['quantite_cloture_recharge_charger']), AppColors.generalColor, PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard("ECH.", controller.formatQty(item['quantite_cloture_echange_charger']), AppColors.generalColor, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard("VENTE", controller.formatQty(item['quantite_cloture_vente_charger']), AppColors.generalColor, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill))),
            ],
          ),

          const SizedBox(height: 20),

          _rowTitle("RETOURS VIDES (CLÔTURE)"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard("V. RECH", controller.formatQty(item['quantite_cloture_recharge_vide']), Colors.red, PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard("V. ECH", controller.formatQty(item['quantite_cloture_echange_vide']), Colors.red, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard("V. VENTE", controller.formatQty(item['quantite_cloture_vente_vide']), Colors.red, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: color)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String t, IconData i) {
    return Padding(padding: const EdgeInsets.only(bottom: 10, left: 4), child: Row(children: [
          Icon(i, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Text(t.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
    ]));
  }

  // --- MODAL DE CLÔTURE ---

  void _openCloseSessionModal(BuildContext context) {
    controller.prepareClotureFields();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            _buildHandle(),
            _buildModalHeader("CLÔTURE DES RETOURS", AppColors.generalColor),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: controller.clotureItems.length,
                itemBuilder: (context, index) {
                  final item = controller.clotureItems[index];
                  final rawItem = controller.session.value?['items'][index];
                  return _buildClotureInputRow(item, rawItem);
                },
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.generalColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: () => controller.submitCloture(),
              child: const Text("VALIDER LA CLÔTURE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildClotureInputRow(ClotureItemInput item, dynamic rawItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
          const SizedBox(height: 15),
          
          _rowTitle("UNITÉS PLEINES"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _qtyInput(PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill), "Recharge", item.qPleineRecharge, controller.formatQty(rawItem['quantite_ouverture_recharge']))),
              const SizedBox(width: 8),
              Expanded(child: _qtyInput(PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill), "Échange", item.qPleineEchange, controller.formatQty(rawItem['quantite_ouverture_echange']))),
              const SizedBox(width: 8),
              // VENTE : MODIFIABLE ET REMPLIE PAR LES DONNÉES RÉELLES
              Expanded(child: _qtyInput(PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill), "Vente", item.qPleineVente, controller.formatQty(rawItem['quantite_ouverture_vente']))),
            ],
          ),
          const SizedBox(height: 15),
          _rowTitle("UNITÉS VIDES"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _qtyInput(PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill), "Rech.", item.qVideRecharge, controller.formatQty(rawItem['quantite_ouverture_recharge']))),
              const SizedBox(width: 8),
              Expanded(child: _qtyInput(PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill), "Ech.", item.qVideEchange, controller.formatQty(rawItem['quantite_ouverture_echange']))),
              // VENTE : MODIFIABLE ET REMPLIE PAR LES DONNÉES RÉELLES
              Expanded(child: _qtyInput(PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill), "Vente", item.qVideVente, "0")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyInput(IconData icon, String label, TextEditingController ctrl, String ouvVal) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.generalColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            isDense: true,
            filled: true,
            fillColor: AppColors.generalColor.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.generalColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.generalColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.generalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            "Ouv: $ouvVal",
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.generalColor),
          ),
        ),
      ],
    );
  }

  Widget _rowTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5));
  }

  Widget _buildModalHeader(String t, Color c) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: [
      Text(t, style: TextStyle(color: Colors.blueGrey.shade800, fontWeight: FontWeight.w900, fontSize: 17)),
      GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200)
          ),
          child: const Icon(Icons.close, size: 20, color: Colors.grey),
        ),
      ),
    ]
  );

  Widget _buildHandle() => Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)));
}