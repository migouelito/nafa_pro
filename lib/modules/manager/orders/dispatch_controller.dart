import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

// MODÈLE COMMANDE
class ManagerOrder {
  final String id;
  final String client;
  final String productNeeded; // EX: "Total B12"
  final int quantityNeeded;   // EX: 2
  final String location;
  final String targetZone;
  final LatLng coordinates;
  final String details;
  final String timeAgo;
  final bool isPriority;
  String status;
  String? driverName;
  String? issueReason;

  ManagerOrder(this.id, this.client, this.location, this.targetZone, this.details, this.timeAgo, {
    required this.productNeeded,
    required this.quantityNeeded,
    this.coordinates = const LatLng(12.35, -1.51),
    this.isPriority = false,
    this.status = 'PENDING',
    this.driverName,
    this.issueReason
  });
}

// MODÈLE CHAUFFEUR AVEC STOCK EMBARQUÉ
class DriverCandidate {
  final String name;
  final String vehicle;
  final String currentZone;
  final String distance;
  final LatLng position;
  final bool isBusy;
  // NOUVEAU : Inventaire en temps réel (Simulation)
  final Map<String, int> onboardStock; 

  DriverCandidate(this.name, this.vehicle, this.currentZone, this.distance, this.position, {
    this.isBusy = false,
    required this.onboardStock
  });
}

