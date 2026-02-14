import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dispatch_controller.dart';
import '../../appColors/appColors.dart';
import '../orders/order_list/order_list_view.dart';
import '../orders/order_list/order_list_controller.dart';
import '../orders/order_in_line/order_in_line_view.dart';
import '../orders/order_in_line/order_in_line_controller.dart';
import '../orders/order_delive/order_delive_view.dart';
import '../orders/order_delive/order_delive_controller.dart';

class DispatchView extends GetView<DispatchController> {
  const DispatchView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrderListController());
    Get.put(OrderInLineController());
    Get.put(OrderDeliveController());

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "DISPATCH", 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)
          ),
          backgroundColor: AppColors.generalColor,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.Orange,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorWeight: 4,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "COMMANDES"),
              Tab(text: "EN COURS"),
              Tab(text: "LIVRÉ"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderListView(),
            OrderInLineView(),
            OrderDeliveView(),
          ],
        ),
      ),
    );
  }
}