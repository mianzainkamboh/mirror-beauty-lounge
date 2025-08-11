import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String? id;
  final String name;
  final String category;
  final int duration; // in minutes
  final double price;
  final String description;
  final bool isActive;
  final String? imageBase64;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Service({
    this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.price,
    required this.description,
    required this.isActive,
    this.imageBase64,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore document
  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      imageBase64: data['imageBase64'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'duration': duration,
      'price': price,
      'description': description,
      'isActive': isActive,
      'imageBase64': imageBase64,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  Service copyWith({
    String? id,
    String? name,
    String? category,
    int? duration,
    double? price,
    String? description,
    bool? isActive,
    String? imageBase64,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      imageBase64: imageBase64 ?? this.imageBase64,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}