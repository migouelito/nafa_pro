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
      backgroundColor: const Color(0xFFF8F9FB), 
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
                backgroundColor: Colors.white,
                color: AppColors.generalColor,
                onRefresh: () => controller.refreshData(),
                child: moves.isEmpty 
                  ? const Center(child: Text("Aucun mouvement trouvé.", style: TextStyle(color: Colors.grey)))
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
      child: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.white,
            value: controller.selectedTypeFilter.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            items: ["TOUS LES MOUVEMENTS", "APPROVISIONNEMENT", "TRANSFERT", "REMBOURSEMENT"]
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900,color: Colors.black)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) controller.selectedTypeFilter.value = v;
            },
          ),
        ),
      )),
    );
  }

  Widget _buildCard(StockMovement m) {
    IconData typeIcon;
    if (m.type.contains("APPROVISIONNEMENT")) {
      typeIcon = PhosphorIcons.arrowDown(PhosphorIconsStyle.bold);
    } else if (m.type.contains("TRANSFERT")) {
      typeIcon = PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.bold);
    } else if (m.type.contains("REMBOURSEMENT")) {
      typeIcon = PhosphorIcons.x(PhosphorIconsStyle.bold);
    } else {
      typeIcon = PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed(Routes.DETAILMOUVEMENT, arguments: m.id),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: m.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(typeIcon, color: m.color, size: 22),
          ),
          title: Text(m.type, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(m.target, style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w700)),
                  
                  if (m.destinationName != null && m.destinationName!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_right_alt, size: 18, color: Colors.grey[400]),
                    ),
                    Text(m.destinationName!, style: TextStyle(color: m.color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(m.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.blueGrey)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('HH:mm').format(m.date), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2D3436))),
              Text(DateFormat('dd MMM').format(m.date), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _openFormModal(String title, Color color) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: _buildHeader(title, color),
            ),
            const Divider(indent: 20, endIndent: 20),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    _label("PRODUIT SOURCE"),
                    _stockDropdown(isSource: true, currentTitle: title),
                    if (title == "TRANSFERT") ...[
                      const SizedBox(height: 20),
                      _label("MAGASIN DESTINATION"),
                      _stockDropdown(isSource: false, currentTitle: title),
                    ],
                    const SizedBox(height: 25),
                    _label("QUANTITÉS À SAISIR"),
                    _field("Bouteilles recharge Chargées ", controller.qRechargeCharger, Colors.green, PhosphorIcons.package(PhosphorIconsStyle.fill)),
                    _field("Bouteilles recharge Vides", controller.qRechargeVide, Colors.orange, PhosphorIcons.recycle(PhosphorIconsStyle.fill)),
                    _field("Bouteilles  Ventes", controller.qVente, Colors.blue, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill)),
                    _field("Bouteilles Échange Chargés", controller.qEchangeCharger, Colors.teal, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill)),
                    _field("Bouteilles Échange Vides", controller.qEchangeVide, Colors.blueGrey, PhosphorIcons.minusCircle(PhosphorIconsStyle.fill)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: _buildSubmitButton(title, color),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _stockDropdown({required bool isSource, required String currentTitle}) => Obx(() {
    // Récupération du stock source sélectionné pour comparer la marque
    StockItem? sourceItem;
    if (!isSource && currentTitle == "TRANSFERT") {
      sourceItem = controller.depotStock.firstWhereOrNull((s) => s.id == controller.selectedStockId.value);
    }

    // Filtrage de la liste pour la destination
    List<StockItem> displayList = controller.depotStock;
    if (!isSource && currentTitle == "TRANSFERT" && sourceItem != null) {
      // On ne garde que les stocks qui ont la même marque (brand) mais un magasin (type) différent
      displayList = controller.depotStock.where((s) => 
        s.brand == sourceItem!.brand && s.id != sourceItem.id
      ).toList();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          hint: Text(isSource ? "Sélectionner source" : "Sélectionner destination", style: const TextStyle(fontSize: 12)),
          value: isSource 
              ? (controller.selectedStockId.value.isEmpty ? null : controller.selectedStockId.value)
              : (controller.selectedDestinationStockId.value.isEmpty ? null : controller.selectedDestinationStockId.value),
          items: displayList.map((s) {
            return DropdownMenuItem<String>(
              value: s.id, 
              child: Text(
                "${s.brand} - ${s.type} [Récharge:${s.full} | Echange:${s.echangeFull} | Vente:${s.vente}]", 
                style: const TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.w700, 
                  color: Color(0xFF2D3436)
                )
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v == null) return; 
            if (isSource) {
              controller.selectedStockId.value = v;
              // On réinitialise la destination si on change la source pour forcer un nouveau choix compatible
              controller.selectedDestinationStockId.value = "";
            } else {
              controller.selectedDestinationStockId.value = v;
            }
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
        _buildMiniFab("APPro", PhosphorIcons.arrowDown(), AppColors.generalColor, "Livreur"),
      ],
    );
  }

  Widget _buildMiniFab(String label, IconData icon, Color color, String entity) {
    return FloatingActionButton(
      heroTag: label, mini: true,
      elevation: 4,
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
      controller: c,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
      decoration: InputDecoration(
        labelText: l,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
        
        prefixIcon: Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100, 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(
            icon,
            color: AppColors.generalColor, 
            size: 22, 
          ),
        ),

        filled: true,
        fillColor: Colors.white, 
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.generalColor, width: 1.8),
        ),
      ),
    ),
  );

  Widget _buildSubmitButton(String t, Color c) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: c, 
      minimumSize: const Size(double.infinity, 60), 
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
    ),
    onPressed: () => controller.createMouvement(type: t, color: c),
    child: const Text("VALIDER LE MOUVEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 14)),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4), 
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blueGrey, letterSpacing: 1.1))
  );

  Widget _buildHeader(String t, Color c) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          const Text("Enregistrement du stock", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
      GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: Icon(PhosphorIcons.x(), color: Colors.grey, size: 20),
        ),
      ),
    ],
  );
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import '../../../appColors/appColors.dart';
// import '../../../loading/loading.dart'; 
// import 'mouvement_controller.dart';
// import '../../../../routes/app_routes.dart';

