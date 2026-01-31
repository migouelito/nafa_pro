import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'mouvement_detail_controller.dart';
import '../../../loading/loading.dart';
import '../views/mouvement_controller.dart';

class MouvementDetailView extends GetView<MouvementDetailController> {
  const MouvementDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MouvementController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Détails du Mouvement", 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget(text: "Chargement...");
        if (controller.mouvement.value == null) return const Center(child: Text("Indisponible"));

        final d = controller.mouvement.value!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(d),
              const Spacer(), 
              _buildSectionHeader("État du Stock", PhosphorIcons.stack()),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Pleine", d['quantite_recharge_charger'], Colors.green, PhosphorIcons.package())),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Vide", d['quantite_recharge_vide'], Colors.orange, PhosphorIcons.recycle())),
                ],
              ),
              const Spacer(),
              _buildSectionHeader("Opérations Commerciales", PhosphorIcons.handshake()),
              _buildModernTile("Ventes réalisées", d['quantite_vente'], Colors.blue, PhosphorIcons.shoppingCart()),
              _buildModernTile("Échange (Chargé)", d['quantite_echange_charger'], Colors.teal, PhosphorIcons.arrowsLeftRight()),
              _buildModernTile("Échange (Vide)", d['quantite_echange_vide'], Colors.blueGrey, PhosphorIcons.minusCircle()),
              const Spacer(),
              _buildAgentCard(d),
            ],
          ),
        );
      }),
      // --- BOUTONS FLOTTANTS (STYLE MINI COMME DANS LE TAB) ---
      floatingActionButton: Obx(() {
        if (controller.mouvement.value == null) return const SizedBox();
        final data = controller.mouvement.value!;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bouton Remboursement (ROUGE MINI)
            FloatingActionButton(
              heroTag: "fabReverse",
              mini: true, // APPLIQUE LA FORME MINI
              backgroundColor: Colors.red,
              onPressed: () {
                _prepareUpdate(mainController, data);
                _openEditModal("REMBOURSEMENT", Colors.red, mainController);
              },
              child: Icon(PhosphorIcons.xCircle(), color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            // Bouton Modifier (BLEU MINI)
            FloatingActionButton(
              heroTag: "fabEdit",
              mini: true, // APPLIQUE LA FORME MINI
              backgroundColor: AppColors.generalColor,
              onPressed: () {
                _prepareUpdate(mainController, data);
                _openEditModal(data['type'] ?? "MODIFICATION", AppColors.generalColor, mainController);
              },
              child: Icon(PhosphorIcons.pencilSimple(), color: Colors.white, size: 20),
            ),
          ],
        );
      }),
    );
  }

  // --- LOGIQUE DE PRÉPARATION & MODAL ---

  void _prepareUpdate(MouvementController mainCtrl, Map<String, dynamic> data) {
    mainCtrl.selectedStockId.value = data['stock'] ?? "";
    mainCtrl.selectedDestinationStockId.value = data['destination_stock'] ?? "";
    mainCtrl.qRechargeCharger.text = (data['quantite_recharge_charger'] ?? 0).toString();
    mainCtrl.qRechargeVide.text = (data['quantite_recharge_vide'] ?? 0).toString();
    mainCtrl.qVente.text = (data['quantite_vente'] ?? 0).toString();
    mainCtrl.qEchangeCharger.text = (data['quantite_echange_charger'] ?? 0).toString();
    mainCtrl.qEchangeVide.text = (data['quantite_echange_vide'] ?? 0).toString();
  }

 void _openEditModal(String title, Color color, MouvementController mainCtrl) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
        ),
        child: Column( // On utilise une Column pour séparer le contenu du bouton fixe
          children: [
            _buildModalHeader(title, color),
            const Divider(height: 20),
            
            // 1. La partie scrollable (champs de saisie)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Source (Produit & Magasin)"),
                    _buildStockDropdown(mainCtrl, isSource: true),
                    if (title == "TRANSFERT") ...[
                      const SizedBox(height: 20),
                      _label("Destination (Magasin)"),
                      _buildStockDropdown(mainCtrl, isSource: false),
                    ],
                    const SizedBox(height: 20),
                    _field("Recharge Chargée", mainCtrl.qRechargeCharger, Colors.green, PhosphorIcons.package()),
                    _field("Recharge Vide", mainCtrl.qRechargeVide, Colors.orange, PhosphorIcons.recycle()),
                    _field("Quantité Vente", mainCtrl.qVente, Colors.blue, PhosphorIcons.shoppingCart()),
                    _field("Échange Chargé", mainCtrl.qEchangeCharger, Colors.teal, PhosphorIcons.arrowsLeftRight()),
                    _field("Échange Vide", mainCtrl.qEchangeVide, Colors.blueGrey, PhosphorIcons.minusCircle()),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 2. La partie fixe en bas (Bouton)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color, 
                  minimumSize: const Size(double.infinity, 55), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5, // Ajout d'une ombre pour montrer qu'il est au-dessus
                ),
                onPressed: () {
                  if (title == "TRANSFERT" && mainCtrl.selectedStockId.value == mainCtrl.selectedDestinationStockId.value) {
                    Get.snackbar("Erreur", "Source et destination identiques !", backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }
                  final body = {
                    "type": title,
                    "stock": mainCtrl.selectedStockId.value,
                    if (title == "TRANSFERT") "destination_stock": mainCtrl.selectedDestinationStockId.value,
                    "quantite_recharge_charger": int.tryParse(mainCtrl.qRechargeCharger.text) ?? 0,
                    "quantite_recharge_vide": int.tryParse(mainCtrl.qRechargeVide.text) ?? 0,
                    "quantite_vente": int.tryParse(mainCtrl.qVente.text) ?? 0,
                    "quantite_echange_charger": int.tryParse(mainCtrl.qEchangeCharger.text) ?? 0,
                    "quantite_echange_vide": int.tryParse(mainCtrl.qEchangeVide.text) ?? 0,
                  };
                  controller.updateMouvement(type: title, body: body);
                },
                child: const Text("METTRE À JOUR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- COMPOSANTS UI RÉUTILISÉS ---

  Widget _buildStockDropdown(MouvementController mainCtrl, {required bool isSource}) => Obx(() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          value: isSource 
              ? (mainCtrl.selectedStockId.value.isEmpty ? null : mainCtrl.selectedStockId.value)
              : (mainCtrl.selectedDestinationStockId.value.isEmpty ? null : mainCtrl.selectedDestinationStockId.value),
          items: mainCtrl.depotStock.map((s) {
            bool isAlreadySelected = isSource ? s.id == mainCtrl.selectedDestinationStockId.value : s.id == mainCtrl.selectedStockId.value;
            return DropdownMenuItem<String>(
              value: isAlreadySelected ? null : s.id, 
              child: Text("${s.brand} - ${s.type}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isAlreadySelected ? Colors.grey[300] : Colors.black87)),
            );
          }).toList(),
          onChanged: (v) {
            if (v == null) return; 
            if (isSource) mainCtrl.selectedStockId.value = v; else mainCtrl.selectedDestinationStockId.value = v;
          },
        ),
      ),
    );
  });

  Widget _buildModalHeader(String t, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18)), IconButton(onPressed: () => Get.back(), icon: Icon(PhosphorIcons.xCircle(), color: Colors.grey))]);
  Widget _field(String l, TextEditingController c, Color col, IconData icon) => Padding(padding: const EdgeInsets.only(bottom: 16), child: TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l, prefixIcon: Icon(icon, color: col, size: 20), filled: true, fillColor: col.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))));
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)));
  Widget _buildHeaderCard(Map<String, dynamic> data) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.generalColor, borderRadius: BorderRadius.circular(20)), child: Column(children: [Text(data['type'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), Text(DateFormat('dd MMMM yyyy à HH:mm').format(DateTime.parse(data['created'])), style: const TextStyle(color: Colors.white70, fontSize: 12))]));
  Widget _buildStatCard(String l, dynamic v, Color c, IconData i) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.1))), child: Column(children: [Icon(i, color: c, size: 22), Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(v.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c))]));
  Widget _buildModernTile(String l, dynamic v, Color c, IconData i) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(i, color: c, size: 20), const SizedBox(width: 12), Text(l, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), const Spacer(), Text(v.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: c))]));
  Widget _buildAgentCard(Map<String, dynamic> data) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [
    _buildInfoRow(PhosphorIcons.user(), "Responsable", data['agent_name']),
    const Divider(),
    _buildInfoRow(PhosphorIcons.package(), "Produit", data['produit_name']),
    const Divider(),
    _buildInfoRow(PhosphorIcons.storefront(), "Magasin / Dépôt", data['magasin_name']),
  ]));
  Widget _buildSectionHeader(String t, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 10, left: 4), child: Row(children: [Icon(i, size: 14, color: Colors.blueGrey), const SizedBox(width: 6), Text(t.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey))]));
  Widget _buildInfoRow(IconData icon, String label, String? value) => Row(children: [Icon(icon, color: Colors.blueGrey.shade300, size: 18), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)), Text(value ?? "N/A", style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)]))]);
}