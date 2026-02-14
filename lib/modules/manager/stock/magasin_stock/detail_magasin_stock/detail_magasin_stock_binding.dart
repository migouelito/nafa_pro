import 'package:get/get.dart';
import 'detail_magasin_stock_controller.dart';

class DetailMagasinStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailMagasinStockController>(() => DetailMagasinStockController());
  }
}