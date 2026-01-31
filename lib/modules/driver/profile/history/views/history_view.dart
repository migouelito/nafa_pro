import 'package:flutter/material.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HISTORIQUE"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text("12kg", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
              title: Text("Livraison #${2045 + index}"),
              subtitle: Text("21 Janv. • Patte d'oie • Payé"),
              trailing: const Text("+100 F", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
