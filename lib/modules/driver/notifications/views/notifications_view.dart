import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Données simulées
    final notifs = [
      {"title": "Nouvelle attribution", "body": "Le gestionnaire vous a ajouté 3 courses.", "time": "Il y a 2 min", "type": "job"},
      {"title": "Bonus Validé", "body": "Votre retrait de 5000F a été approuvé.", "time": "Hier, 18:30", "type": "money"},
      {"title": "Info Trafic", "body": "Embouteillage signalé vers le rond-point des Nations Unies.", "time": "Hier, 14:00", "type": "info"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("NOTIFICATIONS"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: notifs.length,
        separatorBuilder: (c, i) => const Divider(),
        itemBuilder: (context, index) {
          final n = notifs[index];
          IconData icon;
          Color color;
          
          if (n['type'] == 'job') { icon = Icons.local_shipping; color = Colors.blue; }
          else if (n['type'] == 'money') { icon = Icons.savings; color = Colors.green; }
          else { icon = Icons.info; color = Colors.grey; }

          return ListTile(
            leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n['body']!),
              const SizedBox(height: 5),
              Text(n['time']!, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ]),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
