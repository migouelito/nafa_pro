import 'package:get/get.dart';
import '../../../../services/apiServices.dart';

class DetailMagasinStockController extends GetxController {
  final ApiService apiService = ApiService();

  final item = <String, dynamic>{}.obs; 
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic argumentId = Get.arguments;
    
    if (argumentId != null) {
      fetchDetail(argumentId.toString());
    }
  }

  Future<void> fetchDetail(String productId) async {
    try {
      isLoading(true);
      final data = await apiService.getStockDetail(productId);
      if (data != null) {
        item.assignAll(data);
      }
    } catch (e) {
      print("Erreur lors du fetch : $e");
    } finally {
      isLoading(false);
    }
  }

  void signalerAvarie(bool isFull) {
    // Logique pour signaler l'avarie via l'API
    Get.snackbar("Avarie", "Signalement enregistré pour bouteille ${isFull ? 'Pleine' : 'Vide'}");
  }
}