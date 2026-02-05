import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../appColors/appColors.dart';
import '../../../loading/loading.dart'; 
import '../views/session_controler.dart';
import '../../../../routes/app_routes.dart';

class SessionsTab extends GetView<SessionController> {
  const SessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildLivreurDropdown(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessionsList.isEmpty) {
                return const LoadingWidget(text: "Chargement...");
              }
              final sessions = controller.filteredSessions;
              return RefreshIndicator(
                color: AppColors.generalColor,
                backgroundColor: Colors.white,
                onRefresh: () => controller.loadSessions(),
                child: sessions.isEmpty
                    ? const Center(child: Text("Aucune session trouvée"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) => _buildSessionCard(sessions[index]),
                      ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "LoadFab", mini: true,
        backgroundColor: AppColors.generalColor,
        child: Icon(PhosphorIcons.uploadSimple(), color: Colors.white),
        onPressed: () async {
          await controller.getAvailableStock();
          controller.prepareNewSession();
          _openLoadingModal();
        },
      ),
    );
  }

  // --- DROPDOWN FILTRE ---
  Widget _buildLivreurDropdown() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Obx(() {
        List<String> livreurs = controller.sessionsList
            .map((e) => (e['agent_livraison_name'] ?? 'Livreur inconnu').toString())
            .toSet().toList();
        if (!livreurs.contains("TOUS LES LIVREURS")) livreurs.insert(0, "TOUS LES LIVREURS");

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: controller.selectedLivreur.value,
              isExpanded: true,
              items: livreurs.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)))).toList(),
              onChanged: (v) => controller.updateSelectedLivreur(v!),
            ),
          ),
        );
      }),
    );
  }

  // --- MODAL DE CHARGEMENT ---
  void _openLoadingModal() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(), 
            const Divider(height: 30),
            _buildDriverDropdown(),
            const SizedBox(height: 20),
            Expanded(child: _buildStockList()),
            const SizedBox(height: 15),
            _buildSubmitButton(),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStockList() {
    return Obx(() => ListView.builder(
      itemCount: controller.chargementStock.length,
      itemBuilder: (c, i) {
        final item = controller.chargementStock[i];
        final String id = item['id'].toString();
        
        int stockR = int.tryParse(item['quantite_recharge_charger']?.toString() ?? "0") ?? 0;
        int stockE = int.tryParse(item['quantite_echange_charger']?.toString() ?? "0") ?? 0;
        int stockV = int.tryParse(item['quantite_vente']?.toString() ?? "0") ?? 0;

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
              Text("${item['produit_nom']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _qtyInput(PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill), "Recharge", controller.countersRecharge[id]!, AppColors.generalColor, stockR)),
                  const SizedBox(width: 8),
                  Expanded(child: _qtyInput(PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill), "Échange", controller.countersEchange[id]!, AppColors.generalColor, stockE)),
                  const SizedBox(width: 8),
                  Expanded(child: _qtyInput(PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill), "Vente", controller.countersVente[id]!, AppColors.generalColor, stockV)),
                ],
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _qtyInput(IconData icon, String label, TextEditingController ctrl, Color color, int max) {
    bool isOff = max <= 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isOff ? Colors.grey.shade400 : AppColors.generalColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOff ? Colors.grey.shade400 : Colors.blueGrey)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          readOnly: isOff,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isOff ? Colors.grey.shade400 : Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            isDense: true,
            filled: true,
            fillColor: isOff ? Colors.grey.shade100 : AppColors.generalColor.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isOff ? Colors.grey.shade200 : AppColors.generalColor.withOpacity(0.2)),
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
            color: isOff ? Colors.grey.shade200 : AppColors.generalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            "Stock: $max",
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isOff ? Colors.grey : AppColors.generalColor),
          ),
        ),
      ],
    );
  }

  // --- HEADER DU MODAL AVEC BOUTON X GRIS ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("NOUVEAU CHARGEMENT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black)),
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
      ],
    );
  }

  // --- AUTRES COMPOSANTS ---
  Widget _buildSessionCard(Map<String, dynamic> session) {
    final bool isClosed = session['is_close'] ?? false;
    final List items = session['items'] ?? [];

    String rawCreatedDate = "";
    if (items.isNotEmpty) {
      rawCreatedDate = items[0]['created']?.toString() ?? "";
    }

    String formatDT(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "null") return "Date inconnue";
      try {
        DateTime dt = DateTime.parse(dateStr).toLocal();
        return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        return "Format invalide";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => Get.toNamed(Routes.DETAILSESSION, arguments: session['id']),
        leading: CircleAvatar(
          backgroundColor: AppColors.generalColor.withOpacity(0.1),
          child: Icon(
            isClosed ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.truck(PhosphorIconsStyle.fill),
            color: AppColors.generalColor,
          ),
        ),
        title: Text(
          session['agent_livraison_name'] ?? 'Livreur inconnu',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              "Responsable: ${session['agent_responsable_name'] ?? 'N/A'}",
              style:  TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              "Ouvert le: ${formatDT(rawCreatedDate)}",
              style: TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            if (isClosed) ...[
              const SizedBox(height: 2),
              Text(
                "Clos le: ${formatDT(session['close_date']?.toString())}",
                style: TextStyle(fontSize: 11, color: Colors.red,fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isClosed ? Colors.red : Colors.green).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isClosed ? "Clôturée" : "Active",
            style: TextStyle(
              fontSize: 10,
              color: isClosed ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverDropdown() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          value: controller.selectedDriver.value,
          items: controller.drivers.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13,fontWeight:FontWeight.w900,color: Colors.black)))).toList(),
          onChanged: (v) => controller.selectedDriver.value = v!,
        ),
      ),
    ));
  }

  Widget _buildSubmitButton() => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.generalColor, 
      foregroundColor: Colors.white, 
      minimumSize: const Size(double.infinity, 55), 
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
    ),
    onPressed: () => controller.submitSession(),
    child: const Text("VALIDER LE CHARGEMENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
  );

  Widget _buildHandle() => Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)));
}