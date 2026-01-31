import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MES GAINS"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            color: Colors.black,
            child: Column(
              children: [
                const Text("SOLDE DISPONIBLE", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                Obx(() => Text("${controller.balance} FCFA", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.requestWithdrawal,
                  icon: const Icon(Icons.download),
                  label: const Text("RETIRER (DÉPÔT)"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                )
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                final t = controller.transactions[index];
                bool isPositive = t.amount > 0;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: isPositive ? Colors.green.shade50 : Colors.red.shade50, child: Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward, color: isPositive ? Colors.green : Colors.red)),
                    title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd/MM HH:mm').format(t.date)),
                    trailing: Text("${isPositive ? '+' : ''}${t.amount} F", style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red)),
                  ),
                );
              },
            )),
          )
        ],
      ),
    );
  }
}
