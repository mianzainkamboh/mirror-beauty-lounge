import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String? id;
  final String title;
  final String description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final String validFrom;
  final String validTo;
  final bool isActive;
  final int? usageLimit;
  final int usedCount;
  final String? imageBase64;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  // Getter for endDate - converts validTo string to DateTime
  DateTime get endDate {
    try {
      return DateTime.parse(validTo);
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }
  }

  Offer({
    this.id,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validTo,
    required this.isActive,
    this.usageLimit,
    required this.usedCount,
    this.imageBase64,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore document
  factory Offer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Offer(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      discountType: data['discountType'] ?? 'percentage',
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      validFrom: data['validFrom'] ?? '',
      validTo: data['validTo'] ?? '',
      isActive: data['isActive'] ?? true,
      usageLimit: data['usageLimit'],
      usedCount: data['usedCount'] ?? 0,
      imageBase64: data['imageBase64'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'validFrom': validFrom,
      'validTo': validTo,
      'isActive': isActive,
      'usedCount': usedCount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    // Only include optional fields if they are not null
    if (usageLimit != null) {
      data['usageLimit'] = usageLimit;
    }
    if (imageBase64 != null) {
      data['imageBase64'] = imageBase64;
    }
    
    return data;
  }

  // Create a copy with updated fields
  Offer copyWith({
    String? id,
    String? title,
    String? description,
    String? discountType,
    double? discountValue,
    String? validFrom,
    String? validTo,
    bool? isActive,
    int? usageLimit,
    int? usedCount,
    String? imageBase64,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Offer(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      imageBase64: imageBase64 ?? this.imageBase64,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}