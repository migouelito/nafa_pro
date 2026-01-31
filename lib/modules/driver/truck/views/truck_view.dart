import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/truck_controller.dart';

class TruckView extends GetView<TruckController> {
  const TruckView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MON TRICYCLE"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Card(
              color: Colors.blueAccent,
              child: ListTile(
                leading: Icon(Icons.info, color: Colors.white),
                title: Text("Inventaire Embarqué", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("Chargé par le Manager ce matin.", style: TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, mainAxisSpacing: 10, crossAxisSpacing: 10),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          InkWell(onTap: () => controller.reportIssue(item), child: const Icon(Icons.report_problem, size: 18, color: Colors.red))
                        ]),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(children: [Text("${item.full}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)), const Text("Pleines", style: TextStyle(fontSize: 10))]),
                            Column(children: [Text("${item.empty}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)), const Text("Vides", style: TextStyle(fontSize: 10))]),
                          ],
                        )
                      ],
                    ),
                  );
                },
              )),
            )
          ],
        ),
      ),
    );
  }
}
