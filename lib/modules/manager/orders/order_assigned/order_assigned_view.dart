import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'order_assigned_controller.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
import '../../../loading/loading.dart';
import '../../../services/urlBase.dart'; // Import pour le baseUrl

class OrderAssignedView extends GetView<OrderAssignedController> {
  const OrderAssignedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("SESSIONS DE LIVRAISON", 
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingWidget(text: "Chargement"));
        }

        final activeSessions = controller.sessions.where((s) => s['is_close'] == false).toList();

        if (activeSessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.folderOpen(), size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                const Text("Aucune session active", 
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeSessions.length,
                itemBuilder: (context, index) {
                  final session = activeSessions[index];
                  return _buildSessionCard(session);
                },
              ),
            ),
            _buildStickyActionButton(),
          ],
        );
      }),
    );
  }

  Widget _buildStickyActionButton() {
    return Obx(() {
      bool hasSelection = controller.selectedSessionId.value.isNotEmpty;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: hasSelection ? () => controller.assignOrder() : null,
              icon: Icon(PhosphorIcons.userPlus(PhosphorIconsStyle.bold), size: 18),
              label: Text(
                hasSelection ? "VALIDER L'ASSIGNATION" : "CHOISIR UN LIVREUR", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.generalColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final bool canDeliver = session['can_delive_all'] ?? false;
    final String sessionId = session['id']?.toString() ?? "";
    final List items = session['items'] ?? [];

    return Obx(() {
      bool isSelected = controller.selectedSessionId.value == sessionId;

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.generalColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.generalColor.withOpacity(0.05) : Colors.black.withOpacity(0.03), 
              blurRadius: 10, 
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Theme(
          data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.generalColor.withOpacity(0.1),
              child: Icon(PhosphorIcons.user(), color: AppColors.generalColor, size: 20),
            ),
            title: Text(
              session['agent_livraison_name']?.toString().toUpperCase() ?? "AGENT INCONNU",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              canDeliver ? "ÉLIGIBLE" : "NON ÉLIGIBLE (STOCK INSUFFISANT)", 
              style: TextStyle(
                color: canDeliver ? Colors.green : Colors.red, 
                fontWeight: FontWeight.bold, 
                fontSize: 10
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: canDeliver ? () => controller.toggleSelection(sessionId) : null,
                  child: Icon(
                    isSelected ? PhosphorIcons.checkSquare(PhosphorIconsStyle.fill) : PhosphorIcons.square(),
                    color: isSelected ? AppColors.generalColor : (canDeliver ? Colors.grey : Colors.grey.withOpacity(0.2)),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(PhosphorIcons.caretDown(), size: 16, color: Colors.blueGrey),
              ],
            ),
            children: [
              const Divider(height: 1),
              if (items.isNotEmpty)
                ...items.map((item) => _buildStockItemRow(item)).toList(),
              
           
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStockItemRow(Map<String, dynamic> item) {
    // Gestion de l'image
    final String? imagePath = item['produit_image'];
    final String fullImageUrl = (imagePath != null && imagePath.isNotEmpty) 
        ? "${ApiUrlPage.baseUrl}$imagePath" 
        : "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // AFFICHAGE DE L'IMAGE DU PRODUIT
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              Icon(PhosphorIcons.package(), size: 18, color: Colors.grey),
                        )
                      : Icon(PhosphorIcons.package(), size: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item['produit_name'] ?? item['produit'] ?? "Produit", 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF2D3436))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _indicator("RECHARGE", item['quantite_ouverture_recharge'], Colors.green),
              _indicator("ÉCHANGE", item['quantite_ouverture_echange'], AppColors.Orange),
              _indicator("VENTE", item['quantite_ouverture_vente'], Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicator(String label, dynamic value, Color color) {
    String displayValue = "0";
    if (value != null && value is num) {
      if (value > 0 && value < 1000000) {
        displayValue = value.toString();
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(displayValue, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }
}