// class MouvementTab extends GetView<MouvementController> {
//   const MouvementTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB), 
//       body: Column(
//         children: [
//           _buildTopFilters(),
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value && controller.movementHistory.isEmpty) {
//                 return const LoadingWidget(text: "Chargement des mouvements...");
//               }

//               final moves = controller.filteredMouvements;

//               return RefreshIndicator(
//                 backgroundColor: Colors.white,
//                 color: AppColors.generalColor,
//                 onRefresh: () => controller.refreshData(),
//                 child: moves.isEmpty 
//                   ? const Center(child: Text("Aucun mouvement trouvé.", style: TextStyle(color: Colors.grey)))
//                   : ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       itemCount: moves.length,
//                       itemBuilder: (context, index) => _buildCard(moves[index]),
//                     ),
//               );
//             }),
//           ),
//         ],
//       ),
//       floatingActionButton: _buildFabMenu(),
//     );
//   }

//   Widget _buildTopFilters() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
//       child: Obx(() => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
//           border: Border.all(color: Colors.grey.shade100),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             dropdownColor: Colors.white,
//             value: controller.selectedTypeFilter.value,
//             isExpanded: true,
//             icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
//             items: ["TOUS LES MOUVEMENTS", "APPROVISIONNEMENT", "TRANSFERT", "REMBOURSEMENT"]
//                 .map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900,color: Colors.black)),
//               );
//             }).toList(),
//             onChanged: (v) {
//               if (v != null) controller.selectedTypeFilter.value = v;
//             },
//           ),
//         ),
//       )),
//     );
//   }

//   Widget _buildCard(StockMovement m) {
//     IconData typeIcon;
//     if (m.type.contains("APPROVISIONNEMENT")) {
//       typeIcon = PhosphorIcons.arrowDown(PhosphorIconsStyle.bold);
//     } else if (m.type.contains("TRANSFERT")) {
//       typeIcon = PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.bold);
//     } else if (m.type.contains("REMBOURSEMENT")) {
//       typeIcon = PhosphorIcons.x(PhosphorIconsStyle.bold);
//     } else {
//       typeIcon = PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold);
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: () => Get.toNamed(Routes.DETAILMOUVEMENT, arguments: m.id),
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           leading: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: m.color.withOpacity(0.1), shape: BoxShape.circle),
//             child: Icon(typeIcon, color: m.color, size: 22),
//           ),
//           title: Text(m.type, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3)),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 4),
//               Wrap(
//                 crossAxisAlignment: WrapCrossAlignment.center,
//                 children: [
//                   Text(m.target, style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w700)),
                  
//                   if (m.destinationName != null && m.destinationName!.isNotEmpty) ...[
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 6),
//                       child: Icon(Icons.arrow_right_alt, size: 18, color: Colors.grey[400]),
//                     ),
//                     Text(m.destinationName!, style: TextStyle(color: m.color, fontSize: 12, fontWeight: FontWeight.bold)),
//                   ],
//                 ],
//               ),
//               const SizedBox(height: 2),
//               Text(m.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.blueGrey)),
//             ],
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(DateFormat('HH:mm').format(m.date), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2D3436))),
//               Text(DateFormat('dd MMM').format(m.date), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openFormModal(String title, Color color) {
//     Get.bottomSheet(
//       Container(
//         height: Get.height * 0.88,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
//               child: _buildHeader(title, color),
//             ),
//             const Divider(indent: 20, endIndent: 20),
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 15),
//                     _label("PRODUIT SOURCE"),
//                     _stockDropdown(isSource: true, currentTitle: title),
//                     if (title == "TRANSFERT") ...[
//                       const SizedBox(height: 20),
//                       _label("MAGASIN DESTINATION"),
//                       _stockDropdown(isSource: false, currentTitle: title),
//                     ],
//                     const SizedBox(height: 25),
//                     _label("QUANTITÉS À SAISIR"),
//                     _field("Bouteilles recharge Chargées ", controller.qRechargeCharger, Colors.green, PhosphorIcons.package(PhosphorIconsStyle.fill)),
//                     _field("Bouteilles recharge Vides", controller.qRechargeVide, Colors.orange, PhosphorIcons.recycle(PhosphorIconsStyle.fill)),
//                     _field("Bouteilles  Ventes", controller.qVente, Colors.blue, PhosphorIcons.shoppingCart(PhosphorIconsStyle.fill)),
//                     _field("Bouteilles Échange Chargés", controller.qEchangeCharger, Colors.teal, PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill)),
//                     _field("Bouteilles Échange Vides", controller.qEchangeVide, Colors.blueGrey, PhosphorIcons.minusCircle(PhosphorIconsStyle.fill)),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
//               child: _buildSubmitButton(title, color),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }

