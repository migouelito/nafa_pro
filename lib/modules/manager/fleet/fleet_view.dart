import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'fleet_controller.dart';
import '../../appColors/appColors.dart';

class FleetView extends GetView<FleetController> {
  const FleetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SUIVI FLOTTE GPS"),
        backgroundColor:AppColors.generalColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => Row(
            children: [
              _buildStatusPill(Colors.green, "${controller.countOnline}"),
              const SizedBox(width: 5),
              _buildStatusPill(Colors.red, "${controller.countBusy}"),
              const SizedBox(width: 5),
              _buildStatusPill(Colors.orange, "${controller.countMaintenance}", icon: Icons.build), // Pillule Maintenance
              const SizedBox(width: 15),
            ],
          ))
        ],
      ),
      body: Stack(
        children: [
          Obx(() => FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(initialCenter: controller.centerOuaga, initialZoom: 13.0, onTap: (_, __) => controller.clearSelection()),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.nafagaz.pro'),
              MarkerLayer(markers: controller.vehicles.map((v) => Marker(point: v.position, width: 60, height: 60, child: GestureDetector(onTap: () => controller.selectVehicle(v), child: _buildVehicleMarker(v)))).toList()),
            ],
          )),
          Obx(() {
            if (controller.selectedVehicle.value == null) return const SizedBox.shrink();
            return Positioned(bottom: 20, left: 20, right: 20, child: _buildDriverCard(controller.selectedVehicle.value!));
          }),
        ],
      ),
    );
  }

  Widget _buildStatusPill(Color color, String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))),
      child: Row(children: [
        if (icon != null) ...[Icon(icon, size: 10, color: Colors.white), const SizedBox(width: 4)] else ...[CircleAvatar(backgroundColor: color, radius: 4), const SizedBox(width: 6)],
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
      ]),
    );
  }

  Widget _buildVehicleMarker(FleetVehicle v) {
    Color color;
    IconData icon = Icons.electric_rickshaw;
    if (v.status == DriverStatus.online) color = Colors.green;
    else if (v.status == DriverStatus.busy) color = Colors.red;
    else if (v.status == DriverStatus.maintenance) { color = Colors.orange; icon = Icons.build; } // Icône Maintenance
    else color = Colors.grey;

    bool isSelected = controller.selectedVehicle.value?.id == v.id;
    return AnimatedScale(scale: isSelected ? 1.3 : 1.0, duration: const Duration(milliseconds: 300), child: Column(children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)), child: Text(v.driverName.split(' ')[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))), Icon(icon, color: color, size: 35)]));
  }

  Widget _buildDriverCard(FleetVehicle v) {
    Color statusColor;
    String statusText;
    switch (v.status) {
      case DriverStatus.online: statusColor = Colors.green; statusText = "DISPONIBLE"; break;
      case DriverStatus.busy: statusColor = Colors.red; statusText = "EN COURSE"; break;
      case DriverStatus.offline: statusColor = Colors.grey; statusText = "HORS LIGNE"; break;
      case DriverStatus.maintenance: statusColor = Colors.orange; statusText = "AU GARAGE"; break;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            CircleAvatar(backgroundColor: statusColor.withOpacity(0.1), child: Icon(v.status == DriverStatus.maintenance ? Icons.build : Icons.person, color: statusColor)),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(v.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("${v.type} • ${v.plateNumber}", style: const TextStyle(color: Colors.grey, fontSize: 12))])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(5)), child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              const SizedBox(height: 5),
              // Indicateur Essence
              Row(children: [Icon(Icons.local_gas_station, size: 14, color: v.fuelLevel < 30 ? Colors.red : Colors.blue), const SizedBox(width: 4), Text("${v.fuelLevel}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
            ])
          ]),
          const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildBtn(Icons.phone, "Appeler", Colors.black, () {}),
            // Bouton Garage Toggle
            _buildBtn(Icons.build, v.status == DriverStatus.maintenance ? "Sortir Garage" : "Mettre Garage", Colors.orange, () => controller.toggleMaintenance(v)),
          ])
        ],
      ),
    );
  }
  
  Widget _buildBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Column(children: [Icon(icon, color: color), Text(label, style: const TextStyle(fontSize: 10))]));
  }
}
