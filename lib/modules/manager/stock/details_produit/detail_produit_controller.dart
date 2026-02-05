import 'package:get/get.dart';
import '../../../services/apiServices.dart';

class ProduitDetailController extends GetxController {
  final ApiService apiService = ApiService();

  final item = {}.obs; 
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic argumentId = Get.arguments;
    
    if (argumentId != null && argumentId is String) {
      fetchDetail(argumentId);
    } else {
      print("Erreur : ID invalide ou absent");
    }
  }

  Future<void> fetchDetail(String productId) async {
    try {
      isLoading(true);
      final data = await apiService.getProduitDetail(productId);
      print("=============data$data");
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
    print("Action : Signaler avarie sur ${item['brand']} - Pleine: $isFull");
  }
}