//   Widget _stockDropdown({required bool isSource, required String currentTitle}) => Obx(() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15), 
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           dropdownColor: Colors.white,
//           isExpanded: true,
//           value: isSource 
//               ? (controller.selectedStockId.value.isEmpty ? null : controller.selectedStockId.value)
//               : (controller.selectedDestinationStockId.value.isEmpty ? null : controller.selectedDestinationStockId.value),
//           items: controller.depotStock.map((s) {
            
//             // LOGIQUE DE GRISE : Uniquement si c'est un TRANSFERT
//             bool isAlreadySelected = false;
//             if (currentTitle == "TRANSFERT") {
//               isAlreadySelected = isSource 
//                 ? s.id == controller.selectedDestinationStockId.value 
//                 : s.id == controller.selectedStockId.value;
//             }

//             return DropdownMenuItem<String>(
//               value: isAlreadySelected ? null : s.id, 
//             child: Text(
//               "${s.brand} - ${s.type} [Récharge:${s.full} |  Echange:${s.echangeFull}| Vente:${s.vente} ]", 
//               style: TextStyle(
//                 fontSize: 11, 
//                 fontWeight: FontWeight.w700, 
//                 color: isAlreadySelected ? Colors.grey[300] : const Color(0xFF2D3436)
//               )
//             ),
//             );
//           }).toList(),
//           onChanged: (v) {
//             if (v == null) return; 
//             if (isSource) controller.selectedStockId.value = v; 
//             else controller.selectedDestinationStockId.value = v;
//           },
//         ),
//       ),
//     );
//   });

//   Widget _buildFabMenu() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         _buildMiniFab("TRan", PhosphorIcons.arrowsLeftRight(), AppColors.generalColor, "Usine"),
//         const SizedBox(height: 12),
//         _buildMiniFab("APPro", PhosphorIcons.arrowDown(), AppColors.generalColor, "Livreur"),
//       ],
//     );
//   }

//   Widget _buildMiniFab(String label, IconData icon, Color color, String entity) {
//     return FloatingActionButton(
//       heroTag: label, mini: true,
//       elevation: 4,
//       onPressed: () {
//         controller.prepareForm(initialEntity: entity);
//         _openFormModal(label == "TRan" ? "TRANSFERT" : label == "APPro" ? "APPROVISIONNEMENT" : "REMBOURSEMENT", color);
//       },
//       backgroundColor: color,
//       child: Icon(icon, color: Colors.white, size: 20),
//     );
//   }

//   Widget _field(String l, TextEditingController c, Color col, IconData icon) => Padding(
//     padding: const EdgeInsets.only(bottom: 16),
//     child: TextField(
//       controller: c,
//       keyboardType: TextInputType.number,
//       style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
//       decoration: InputDecoration(
//         labelText: l,
//         labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
        
//         prefixIcon: Container(
//           width: 44,
//           height: 44,
//           margin: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100, 
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Icon(
//             icon,
//             color: AppColors.generalColor, 
//             size: 22, 
//           ),
//         ),

//         filled: true,
//         fillColor: Colors.white, 
//         contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: AppColors.generalColor, width: 1.8),
//         ),
//       ),
//     ),
//   );

//   Widget _buildSubmitButton(String t, Color c) => ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: c, 
//       minimumSize: const Size(double.infinity, 60), 
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
//     ),
//     onPressed: () => controller.createMouvement(type: t, color: c),
//     child: const Text("VALIDER LE MOUVEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 14)),
//   );

//   Widget _label(String t) => Padding(
//     padding: const EdgeInsets.only(bottom: 10, left: 4), 
//     child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blueGrey, letterSpacing: 1.1))
//   );

//   Widget _buildHeader(String t, Color c) => Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween, 
//     children: [
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
//           const SizedBox(height: 2),
//           const Text("Enregistrement du stock", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
//       ]),
//       GestureDetector(
//         onTap: () => Get.back(),
//         child: Container(
//           padding: const EdgeInsets.all(4),
//           decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
//           child: Icon(PhosphorIcons.x(), color: Colors.grey, size: 20),
//         ),
//       ),
//     ],
//   );
// }