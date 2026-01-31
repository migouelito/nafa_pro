import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/delivery_validation_controller.dart';

class DeliveryValidationView extends GetView<DeliveryValidationController> {
  const DeliveryValidationView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DeliveryValidationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("FIN D'INTERVENTION"),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO MISSION
            if (controller.mission != null)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.grey),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.mission.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(controller.mission.details, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Chip(label: Text("PAYÉ", style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.green)
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // 1. BOUTEILLES
            const Text("1. GESTION DES BOUTEILLES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade200),
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Row(children: [
                    const Icon(Icons.sync_alt, color: Colors.orange), 
                    const SizedBox(width: 10), 
                    Expanded(child: Text("Attendu : ${controller.expectedEmptyBottle}", style: const TextStyle(fontWeight: FontWeight.bold)))
                  ]),
                  const Divider(),
                  Obx(() => CheckboxListTile(
                    value: controller.hasCollectedEmptyBottle.value,
                    onChanged: controller.expectedEmptyBottle.contains("Aucune") ? null : controller.toggleEmptyBottleCollection,
                    activeColor: Colors.orange,
                    contentPadding: EdgeInsets.zero,
                    title: const Text("J'ai bien récupéré la consigne vide", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ))
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("2. ACTIONS RÉALISÉES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                Text("(Choix multiples)", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() => Column(
              children: controller.interventionTypes.map((action) {
                bool isSelected = controller.selectedActions.contains(action);
                return GestureDetector(
                  onTap: () => controller.toggleAction(action),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(color: isSelected ? Colors.blue : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: isSelected ? Colors.blue : Colors.grey)),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(child: Text(action, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.blue.shade900 : Colors.black))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),

            const SizedBox(height: 30),

            // 3. OBSERVATIONS (NOUVEAU)
            const Text("3. OBSERVATIONS (OPTIONNEL)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: controller.observationController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Ex: Client absent au début, Portail difficile d'accès, Plainte prix...",
                fillColor: Colors.grey.shade50,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),

            const SizedBox(height: 40),

            // 4. SCAN
            const Text("4. PREUVE DE LIVRAISON", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: controller.startQRScan,
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: const Text("SCANNER QR CLIENT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
