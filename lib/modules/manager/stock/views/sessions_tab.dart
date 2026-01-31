import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../appColors/appColors.dart';
import '../../../loading/loading.dart'; 
import '../views/session_controler.dart';
import '../../../../routes/app_routes.dart';

class SessionsTab extends GetView<SessionController> {
  const SessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final stockCtrl = controller.stockController;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // --- DROPDOWN DE FILTRAGE DES LIVREURS ---
          _buildLivreurDropdown(),
          
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && stockCtrl.sessionsList.isEmpty) {
                return const LoadingWidget(text: "Chargement des sessions...");
              }

              final sessions = controller.filteredSessions;

              return RefreshIndicator(
                onRefresh: () => controller.loadSessions(),
                child: sessions.isEmpty
                    ? const Center(child: Text("Aucune session trouvée"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Get.toNamed(Routes.DETAILSESSION, arguments: session['id']),
                            child: _buildSessionCard(session),
                          );
                        },
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
          await stockCtrl.getStocks();
          controller.prepareNewSession();
          _openLoadingModal();
        },
      ),
    );
  }

  Widget _buildLivreurDropdown() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Obx(() {
        // Extraction de la liste unique des noms de livreurs depuis sessionsList
        List<String> livreurs = controller.stockController.sessionsList
            .map((e) => (e['agent_livraison_name'] ?? 'Livreur inconnu').toString())
            .toSet()
            .toList();
        
        if (!livreurs.contains("TOUS LES LIVREURS")) {
          livreurs.insert(0, "TOUS LES LIVREURS");
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white, 
              value: controller.selectedLivreur.value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey),
              items: livreurs.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) controller.updateSelectedLivreur(v);
              },
            ),
          ),
        );
      }),
    );
  }

  // --- RESTE DU CODE (IDENTIQUE) ---

  Widget _buildSessionCard(Map<String, dynamic> session) {
    bool isClosed = session['is_close'] ?? false;
    DateTime? date = DateTime.tryParse(session['created'] ?? "");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: (isClosed ? Colors.grey : Colors.blue).withOpacity(0.1),
          child: Icon(isClosed ? PhosphorIcons.checkCircle() : PhosphorIcons.truck(), 
                      color: isClosed ? Colors.grey : Colors.blue),
        ),
        title: Text(
          session['agent_livraison_name'] ?? 'Livreur inconnu',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Responsable: ${session['agent_responsable_name'] ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
            if (date != null)
              Text(DateFormat('dd MMM yyyy à HH:mm').format(date), 
                   style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isClosed ? Colors.redAccent : Colors.green).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isClosed ? "Clôturée" : "Active",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isClosed ? Colors.redAccent : Colors.green),
          ),
        ),
      ),
    );
  }

  void _openLoadingModal() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            const Divider(),
            _buildDriverDropdown(),
            const SizedBox(height: 20),
            Expanded(child: _buildStockList()),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStockList() {
    return ListView.builder(
      itemCount: controller.stockController.chargementStock.length,
      itemBuilder: (c, i) {
        final item = controller.stockController.chargementStock[i];
        final String key = "${item.brand}_${item.type}";
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${item.brand} ${item.type}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Dispo: ${item.fullCount.value} P | ${item.emptyCount.value} V", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              _buildCounter(key),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounter(String key) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.generalColor.withOpacity(0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleBtn(Icons.remove, () => controller.decrement(key), isFilled: false),
          SizedBox(width: 35, child: Obx(() => Text("${controller.counters[key] ?? 0}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)))),
          _circleBtn(Icons.add, () => controller.increment(key), isFilled: true),
        ],
      ),
    );
  }

  Widget _buildDriverDropdown() {
    final stockCtrl = controller.stockController;
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          value: stockCtrl.selectedDriver.value,
          items: stockCtrl.drivers.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => stockCtrl.selectedDriver.value = v!,
        ),
      ),
    ));
  }

  Widget _buildSubmitButton() => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.generalColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    onPressed: () => controller.submitSession(),
    child: const Text("VALIDER LE CHARGEMENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );

  Widget _circleBtn(IconData icon, VoidCallback onTap, {required bool isFilled}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: isFilled ? AppColors.generalColor : AppColors.generalColor.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: isFilled ? Colors.white : AppColors.generalColor, size: 16),
    ),
  );

  Widget _buildHandle() => Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)));
  
  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text("NOUVEAU CHARGEMENT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
    ],
  );
}