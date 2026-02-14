import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nafa_pro/modules/appColors/appColors.dart';
import 'package:nafa_pro/modules/driver/dashboard/controllers/driver_controller.dart';
import '../../../appColors/appColors.dart';

class DriverView extends GetView<DriverController> {
  const DriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isOnline.value) return _buildOfflineLockScreen();

      return Scaffold(
        appBar: AppBar(
          title: const Text("FEUILLE DE ROUTE"),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: controller.fetchAssignedMissions),
            IconButton(icon: const Icon(Icons.auto_graph), onPressed: () {}),
          ],
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(initialCenter: controller.currentPosition.value, initialZoom: 13.0),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.nafagaz.pro'),
                MarkerLayer(markers: [
                  Marker(point: controller.currentPosition.value, width: 50, height: 50, child: const Icon(Icons.electric_rickshaw, color: Colors.black, size: 40)),
                  if (controller.activeMission.value == null) ...controller.missions.map((mission) => Marker(point: mission.location, width: 60, height: 60, child: GestureDetector(onTap: () => controller.startMission(mission), child: Column(children: [Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)), child: Text(mission.clientName.split(' ')[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))), const Icon(Icons.location_on, color: Colors.red, size: 35)])))),
                  if (controller.activeMission.value != null) Marker(point: controller.activeMission.value!.location, width: 50, height: 50, child: const Icon(Icons.flag, color: Colors.red, size: 45)),
                ]),
                if (controller.activeMission.value != null) PolylineLayer(polylines: [Polyline(points: [controller.currentPosition.value, controller.activeMission.value!.location], strokeWidth: 4.0, color: Colors.blue)]),
              ],
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: controller.activeMission.value != null ? _buildNavigationPanel(controller.activeMission.value!) : _buildMissionsList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOfflineLockScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.lock_outline, size: 60, color: Colors.grey)),
            const SizedBox(height: 30),
            const Text("ACCÈS RESTREINT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Passez en ligne pour voir vos missions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => controller.toggleStatus(true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.generalColor, foregroundColor: Colors.white), child: const Text("PASSER EN LIGNE")))
          ]),
        ),
      ),
    );
  }

  Widget _buildMissionsList() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(15), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Commandes à livrer (${controller.missions.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Icon(Icons.keyboard_arrow_up, color: Colors.grey)])),
          const Divider(height: 1),
          Expanded(child: controller.missions.isEmpty ? const Center(child: Text("Aucune course.")) : ListView.builder(itemCount: controller.missions.length, itemBuilder: (context, index) { final mission = controller.missions[index]; return ListTile(leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text("${index + 1}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))), title: Text(mission.clientName, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${mission.details}\n${mission.address}"), isThreeLine: true, trailing: ElevatedButton(onPressed: () => controller.startMission(mission), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A86B), foregroundColor: Colors.white, shape: const CircleBorder(), padding: const EdgeInsets.all(10)), child: const Icon(Icons.navigation))); })),
        ],
      ),
    );
  }

  Widget _buildNavigationPanel(DeliveryMission mission) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("EN COURS DE LIVRAISON", style: TextStyle(color:AppColors.Orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(mission.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // BOUTON FERMER NAV
              IconButton(onPressed: controller.cancelNavigation, icon: const Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          
          // BOUTONS D'ACTION RAPIDE (NOUVEAU)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.callClient(mission.phoneNumber),
                  icon: const Icon(Icons.call, color: Colors.black),
                  label: const Text("APPELER", style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.reportIssue,
                  icon: const Icon(Icons.warning_amber, color: AppColors.Orange),
                  label: const Text("SIGNALER", style: TextStyle(color: AppColors.Orange)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color:AppColors.Orange)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [const Icon(Icons.location_on, color: Colors.blue), const SizedBox(width: 10), Expanded(child: Text(mission.address, style: const TextStyle(fontWeight: FontWeight.w500)))]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.arriveAtClient,
              icon: const Icon(Icons.flag),
              label: const Text("J'Y SUIS - VALIDER"),
              style: ElevatedButton.styleFrom(backgroundColor:  AppColors.generalColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
