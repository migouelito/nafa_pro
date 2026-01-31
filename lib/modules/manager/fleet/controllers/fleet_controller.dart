import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

// ÉTAT DU CHAUFFEUR ENRICHI
enum DriverStatus { online, busy, offline, maintenance }

class FleetVehicle {
  final String id;
  final String driverName;
  final String plateNumber;
  final String type;
  final LatLng position;
  DriverStatus status; // Mutable pour le changement d'état
  final int batteryLevel;
  final int fuelLevel; // NOUVEAU : Niveau essence
  final String currentZone;

  FleetVehicle({
    required this.id,
    required this.driverName,
    required this.plateNumber,
    required this.type,
    required this.position,
    required this.status,
    required this.batteryLevel,
    this.fuelLevel = 100,
    required this.currentZone,
  });
}

class FleetController extends GetxController {
  final mapController = MapController();
  final centerOuaga = const LatLng(12.3714, -1.5197);
  var vehicles = <FleetVehicle>[].obs;
  var selectedVehicle = Rxn<FleetVehicle>();

  @override
  void onInit() {
    super.onInit();
    _loadFleetData();
  }

  void _loadFleetData() {
    vehicles.value = [
      FleetVehicle(id: "LIV01", driverName: "Amadou O.", plateNumber: "11-GG-4488", type: "TVS King", position: const LatLng(12.3500, -1.5100), status: DriverStatus.busy, batteryLevel: 85, fuelLevel: 40, currentZone: "ZONE SUD"),
      FleetVehicle(id: "LIV02", driverName: "Seydou K.", plateNumber: "11-JJ-2020", type: "Bajaj RE", position: const LatLng(12.3650, -1.5500), status: DriverStatus.online, batteryLevel: 42, fuelLevel: 80, currentZone: "ZONE OUEST"),
      FleetVehicle(id: "LIV03", driverName: "Moussa T.", plateNumber: "11-AA-1234", type: "TVS King", position: const LatLng(12.3600, -1.4800), status: DriverStatus.online, batteryLevel: 90, fuelLevel: 20, currentZone: "ZONE EST"),
      FleetVehicle(id: "LIV04", driverName: "Jean B.", plateNumber: "11-XX-9999", type: "Moto X1", position: const LatLng(12.3714, -1.5197), status: DriverStatus.maintenance, batteryLevel: 0, fuelLevel: 0, currentZone: "GARAGE"),
    ];
  }

  void selectVehicle(FleetVehicle v) {
    selectedVehicle.value = v;
    mapController.move(v.position, 15.0);
  }

  void clearSelection() {
    selectedVehicle.value = null;
    mapController.move(centerOuaga, 13.0);
  }

  // --- NOUVEAU : GESTION MAINTENANCE ---
  void toggleMaintenance(FleetVehicle v) {
    if (v.status == DriverStatus.maintenance) {
      v.status = DriverStatus.offline; // Retourne en mode normal (hors ligne)
      Get.snackbar("Maintenance Terminée", "${v.plateNumber} est de retour dans le parc.", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      v.status = DriverStatus.maintenance; // Part au garage
      Get.snackbar("Au Garage", "${v.plateNumber} marqué comme indisponible.", backgroundColor: Colors.orange, colorText: Colors.white);
    }
    vehicles.refresh(); // Rafraîchir l'UI
    selectedVehicle.refresh();
  }

  int get countOnline => vehicles.where((v) => v.status == DriverStatus.online).length;
  int get countBusy => vehicles.where((v) => v.status == DriverStatus.busy).length;
  int get countMaintenance => vehicles.where((v) => v.status == DriverStatus.maintenance).length;
}
