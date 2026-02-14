import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/apiServices.dart';
import 'package:flutter/material.dart';

class DetailOrderController extends GetxController {
  final ApiService apiService = ApiService();
  
  var order = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // On récupère l'argument (soit la Map complète, soit juste l'ID)
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        order.value = Get.arguments;
      } else if (Get.arguments is String) {
        order['id'] = Get.arguments;
      }
    }
    fetchCommandeDetail();
  }

  Future<void> fetchCommandeDetail() async {
    if (order['id'] == null) return;
    try {
      isLoading.value = true;
      final response = await apiService.fetchCommandeDetail(order['id']);
      if (response != null) {
        order.value = response;
      }
    } catch (e) {
      debugPrint("Erreur chargement détails : $e");
    } finally {
      isLoading.value = false;
    }
  }
 
  String get formattedDate {
    if (order['created'] == null) return "Date inconnue";
    try {
      DateTime date = DateTime.parse(order['created'].toString());
      return DateFormat('dd MMM yyyy • HH:mm', 'fr_FR').format(date);
    } catch (e) {
      return order['created'].toString();
    }
  }

  String get shortId => order['id'] != null 
      ? order['id'].toString().substring(0, 8).toUpperCase() 
      : "ID Inconnu";

  List get items => order['items'] ?? [];

  bool get canModify => order['etat'] == "EN_ATTENTE";
}