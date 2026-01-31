import 'package:flutter/material.dart';

class PerformanceView extends StatelessWidget {
  const PerformanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MES PERFORMANCES"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBigScore("4.8", "Note Moyenne", Icons.star, Colors.amber),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSmallScore("98%", "Acceptation", Colors.blue)),
                const SizedBox(width: 15),
                Expanded(child: _buildSmallScore("12 min", "Temps Moyen", Colors.purple)),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Progression du mois", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            Container(height: 200, color: Colors.grey.shade100, child: const Center(child: Text("Graphique ici", style: TextStyle(color: Colors.grey)))),
          ],
        ),
      ),
    );
  }

  Widget _buildBigScore(String score, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]),
      child: Column(children: [
        Icon(icon, size: 50, color: color),
        Text(score, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ]),
    );
  }

  Widget _buildSmallScore(String score, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        Text(score, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }
}
