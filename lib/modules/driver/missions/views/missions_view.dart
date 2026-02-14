import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/missions_controller.dart';
import '../../../appColors/appColors.dart';

class MissionsView extends GetView<MissionsController> {
  const MissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MES COURSES"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: controller.missions.length,
        itemBuilder: (context, index) {
          final m = controller.missions[index];
          if (m.status == 'DELIVERED') return const SizedBox.shrink(); 

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(5)),
                        child: Text(m.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 10)),
                      ),
                      Text("+${m.commission} F", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(m.client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(m.address, style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 20),
                  Row(children: [const Icon(Icons.propane_tank, size: 16), const SizedBox(width: 10), Text(m.details, style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.openMap(m),
                          icon: const Icon(Icons.map),
                          label: const Text("GPS"),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.completeMission(m),
                          icon: const Icon(Icons.check),
                          label: const Text("LIVRÉ"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      )),
    );
  }
}
