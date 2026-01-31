import 'package:get/get.dart';
import 'mouvement_detail_controller.dart';

class MouvementDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MouvementDetailController>(() => MouvementDetailController());
  }
}