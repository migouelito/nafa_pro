import 'package:get/get.dart';
import '../controllers/stock_controller.dart';

class SessionController extends GetxController {
  final StockController stockController = Get.find<StockController>();
  var isLoading = false.obs;
  var counters = <String, int>{}.obs;

  // --- LOGIQUE DE FILTRE PAR DROPDOWN ---
  var selectedLivreur = "TOUS LES LIVREURS".obs;

  List<Map<String, dynamic>> get filteredSessions {
    if (selectedLivreur.value == "TOUS LES LIVREURS") {
      return stockController.sessionsList;
    } else {
      return stockController.sessionsList.where((session) {
        return session['agent_livraison_name'] == selectedLivreur.value;
      }).toList();
    }
  }

  void updateSelectedLivreur(String name) => selectedLivreur.value = name;
  // --------------------------------------

  @override
  void onReady() {
    super.onReady();
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      isLoading(true);
      await stockController.getSessions();
    } catch (e) {
      print("Erreur chargement sessions: $e");
    } finally {
      isLoading(false);
    }
  }

  void prepareNewSession() {
    counters.clear();
    for (var item in stockController.chargementStock) {
      String key = "${item.brand}_${item.type}";
      counters[key] = 0;
    }
  }

  void increment(String key) => counters[key] = (counters[key] ?? 0) + 1;
  void decrement(String key) {
    if ((counters[key] ?? 0) > 0) counters[key] = counters[key]! - 1;
  }

  Future<void> submitSession() async {
    List<Map<String, dynamic>> itemsToShip = [];
    counters.forEach((key, quantity) {
      if (quantity > 0) {
        var parts = key.split('_');
        try {
          var itemObj = stockController.chargementStock.firstWhere(
            (i) => i.brand == parts[0] && i.type == parts[1]
          );
          itemsToShip.add({"stock": itemObj.id, "quantite_ouverture": quantity});
        } catch (e) { print("Erreur item: $e"); }
      }
    });

    if (itemsToShip.isNotEmpty) {
      if (Get.isBottomSheetOpen ?? false) Get.back();
      await stockController.createSession(items: itemsToShip);
      await loadSessions();
    }
  }
}