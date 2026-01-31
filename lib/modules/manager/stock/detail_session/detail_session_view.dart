import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'detail_session_controller.dart';
import '../../../loading/loading.dart';

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
       iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(text: "Analyse du chargement...");
        }

        if (controller.session.value == null) {
          return const Center(child: Text("Aucun détail disponible"));
        }

        final s = controller.session.value!;
        final items = s['items'] as List? ?? [];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(s),
              const SizedBox(height: 20),
              _buildSectionHeader("Inventaire des produits", PhosphorIcons.package()),
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
      // --- BOUTON DE CLÔTURE EN BAS ---
      bottomNavigationBar: Obx(() {
        if (controller.session.value != null && controller.session.value!['is_close'] == false) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.generalColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () => _openCloseSessionModal(context),
              child: const Text(
                "CLÔTURER LA SESSION",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),

          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  // --- COMPOSANTS UI (Inchangés pour le style) ---

  Widget _buildHeaderCard(Map<String, dynamic> s) {
    bool isClosed = s['is_close'] ?? false;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isClosed ? Colors.grey : AppColors.generalColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(isClosed ? "SESSION CLÔTURÉE" : "SESSION ACTIVE", 
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text("Ouverte le ${DateFormat('dd MMMM yyyy à HH:mm').format(DateTime.parse(s['created']))}",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
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
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.cube(), color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text("Stock ID: ${item['stock'].toString().substring(0, 12)}...", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard("OUVERTURE", controller.formatQty(item['quantite_ouverture']), Colors.blueGrey, PhosphorIcons.doorOpen())),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("VENDU", controller.formatQty(item['quantite_vendu']), Colors.green, PhosphorIcons.shoppingCart())),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard("CLÔTURE (P)", controller.formatQty(item['quantite_cloture_charger']), Colors.blue, PhosphorIcons.package())),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("CLÔTURE (V)", controller.formatQty(item['quantite_cloture_vide']), Colors.orange, PhosphorIcons.recycle())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
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
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            _buildModalHeader("CLÔTURE DE SESSION",AppColors.generalColor),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: controller.clotureItems.length,
                itemBuilder: (context, index) {
                  final item = controller.clotureItems[index];
                  return _buildClotureInputRow(item);
                },
              ),
            ),
            const SizedBox(height: 20),
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

Widget _buildClotureInputRow(ClotureItemInput item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, 
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Produit: ${item.stockId.substring(0, 12)}...", 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 12),
          // --- PREMIÈRE LIGNE : PLEINE & VIDE ---
          Row(
            children: [
              Expanded(child: _miniField("Pleine", item.qPleine, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _miniField("Vide", item.qVide, Colors.orange)),
            ],
          ),
          const SizedBox(height: 10), // Espace entre les deux lignes de saisie
          // --- DEUXIÈME LIGNE : VENDU & ÉCHANGE ---
          Row(
            children: [
              Expanded(child: _miniField("Vendu", item.qVendu, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _miniField("Échange", item.qEchange, Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniField(String label, TextEditingController ctrl, Color color) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildModalHeader(String t, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18)),
    IconButton(onPressed: () => Get.back(), icon: Icon(PhosphorIcons.xCircle(), color: Colors.grey))
  ]);
}