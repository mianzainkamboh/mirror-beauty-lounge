// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _mapController;
//   LatLng? _currentPosition;
//   final LatLng _branchPosition = LatLng(31.5204, 74.3587); // Example: Lahore
//   Set<Marker> _markers = {};
//   List<LatLng> _polylineCoordinates = [];
//   double? _distanceInKm;
//
//   @override
//   void initState() {
//     super.initState();
//     _getUserLocation();
//   }
//
//   Future<void> _getUserLocation() async {
//     Location location = Location();
//     final currentLoc = await location.getLocation();
//     setState(() {
//       _currentPosition = LatLng(currentLoc.latitude!, currentLoc.longitude!);
//       _markers.add(Marker(
//         markerId: const MarkerId('me'),
//         position: _currentPosition!,
//         infoWindow: const InfoWindow(title: 'You'),
//       ));
//       _markers.add(Marker(
//         markerId: const MarkerId('branch'),
//         position: _branchPosition,
//         infoWindow: const InfoWindow(title: 'Branch'),
//       ));
//     });
//
//     _drawRoute();
//     _calculateDistance();
//   }
//
//   void _drawRoute() async {
//     PolylinePoints polylinePoints = PolylinePoints();
//     final result = await polylinePoints.getRouteBetweenCoordinates(
//       'YOUR_GOOGLE_MAPS_API_KEY',
//       PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//       PointLatLng(_branchPosition.latitude, _branchPosition.longitude),
//     );
//
//     if (result.points.isNotEmpty) {
//       _polylineCoordinates =
//           result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
//       setState(() {});
//     }
//   }
//
//   void _calculateDistance() {
//     double distance = Geolocator.distanceBetween(
//       _currentPosition!.latitude,
//       _currentPosition!.longitude,
//       _branchPosition.latitude,
//       _branchPosition.longitude,
//     );
//     setState(() {
//       _distanceInKm = distance / 1000;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _currentPosition!,
//               zoom: 14,
//             ),
//             onMapCreated: (controller) => _mapController = controller,
//             markers: _markers,
//             polylines: {
//               Polyline(
//                 polylineId: const PolylineId('route'),
//                 color: Colors.blue,
//                 width: 4,
//                 points: _polylineCoordinates,
//               )
//             },
//           ),
//           Positioned(
//             top: 40,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.search),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Text('Salon Design by: Fluttertop'),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text('Signature Salon'),
//                   const Text('1222 Russell Street, Cambridge...'),
//                   Text('${_distanceInKm?.toStringAsFixed(2)} km away'),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
