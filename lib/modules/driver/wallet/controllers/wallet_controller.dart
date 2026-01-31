import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Transaction {
  final String title;
  final int amount;
  final DateTime date;
  Transaction(this.title, this.amount, this.date);
}

class WalletController extends GetxController {
  var balance = 12500.obs; // Solde Gains
  var transactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    transactions.value = [
      Transaction("Commission Course #885", 150, DateTime.now().subtract(const Duration(minutes: 10))),
      Transaction("Commission Course #880", 150, DateTime.now().subtract(const Duration(hours: 2))),
      Transaction("Bonus Semaine", 2000, DateTime.now().subtract(const Duration(days: 1))),
      Transaction("Retrait Espèces", -5000, DateTime.now().subtract(const Duration(days: 2))),
    ];
  }

  void requestWithdrawal() {
    final amountCtrl = TextEditingController();
    Get.defaultDialog(
      title: "DEMANDER RETRAIT",
      content: Column(children: [
        const Text("Montant à récupérer au dépôt :"),
        TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(suffixText: "FCFA")),
      ]),
      textConfirm: "ENVOYER DEMANDE",
      confirmTextColor: Colors.white,
      buttonColor: Colors.black,
      onConfirm: () {
        int amount = int.tryParse(amountCtrl.text) ?? 0;
        if (amount > 0 && amount <= balance.value) {
          Get.back();
          Get.snackbar("Envoyé", "Le Manager a reçu votre demande.", backgroundColor: Colors.green, colorText: Colors.white);
          // Côté Manager, ça apparaitrait dans l'onglet "GUICHET"
        } else {
          Get.snackbar("Erreur", "Solde insuffisant.", backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    );
  }
}
