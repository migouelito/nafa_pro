import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/clients_controller.dart';
import 'package:intl/intl.dart'; // Assurez-vous d'avoir intl dans pubspec

class ClientsView extends GetView<ClientsController> {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("CLIENTS & PARTENAIRES"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // BARRE DE RECHERCHE
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF1A237E),
            child: TextField(
              controller: controller.searchCtrl,
              onChanged: controller.filterClients,
              decoration: InputDecoration(
                hintText: "Rechercher (Nom, Tel)...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // LISTE
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: controller.filteredClients.length,
              itemBuilder: (context, index) {
                final client = controller.filteredClients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => controller.showHistory(client),
                    leading: CircleAvatar(
                      backgroundColor: _getTypeColor(client.type).withOpacity(0.1),
                      child: Text(client.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: _getTypeColor(client.type))),
                    ),
                    title: Row(
                      children: [
                        Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (client.isVIP) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.star, color: Colors.amber, size: 16)
                        ]
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${client.type} • ${client.location}"),
                        if (client.isChurning)
                          Text("⚠️ Inactif depuis ${_daysSince(client.lastOrderDate)} jours", style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () => controller.callClient(client),
                    ),
                  ),
                );
              },
            )),
          )
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case "Maquis": return Colors.purple;
      case "Restaurant": return Colors.orange;
      case "Revendeur": return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _daysSince(DateTime date) {
    return DateTime.now().difference(date).inDays.toString();
  }
}
