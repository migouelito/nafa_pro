import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// --- MODÈLES ---

// 1. ANALYSE VENTES (Par Marque/Type)
class SalesStat {
  final String brand; 
  final String type;
  final int quantitySold;
  final int unitMargin;
  int get totalRevenue => quantitySold * (unitMargin + 4000); // Prix vente approx
  int get totalMargin => quantitySold * unitMargin;
  SalesStat(this.brand, this.type, this.quantitySold, this.unitMargin);
}

// 2. PERFORMANCE LIVREUR (Ventes réelles)
class DriverPerformance {
  final String name;
  final int bottlesSold;
  final int revenueGenerated;
  DriverPerformance(this.name, this.bottlesSold, this.revenueGenerated);
}

// 3. GUICHET LIVREUR (Pour le paiement des gains)
class DriverWallet {
  final String name;
  var availableBalance; // Ce que le dépôt doit payer au livreur
  DriverWallet(this.name, int balance) { availableBalance = balance.obs; }
}
class WithdrawalRequest {
  final String driverName;
  final int amount;
  final DateTime time;
  WithdrawalRequest(this.driverName, this.amount, this.time);
}

// 4. DETTES & DÉPENSES
class SupplierInvoice {
  final String supplier;
  final int amount;
  final DateTime dueDate;
  var isPaid = false.obs;
  SupplierInvoice(this.supplier, this.amount, this.dueDate, {bool paid = false}) { isPaid.value = paid; }
}
class Expense {
  final String category;
  final String description;
  final int amount;
  final DateTime date;
  Expense(this.category, this.description, this.amount) : date = DateTime.now();
}

class FinanceController extends GetxController {
  // === TRÉSORERIE ===
  var virtualBalance = 2500000.obs; // Ligdicash/OM (Reçoit ventes)
  var physicalCash = 150000.obs;    // Coffre (Paie dépenses & retraits)

  // === ANALYTIQUE ===
  var productStats = <SalesStat>[].obs;
  var driverStats = <DriverPerformance>[].obs;
  
  // === GUICHET (PAIE) ===
  var driverWallets = <DriverWallet>[].obs;
  var pendingWithdrawals = <WithdrawalRequest>[].obs;

  // === CHARGES ===
  var supplierInvoices = <SupplierInvoice>[].obs;
  var expenses = <Expense>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
  }

  void _loadAllData() {
    // 1. Stats Ventes
    productStats.value = [
      SalesStat("Sodigaz", "B12", 120, 500),
      SalesStat("Total", "B12", 85, 500),
      SalesStat("Oryx", "B6", 40, 250),
    ];

    // 2. Perf Livreurs
    driverStats.value = [
      DriverPerformance("Amadou O.", 95, 570000),
      DriverPerformance("Seydou K.", 60, 360000),
      DriverPerformance("Moussa T.", 90, 540000),
    ];

    // 3. Portefeuilles (Gains à payer)
    driverWallets.value = [
      DriverWallet("Amadou O.", 12500),
      DriverWallet("Seydou K.", 5000),
      DriverWallet("Moussa T.", 1500),
    ];
    // Une demande de retrait en attente
    pendingWithdrawals.value = [
      WithdrawalRequest("Seydou K.", 2000, DateTime.now().subtract(const Duration(minutes: 30))),
    ];

    // 4. Dettes Fournisseurs
    supplierInvoices.value = [
      SupplierInvoice("Usine SODIGAZ", 1500000, DateTime.now().add(const Duration(days: 5))), 
      SupplierInvoice("SONABHY", 3000000, DateTime.now().subtract(const Duration(days: 2))), // En retard
    ];

    // 5. Dépenses
    expenses.value = [
      Expense("Carburant", "Tricycle 01", 5000),
      Expense("Maintenance", "Vidange Bajaj", 12000),
    ];
  }

  // === CALCULS BÉNÉFICE (P&L) ===
  int get totalRevenue => productStats.fold(0, (sum, item) => sum + item.totalRevenue);
  int get totalGrossMargin => productStats.fold(0, (sum, item) => sum + item.totalMargin);
  int get totalExpenses => expenses.fold(0, (sum, item) => sum + item.amount);
  int get netProfit => totalGrossMargin - totalExpenses;

  // === ACTIONS ===

  // 1. Payer un Livreur (Retrait)
  void processWithdrawal(WithdrawalRequest req) {
    if (physicalCash.value < req.amount) {
      Get.snackbar("Erreur", "Pas assez de cash dans le coffre.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    physicalCash.value -= req.amount;
    var wallet = driverWallets.firstWhere((d) => d.name == req.driverName);
    wallet.availableBalance.value -= req.amount;
    pendingWithdrawals.remove(req);
    Get.snackbar("Payé", "Retrait de ${formatCurrency(req.amount)} F effectué.", backgroundColor: Colors.green, colorText: Colors.white);
  }

  // 2. Payer un Fournisseur
  void paySupplier(SupplierInvoice inv) {
    // On suppose qu'on paie les gros montants via le Solde Virtuel (Virement)
    if (virtualBalance.value < inv.amount) {
      Get.snackbar("Erreur", "Solde Ligdicash insuffisant.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    virtualBalance.value -= inv.amount;
    inv.isPaid.value = true;
    Get.snackbar("Rêglé", "Facture ${inv.supplier} payée.", backgroundColor: Colors.green, colorText: Colors.white);
  }

  // 3. Ajouter une Dépense
  void addExpense() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String cat = "Carburant";
    Get.defaultDialog(
      title: "NOUVELLE DÉPENSE",
      content: Column(children: [
        DropdownButtonFormField<String>(value: cat, items: ["Carburant", "Maintenance", "Salaire", "Divers"].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(), onChanged:(v)=>cat=v!),
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
        TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Montant")),
      ]),
      textConfirm: "PAYER (COFFRE)", confirmTextColor: Colors.white, buttonColor: Colors.red,
      onConfirm: () {
        int amount = int.tryParse(amountCtrl.text) ?? 0;
        if (amount > 0 && amount <= physicalCash.value) {
          physicalCash.value -= amount;
          expenses.insert(0, Expense(cat, descCtrl.text, amount));
          Get.back();
          Get.snackbar("Enregistré", "Dépense ajoutée.", backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          Get.snackbar("Erreur", "Fonds insuffisants au coffre.", backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    );
  }

  String formatCurrency(int amount) => amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
}
