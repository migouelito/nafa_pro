// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import '../controllers/driver_controller.dart';

// class DriverView extends GetView<DriverController> {
//   const DriverView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // AppBar flottante ou transparente pour laisser place à la map
//       extendBodyBehindAppBar: false,
//       appBar: AppBar(
//         title: Obx(() => Text(controller.isOnline.value ? "🟢 EN LIGNE" : "🔴 HORS LIGNE", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
//         backgroundColor: Colors.black87,
//         foregroundColor: Colors.white,
//         actions: [
//           Obx(() => Switch(
//             value: controller.isOnline.value, 
//             activeColor: const Color(0xFF00A86B),
//             onChanged: controller.toggleStatus
//           )),
//           IconButton(icon: const Icon(Icons.logout), onPressed: controller.logout)
//         ],
//       ),
      
//       // STACK : Carte en fond + Widgets par dessus
//       body: Stack(
//         children: [
//           // 1. LA CARTE (OpenStreetMap)
//           Obx(() => FlutterMap(
//             mapController: controller.mapController,
//             options: MapOptions(
//               initialCenter: controller.currentPosition.value, // Ouaga
//               initialZoom: 14.0,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.nafagaz.pro',
//               ),
              
//               // Marqueurs (Livreur + Client si commande)
//               MarkerLayer(
//                 markers: [
//                   // Marqueur LIVREUR (Moto)
//                   Marker(
//                     point: controller.currentPosition.value,
//                     width: 50, height: 50,
//                     child: const Icon(Icons.two_wheeler, color: Colors.black, size: 40),
//                   ),
                  
//                   // Marqueur CLIENT (Visible seulement si commande active)
//                   if (controller.orderStatus.value != 'IDLE')
//                     Marker(
//                       point: controller.clientPosition.value,
//                       width: 50, height: 50,
//                       child: const Icon(Icons.location_on, color: Colors.red, size: 40),
//                     ),
//                 ],
//               ),
              
//               // Trajet (Ligne simple pour l'instant)
//               if (controller.orderStatus.value == 'DELIVERING')
//                 PolylineLayer(
//                   polylines: [
//                     Polyline(
//                       points: [controller.currentPosition.value, controller.clientPosition.value],
//                       strokeWidth: 4.0,
//                       color: Colors.blue,
//                     ),
//                   ],
//                 ),
//             ],
//           )),

//           // 2. PANNEAU DE COMMANDE (Bas de page)
//           Positioned(
//             bottom: 0, left: 0, right: 0,
//             child: Obx(() => _buildBottomPanel()),
//           ),

//           // 3. BOUTON DEBUG (Pour simuler une commande)
//           Positioned(
//             top: 20, right: 20,
//             child: FloatingActionButton.small(
//               backgroundColor: Colors.white,
//               child: const Icon(Icons.bug_report, color: Colors.grey),
//               onPressed: controller.simulateIncomingOrder,
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // WIDGET DYNAMIQUE DU BAS
//   Widget _buildBottomPanel() {
//     String status = controller.orderStatus.value;

//     // CAS 1 : SONNERIE (Nouvelle Commande)
//     if (status == 'RINGING') {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)]
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("NOUVELLE COMMANDE 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
//             const SizedBox(height: 10),
//             const ListTile(
//               leading: Icon(Icons.person, color: Colors.grey),
//               title: Text("Moussa Koné"),
//               subtitle: Text("Patte d'oie (2.5 km) • 1x Bouteille 12kg"),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: controller.rejectOrder,
//                     style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
//                     child: const Text("REFUSER"),
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: controller.acceptOrder,
//                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A86B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
//                     child: const Text("ACCEPTER"),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       );
//     }

//     // CAS 2 : EN COURS DE LIVRAISON
//     if (status == 'DELIVERING') {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("En route vers Client", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
//                   child: const Text("GPS Actif", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
//                 )
//               ],
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: controller.arriveAtClient, // Simule l'arrivée
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
//                 icon: const Icon(Icons.flag),
//                 label: const Text("JE SUIS ARRIVÉ"),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // CAS 3 : ATTENTE (Rien à afficher ou juste stats)
//     return const SizedBox.shrink(); 
//   }
// }