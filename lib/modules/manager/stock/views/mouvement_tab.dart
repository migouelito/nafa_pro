import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../appColors/appColors.dart';
import '../../../loading/loading.dart'; 
import 'mouvement_controller.dart';
import '../../../../routes/app_routes.dart';

class MouvementTab extends GetView<MouvementController> {
  const MouvementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      body: Column(
        children: [
          _buildTopFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.movementHistory.isEmpty) {
                return const LoadingWidget(text: "Chargement des mouvements...");
              }

              final moves = controller.filteredMouvements;

              return RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                child: moves.isEmpty 
                  ? const Center(child: Text("Aucun mouvement trouvé."))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: moves.length,
                      itemBuilder: (context, index) => _buildCard(moves[index]),
                    ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  Widget _buildTopFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        children: [
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
              dropdownColor: Colors.white,
                value: controller.selectedTypeFilter.value,
                isExpanded: true,
                // REMPLACE Icons.filter_list PAR LA FLÈCHE DE SÉLECTION
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey),
                items: [
                  "TOUS",
                  "APPROVISIONNEMENT",
                  "TRANSFERT",
                  "REMBOURSEMENT"
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) controller.selectedTypeFilter.value = v;
                },
              ),
            )),
          ),
        ],
      ),
    );
  }

  // --- RESTE DU CODE IDENTIQUE ---

  Widget _buildCard(StockMovement m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed(Routes.DETAILMOUVEMENT, arguments: m.id),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: m.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(PhosphorIcons.arrowsClockwise(), color: m.color, size: 24),
          ),
          title: Text(m.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(m.target, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(m.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.blueGrey)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('HH:mm').format(m.date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(DateFormat('dd MMM').format(m.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  void _openFormModal(String title, Color color) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9, 
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(title, color),
              const Divider(height: 30),
              _label("Source (Produit & Magasin)"),
              _stockDropdown(isSource: true),
              if (title == "TRANSFERT") ...[
                const SizedBox(height: 20),
                _label("Destination (Magasin)"),
                _stockDropdown(isSource: false),
              ],
              const SizedBox(height: 20),
              _field("Recharge Chargée", controller.qRechargeCharger, Colors.green, PhosphorIcons.package()),
              _field("Recharge Vide", controller.qRechargeVide, Colors.orange, PhosphorIcons.recycle()),
              _field("Quantité Vente", controller.qVente, Colors.blue, PhosphorIcons.shoppingCart()),
              _field("Échange Chargé", controller.qEchangeCharger, Colors.teal, PhosphorIcons.arrowsLeftRight()),
              _field("Échange Vide", controller.qEchangeVide, Colors.blueGrey, PhosphorIcons.minusCircle()),
              const SizedBox(height: 30),
              _buildSubmitButton(title, color),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _stockDropdown({required bool isSource}) => Obx(() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          value: isSource 
              ? (controller.selectedStockId.value.isEmpty ? null : controller.selectedStockId.value)
              : (controller.selectedDestinationStockId.value.isEmpty ? null : controller.selectedDestinationStockId.value),
          items: controller.depotStock.map((s) {
            bool isAlreadySelected = isSource ? s.id == controller.selectedDestinationStockId.value : s.id == controller.selectedStockId.value;
            return DropdownMenuItem<String>(
              value: isAlreadySelected ? null : s.id, 
              child: Text("${s.brand} - ${s.type} [P:${s.full} | V:${s.empty}]", 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isAlreadySelected ? Colors.grey[300] : Colors.black87)),
            );
          }).toList(),
          onChanged: (v) {
            if (v == null) return; 
            if (isSource) controller.selectedStockId.value = v; else controller.selectedDestinationStockId.value = v;
          },
        ),
      ),
    );
  });

  Widget _buildFabMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildMiniFab("TRan", PhosphorIcons.arrowsLeftRight(), AppColors.generalColor, "Usine"),
        const SizedBox(height: 12),
        _buildMiniFab("APPro", PhosphorIcons.downloadSimple(), AppColors.generalColor, "Livreur"),
      ],
    );
  }

  Widget _buildMiniFab(String label, IconData icon, Color color, String entity) {
    return FloatingActionButton(
      heroTag: label, mini: true,
      onPressed: () {
        controller.prepareForm(initialEntity: entity);
        _openFormModal(label == "TRan" ? "TRANSFERT" : label == "APPro" ? "APPROVISIONNEMENT" : "REMBOURSEMENT", color);
      },
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _field(String l, TextEditingController c, Color col, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: c, keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: l, prefixIcon: Icon(icon, color: col, size: 20),
        filled: true, fillColor: col.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _buildSubmitButton(String t, Color c) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    onPressed: () => controller.createMouvement(type: t, color: c),
    child: const Text("VALIDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
  );

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)));

  Widget _buildHeader(String t, Color c) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 20)),
          const Text("Saisie du mouvement de stock", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
      IconButton(onPressed: () => Get.back(), icon: Icon(PhosphorIcons.xCircle(), color: Colors.grey)),
    ],
  );
}