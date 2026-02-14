import 'package:get/get.dart';
import '../../../loading/loading.dart';
import '../../../services/apiServices.dart';
import 'package:flutter/widgets.dart';

class OrderListController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var futureCommandes = Future<List<dynamic>?>.value([]).obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    Future.microtask(() async {
      try {
        LoadingModal.show();
        futureCommandes.value = _apiService.fetchCommandes();
      } finally {
        LoadingModal.hide();
      }
    });
  }

  Future<void> handleRefresh() async {
    await fetchOrders();
  }
}