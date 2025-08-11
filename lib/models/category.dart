import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String? id;
  final String name;
  final String description;
  final int serviceCount;
  final String color;
  final String? imageBase64;
  final String gender; // 'men', 'women', or 'unisex'
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Category({
    this.id,
    required this.name,
    required this.description,
    required this.serviceCount,
    required this.color,
    this.imageBase64,
    required this.gender,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      serviceCount: data['serviceCount'] ?? 0,
      color: data['color'] ?? '',
      imageBase64: data['imageBase64'],
      gender: data['gender'] ?? 'unisex',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'serviceCount': serviceCount,
      'color': color,
      'imageBase64': imageBase64,
      'gender': gender,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? description,
    int? serviceCount,
    String? color,
    String? imageBase64,
    String? gender,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      serviceCount: serviceCount ?? this.serviceCount,
      color: color ?? this.color,
      imageBase64: imageBase64 ?? this.imageBase64,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}