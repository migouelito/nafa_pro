import 'package:get/get.dart';
import 'detail_session_controller.dart';

class DetailSessionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailSessionController>(() => DetailSessionController());
  }
}