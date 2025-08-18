import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String? id;
  final String serviceId;
  final String serviceName;
  final String category;
  final int duration;
  final double price;
  final String description;
  final String? imageBase64;
  final int quantity;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    this.id,
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.duration,
    required this.price,
    required this.description,
    this.imageBase64,
    required this.quantity,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert CartItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'category': category,
      'duration': duration,
      'price': price,
      'description': description,
      'imageBase64': imageBase64,
      'quantity': quantity,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create CartItem from Firestore document
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageBase64: data['imageBase64'],
      quantity: data['quantity'] ?? 1,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create CartItem from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageBase64: map['imageBase64'],
      quantity: map['quantity'] ?? 1,
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : map['updatedAt'] ?? DateTime.now(),
    );
  }

  // Create a copy of CartItem with updated fields
  CartItem copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? category,
    int? duration,
    double? price,
    String? description,
    String? imageBase64,
    int? quantity,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      description: description ?? this.description,
      imageBase64: imageBase64 ?? this.imageBase64,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate total price for this cart item
  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'CartItem{id: $id, serviceName: $serviceName, quantity: $quantity, totalPrice: $totalPrice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.serviceId == serviceId &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^ serviceId.hashCode ^ quantity.hashCode;
  }
}