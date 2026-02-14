import 'package:get/get.dart';
import 'detail_produit_controller.dart';

class ProduitDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProduitDetailController());
  }
}