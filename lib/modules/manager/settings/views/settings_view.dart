import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("PRIX & COMMISSIONS"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final p = controller.products[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // EN-TÊTE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: Colors.grey.shade200, child: Text(p.brand[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${p.brand} ${p.type}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text("Gaz Butane", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => controller.openEditModal(p),
                      )
                    ],
                  ),
                  const Divider(height: 25),
                  
                  // DÉTAILS PRIX
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _priceColumn("ACHAT", p.buyPrice.value, Colors.grey),
                      const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                      _priceColumn("VENTE", p.sellPrice.value, Colors.black),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // RÉPARTITION (COMMISSION vs MARGE)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _detailRow(Icons.motorcycle, "Com. Livreur", p.driverCommission.value, Colors.orange),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        _detailRow(Icons.store, "Marge Dépôt", p.netMargin, Colors.green),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addProduct,
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _priceColumn(String label, int price, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text("$price F", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, int price, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text("$price F", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        )
      ],
    );
  }
}