class DispatchController extends GetxController {
  var pendingOrders = <ManagerOrder>[].obs;
  var assignedOrders = <ManagerOrder>[].obs;
  var issueOrders = <ManagerOrder>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFakeData();
  }

  void _loadFakeData() {
    pendingOrders.value = [
      // Commande 1 : Besoin de TOTAL B12
      ManagerOrder("CMD-885", "Maquis Le Verdoyant", "Ouaga 2000", "ZONE SUD", "5x Total B12", "Il y a 10 min", 
        productNeeded: "Total B12", quantityNeeded: 5, coordinates: const LatLng(12.3500, -1.5100), isPriority: true),
      
      // Commande 2 : Besoin de SODIGAZ B12
      ManagerOrder("CMD-887", "Boulangerie Wend-Konta", "Karpala", "ZONE EST", "2x Sodigaz B12", "Il y a 2 min", 
        productNeeded: "Sodigaz B12", quantityNeeded: 2, coordinates: const LatLng(12.3600, -1.4800)),
    ];
    assignedOrders.value = [
      ManagerOrder("CMD-880", "Clinique du Cœur", "Centre Ville", "ZONE CENTRE", "3x Total B12", "09:30", productNeeded: "Total B12", quantityNeeded: 3, status: 'ASSIGNED', driverName: "Amadou O.")
    ];
    issueOrders.value = [];
  }

  // RÉCUPÉRATION DES CHAUFFEURS AVEC LEUR STOCK RÉEL
  List<DriverCandidate> getDriversAround(LatLng target) {
    return [
      // AMADOU : A du stock Total (Bon pour CMD-885)
      DriverCandidate("Amadou O.", "TVS King", "ZONE SUD", "0.5 km", const LatLng(12.3520, -1.5120),
        onboardStock: {"Total B12": 6, "Sodigaz B6": 2} 
      ),
      
      // SEYDOU : A du stock Sodigaz (Bon pour CMD-887)
      DriverCandidate("Seydou K.", "Bajaj RE", "ZONE OUEST", "8.5 km", const LatLng(12.3650, -1.5500),
        onboardStock: {"Sodigaz B12": 4, "Oryx B12": 1}
      ),
      
      // MOUSSA : Vide (Ne peut rien prendre)
      DriverCandidate("Moussa T.", "TVS King", "ZONE EST", "12 km", const LatLng(12.3600, -1.4800),
        onboardStock: {"Vide": 10} // Que des bouteilles vides
      ),
    ];
  }

  // --- LE DISPATCH VISUEL INTELLIGENT ---
  void openAssignModal(ManagerOrder order) {
    List<DriverCandidate> drivers = getDriversAround(order.coordinates);
    
    Get.bottomSheet(
      Container(
        height: 600,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            // INFO COMMANDE
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Besoin Client :", style: TextStyle(fontSize: 10, color: Colors.blue.shade800)),
                    Text("${order.quantityNeeded}x ${order.productNeeded}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                  ]),
                  const Icon(Icons.shopping_cart, color: Colors.blue)
                ]
              ),
            ),
            
            // CARTE INTERACTIVE
            Expanded(
              child: FlutterMap(
                options: MapOptions(initialCenter: order.coordinates, initialZoom: 13.5),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.nafagaz.pro'),
                  MarkerLayer(markers: [
                    // CLIENT
                    Marker(point: order.coordinates, width: 60, height: 60, child: Column(children: [Icon(Icons.location_on, color: Colors.blue, size: 40), Container(padding: EdgeInsets.all(2), color: Colors.white, child: Text("CLIENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))])),
                    
                    // CHAUFFEURS
                    ...drivers.map((d) {
                      // VERIFICATION DU STOCK
                      int stockDispo = d.onboardStock[order.productNeeded] ?? 0;
                      bool hasStock = stockDispo >= order.quantityNeeded;
                      
                      return Marker(
                        point: d.position, width: 100, height: 80,
                        child: GestureDetector(
                          onTap: () => _showDriverDetails(order, d, hasStock, stockDispo),
                          child: Column(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), 
                              decoration: BoxDecoration(
                                color: hasStock ? Colors.green : Colors.red, // VERT SI STOCK OK, ROUGE SINON
                                borderRadius: BorderRadius.circular(5), 
                                border: Border.all(color: Colors.white)
                              ), 
                              child: Text(d.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))
                            ),
                            Icon(Icons.electric_rickshaw, color: hasStock ? Colors.green : Colors.red, size: 35),
                            // Badge Stock
                            if(hasStock)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                              child: Text("Stock: $stockDispo", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                            )
                          ]),
                        ),
                      );
                    })
                  ])
                ],
              ),
            ),
            
            // LEGENDE
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _legendItem(Colors.green, "Stock Compatible"),
                const SizedBox(width: 20),
                _legendItem(Colors.red, "Stock Insuffisant"),
              ]),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(children: [CircleAvatar(backgroundColor: color, radius: 5), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 12))]);
  }

  void _showDriverDetails(ManagerOrder order, DriverCandidate d, bool hasStock, int stockDispo) {
    Get.defaultDialog(
      title: d.name,
      content: Column(
        children: [
          Text("Véhicule : ${d.vehicle}"),
          const Divider(),
          const Text("STOCK DISPONIBLE À BORD :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          const SizedBox(height: 10),
          // Affiche tout le stock du chauffeur
          ...d.onboardStock.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key),
                Text("x${e.value}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
          const Divider(),
          if (!hasStock)
            Text("⚠️ Manque ${order.quantityNeeded - stockDispo} bouteille(s) pour cette commande.", style: const TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic))
          else
            const Text("✅ Stock suffisant pour livrer.", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))
        ],
      ),
      textConfirm: hasStock ? "ASSIGNER LA COURSE" : "Forcer l'assignation",
      confirmTextColor: Colors.white,
      buttonColor: hasStock ? Colors.green : Colors.grey,
      onConfirm: () {
        Get.back(); // Ferme Dialog
        Get.back(); // Ferme Map
        _confirmAssignment(order, d);
      }
    );
  }

  void _confirmAssignment(ManagerOrder order, DriverCandidate driver) {
    pendingOrders.remove(order);
    order.status = 'ASSIGNED';
    order.driverName = driver.name;
    assignedOrders.insert(0, order);
    Get.snackbar("Assigné !", "${driver.name} va livrer avec son stock tampon.", backgroundColor: Colors.green, colorText: Colors.white);
  }

  void openResolveModal(ManagerOrder order) {}
}
