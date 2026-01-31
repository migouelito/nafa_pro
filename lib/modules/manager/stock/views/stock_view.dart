import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import '../../../appColors/appColors.dart';
import 'inventory_tab.dart';
import 'mouvement_tab.dart';
import 'sessions_tab.dart';

import '../views/mouvement_controller.dart';
import '../views/session_controler.dart';


class StockView extends GetView<StockController> {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    // On rafraîchit les produits au démarrage via le controller principal
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.getProduits());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: const Text("GESTION STOCK", 
            style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w800)),
          backgroundColor: AppColors.generalColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            unselectedLabelColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            tabs: [
              Tab(text: "PRODUIT"), 
              Tab(text: "MOUVEMENT"), 
              Tab(text: "SESSIONS")
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const InventoryTab(),
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