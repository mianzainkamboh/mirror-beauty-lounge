import 'package:google_maps_flutter/google_maps_flutter.dart';

class Branch {
  final String id;
  final String name;
  final String address;
  final LatLng coordinates;
  final String phone;
  final String description;
  final List<String> workingHours;
  final List<String> amenities;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.phone,
    required this.description,
    required this.workingHours,
    required this.amenities,
  });

  // Static list of all Mirrors Beauty Lounge branches with real coordinates
  static const List<Branch> allBranches = [
    Branch(
      id: 'batutta_mall',
      name: 'Mirrors Beauty Lounge - Batutta Mall',
      address: 'Ibn Battuta Mall, Sheikh Zayed Road, Dubai',
      coordinates: LatLng(25.040000, 55.117800), // Ibn Battuta Mall coordinates
      phone: '+971 4 269 1449',
      description: 'Located in the world\'s largest themed shopping mall',
      workingHours: [
        'Sunday - Thursday: 10:00 AM - 10:00 PM',
        'Friday - Saturday: 10:00 AM - 12:00 AM'
      ],
      amenities: ['Parking Available', 'Mall Location', 'Easy Access'],
    ),
    Branch(
      id: 'al_bustan',
      name: 'Mirrors Beauty Lounge - Al Bustan Centre',
      address: 'Al Bustan Centre, Al Nahda Road, Dubai',
      coordinates: LatLng(25.267906, 55.323158), // Al Bustan Centre coordinates
      phone: '+971 50 545 8263',
      description: 'Conveniently located in Al Bustan Centre',
      workingHours: [
        'Sunday - Thursday: 9:00 AM - 9:00 PM',
        'Friday - Saturday: 9:00 AM - 10:00 PM'
      ],
      amenities: ['Free Parking', 'Shopping Center', 'Family Friendly'],
    ),
    Branch(
      id: 'muraqabat',
      name: 'Mirrors Beauty Lounge - Muraqabat',
      address: 'Al Muraqabat Area, Dubai',
      coordinates: LatLng(25.267906, 55.323158), // Muraqabat coordinates
      phone: '+971 56 537 3911',
      description: 'Premium beauty services in the heart of Muraqabat',
      workingHours: [
        'Sunday - Thursday: 9:00 AM - 9:00 PM',
        'Friday - Saturday: 9:00 AM - 10:00 PM'
      ],
      amenities: ['Street Parking', 'Central Location', 'Easy Metro Access'],
    ),
    Branch(
      id: 'barsha_heights',
      name: 'Mirrors Beauty Lounge - Barsha Heights',
      address: 'New API Building, Barsha Heights (TECOM), Dubai',
      coordinates: LatLng(25.097670, 55.175536), // Barsha Heights coordinates
      phone: '+971 50 224 7058',
      description: 'Modern salon in the business district of TECOM',
      workingHours: [
        'Sunday - Thursday: 9:00 AM - 9:00 PM',
        'Friday - Saturday: 9:00 AM - 10:00 PM'
      ],
      amenities: ['Business District', 'Modern Facilities', 'Valet Parking'],
    ),
    Branch(
      id: 'marina',
      name: 'Mirrors Beauty Lounge - Marina',
      address: 'Dubai Marina, Dubai',
      coordinates: LatLng(25.088907, 55.148571), // Dubai Marina coordinates
      phone: '+971 56 300 5629',
      description: 'Luxury beauty services with marina views',
      workingHours: [
        'Sunday - Thursday: 9:00 AM - 9:00 PM',
        'Friday - Saturday: 9:00 AM - 10:00 PM'
      ],
      amenities: ['Marina Views', 'Luxury Setting', 'Waterfront Location'],
    ),
  ];

  // Get branch by ID
  static Branch? getBranchById(String id) {
    try {
      return allBranches.firstWhere((branch) => branch.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get branch by name
  static Branch? getBranchByName(String name) {
    try {
      return allBranches.firstWhere(
        (branch) => branch.name.toLowerCase().contains(name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'phone': phone,
      'description': description,
      'workingHours': workingHours,
      'amenities': amenities,
    };
  }

  // Create from JSON
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      coordinates: LatLng(
        json['latitude']?.toDouble() ?? 0.0,
        json['longitude']?.toDouble() ?? 0.0,
      ),
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      workingHours: List<String>.from(json['workingHours'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Branch{id: $id, name: $name, address: $address}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Branch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}