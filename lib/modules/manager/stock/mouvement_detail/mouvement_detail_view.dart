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
        if (controller.isLoading.value) return const LoadingWidget(text:"Chargement des détails");
        if (controller.mouvement.value == null) return const Center(child: Text("Indisponible"));

        final d = controller.mouvement.value!;
        
        final String displayType = d['type_display'] ?? d['type'] ?? "Mouvement";
        final String agentName = d['agent_details']?['full_name'] ?? d['agent_name'] ?? "N/A";
        final String agentPhone = d['agent_details']?['username'] ?? "N/A";
        final String? destName = d['magasin_destination_name'];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              _buildHeaderCard(d, displayType),
              const SizedBox(height: 20), 
              
              _buildSectionHeader("Détails des Quantités", PhosphorIcons.package()),
              
              _buildModernTile("Recharge Pleine", d['quantite_recharge_charger'], Colors.green, PhosphorIcons.package()),
              _buildModernTile("Recharge Vide", d['quantite_recharge_vide'], Colors.orange, PhosphorIcons.recycle()),
              _buildModernTile("Ventes réalisées", d['quantite_vente'], Colors.blue, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill)),
              _buildModernTile("Échange (Chargé)", d['quantite_echange_charger'], Colors.teal, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill)),
              _buildModernTile("Échange (Vide)", d['quantite_echange_vide'], Colors.blueGrey, PhosphorIcons.minusCircle(PhosphorIconsStyle.fill)),
              
              const SizedBox(height: 20),
              _buildSectionHeader("Traçabilité & Acteurs", PhosphorIcons.shieldCheck()),
              
              _buildAgentCard(d, agentName, agentPhone, destName),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.mouvement.value == null) return const SizedBox();
        final data = controller.mouvement.value!;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "fabReverse",
              mini: true,
              backgroundColor: Colors.red,
              onPressed: () {
                _prepareUpdate(mainController, data);
                _openEditModal("REMBOURSEMENT", Colors.red, mainController);
              },
              child: Icon(PhosphorIcons.xCircle(), color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: "fabEdit",
              mini: true,
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

  // --- COMPOSANTS UI ORIGINAUX ---

  Widget _buildHeaderCard(Map<String, dynamic> data, String displayType) {
    final String source = data['magasin_source_name'] ?? "Inconnu";
    final String? destination = data['magasin_destination_name'];
    final bool hasDestination = destination != null && destination.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.generalColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.generalColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          Text(displayType.toUpperCase(), 
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(source, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              if (hasDestination) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_right_alt, color: Colors.white60, size: 24),
                ),
                Text(destination, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Fait ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.parse(data['created']))}", 
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> data, String name, String phone, String? dest) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        children: [
          _buildInfoRow(PhosphorIcons.userFocus(PhosphorIconsStyle.fill), "Responsable", name),
          _buildInfoRow(PhosphorIcons.phone(PhosphorIconsStyle.fill), "Contact", phone),
          const Divider(height: 24),
          _buildInfoRow(PhosphorIcons.gasCan(PhosphorIconsStyle.fill), "Article", data['produit_name']),
          _buildInfoRow(PhosphorIcons.storefront(PhosphorIconsStyle.fill), "Magasin Source", data['magasin_source_name'] ?? "Inconnu"),
          if (dest != null && dest.isNotEmpty)
            _buildInfoRow(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), "Magasin Destination", dest),
          const Divider(height: 24),
          _buildInfoRow(PhosphorIcons.clockClockwise(PhosphorIconsStyle.fill), "Dernière modification", 
              DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.parse(data['modified']))),
        ],
      ),
    );
  }

  Widget _buildModernTile(String l, dynamic v, Color c, IconData i, {String suffix = ""}) => Container(
    margin: const EdgeInsets.only(bottom: 8), 
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade100)
    ), 
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(i, color: c, size: 18),
        ),
        const SizedBox(width: 12), 
        Text(l, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)), 
        const Spacer(), 
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(v.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: c)),
            const SizedBox(width: 4),
            Text(suffix, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          ],
        )
      ]
    )
  );

  Widget _buildSectionHeader(String t, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4), 
    child: Row(children: [
      Icon(i, size: 16, color: AppColors.generalColor), 
      const SizedBox(width: 8), 
      Text(t.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade700, letterSpacing: 0.5))
    ])
  );

  Widget _buildInfoRow(IconData icon, String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, color: Colors.blueGrey.shade300, size: 16), 
        const SizedBox(width: 12), 
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)), 
              Text(value ?? "N/A", style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)
            ]
          )
        )
      ]
    ),
  );

  // --- LOGIQUE DE PRÉPARATION & MODAL (STYLE ORIGINAL CONSERVÉ) ---

  void _prepareUpdate(MouvementController mainCtrl, Map<String, dynamic> data) {
    mainCtrl.selectedStockId.value = data['stock']?.toString() ?? "";
    mainCtrl.selectedDestinationStockId.value = data['destination_stock']?.toString() ?? "";
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
        child: Column(
          children: [
            _buildModalHeader(title, color),
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Source (Produit & Magasin)"),
                    _buildStockDropdown(mainCtrl, isSource: true),
                    if (title == "TRANSFERT" || title == "REMBOURSEMENT") ...[
                      const SizedBox(height: 20),
                      _label("Destination (Magasin)"),
                      _buildStockDropdown(mainCtrl, isSource: false),
                    ],
                    const SizedBox(height: 20),
                    _field("Recharge Chargée", mainCtrl.qRechargeCharger, Colors.green, PhosphorIcons.package(PhosphorIconsStyle.fill)),
                    _field("Recharge Vide", mainCtrl.qRechargeVide, Colors.orange, PhosphorIcons.recycle(PhosphorIconsStyle.fill)),
                    _field("Quantité Vente", mainCtrl.qVente, Colors.blue, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill)),
                    _field("Échange Chargé", mainCtrl.qEchangeCharger, Colors.teal, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill)),
                    _field("Échange Vide", mainCtrl.qEchangeVide, Colors.blueGrey, PhosphorIcons.minusCircle(PhosphorIconsStyle.fill)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color, 
                  minimumSize: const Size(double.infinity, 55), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  final body = {
                    "type": title,
                    "stock": mainCtrl.selectedStockId.value,
                    if (title == "TRANSFERT" || title == "REMBOURSEMENT") "destination_stock": mainCtrl.selectedDestinationStockId.value,
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

  Widget _buildModalHeader(String t, Color c) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18)), IconButton(onPressed: () => Get.back(), icon: Icon(PhosphorIcons.xCircle(), color: Colors.grey))]);
  
  Widget _field(String l, TextEditingController c, Color col, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
      decoration: InputDecoration(
        labelText: l,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
        prefixIcon: Container(
          width: 44, height: 44, margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Icon(icon, color: AppColors.generalColor, size: 22),
        ),
        filled: true, fillColor: Colors.white, 
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.generalColor, width: 1.8)),
      ),
    ),
  );

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)));

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
}