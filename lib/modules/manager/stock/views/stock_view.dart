import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import '../../../appColors/appColors.dart';
import '../mouvement/mouvement_tab.dart';
import '../session/sessions_tab.dart';
import '../mouvement/mouvement_controller.dart';
import '../session/session_controler.dart';
import '../magasin_stock/magasin_stock_tab.dart';
import '../magasin_stock/magasin_stock_controller.dart';

class StockView extends GetView<StockController> {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.getProduits());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: const Text("GESTION STOCK", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)),
          backgroundColor: AppColors.generalColor,
          foregroundColor: Colors.white,
          bottom:  TabBar(
            indicatorColor: AppColors.Orange,
            unselectedLabelColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            tabs: [
              Tab(text: "STOK"), 
              // Tab(text: "PRODUIT"), 
              Tab(text: "MOUVEMENT"), 
              Tab(text: "SESSIONS")
            ],
          ),
        ),
        body: TabBarView(
        children: [
        GetBuilder<MagasinStockController>(
          init: MagasinStockController(),
          builder: (_) => const MagasinStockTab(),
        ),
        // GetBuilder<StockController>(
        //   init: StockController(),
        //   builder: (_) => const ProduitsTab(),
        // ),
        GetBuilder<MouvementController>(
          init: MouvementController(),
          builder: (_) => const MouvementTab(),
        ),
        GetBuilder<SessionController>(
          init: SessionController(),
          builder: (_) => const SessionsTab(),
        ),
      ],

        ),
      ),
    );
  }
}