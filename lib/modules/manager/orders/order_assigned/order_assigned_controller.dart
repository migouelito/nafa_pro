import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
import '../../../services/apiServices.dart';
import 'package:flutter/material.dart';
import '../../../alerte/alerte.dart'; 
import '../../../loading/loading.dart'; 

class OrderAssignedController extends GetxController {
  final ApiService apiService = ApiService();
  
  var sessions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  var selectedSessionId = "".obs;
  String currentOrderId = "";

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
  }

  void _handleArguments() {
    final dynamic arguments = Get.arguments;
    if (arguments != null) {
      if (arguments is Map && arguments.containsKey('orderId')) {
        currentOrderId = arguments['orderId']?.toString() ?? "";
      } else {
        currentOrderId = arguments?.toString() ?? "";
      }
    }

    if (currentOrderId.isNotEmpty) {
      fetchSessions(currentOrderId);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchSessions(String id) async {
    try {
      isLoading.value = true;
      selectedSessionId.value = ""; 

      final response = await apiService.fetchDeliver(id); 
      
      if (response != null) {
        sessions.assignAll([response]);
      } else {
        sessions.clear();
      }
    } catch (e) {
      debugPrint("Erreur chargement sessions : $e");
      sessions.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelection(String sessionId) {
    if (selectedSessionId.value == sessionId) {
      selectedSessionId.value = ""; 
    } else {
      selectedSessionId.value = sessionId; 
    }
  }

  Future<bool> dispatchSession({
    required String commandeId,
    required String sessionId,
    required List<String> itemIds,
  }) async {
    try {
      final bool success = await apiService.dispatchSession(
        commandeId: commandeId,
        sessionId: sessionId,
        itemIds: itemIds,
      );
      return success;
    } catch (e) {
      debugPrint("Erreur dans dispatchSession: $e");
      return false;
    }
  }

  // --- ACTION FINALE APPELÉE PAR LE BOUTON ---
  Future<void> assignOrder() async {
    if (selectedSessionId.isEmpty) return;

    try {
      LoadingModal.show(); 

      // 1. Trouver la session sélectionnée
      final selectedSession = sessions.firstWhere(
        (s) => s['id'].toString() == selectedSessionId.value
      );
      
      // 2. Récupérer les items (produits) de cette session spécifique
      final List itemsRaw = selectedSession['items'] ?? [];
      
      // 3. Extraire les IDs des produits (UUID)
      final List<String> itemIds = itemsRaw
          .map((item) => item['id'].toString())
          .where((id) => id.isNotEmpty && id != "null")
          .toList();

      final bool success = await dispatchSession(
        commandeId: currentOrderId,
        sessionId: selectedSessionId.value,
        itemIds: itemIds,
      );

      LoadingModal.hide();

      if (success) {
        Get.back(); 
        Alerte.show(
          title: "Succès",
          message: "La commande a été assignée avec succès",
          color: AppColors.generalColor,
          imagePath: "assets/images/success.png"
        );
      } else {
        Alerte.show(
          title: "Erreur",
          message: "L'assignation a échoué. Vérifiez la session du livreur.",
          color: Colors.red,
          imagePath: "assets/images/error.png"
        );
      }
    } catch (e) {
      LoadingModal.hide();
      debugPrint("Crash assignOrder: $e");
      Alerte.show(
        title: "Erreur technique", 
        message: "Une erreur est survenue lors de l'assignation", 
        color: Colors.red
      );
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy • HH:mm', 'fr_FR').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}