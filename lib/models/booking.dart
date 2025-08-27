import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;
  final String userId;
  final String customerName;
  final List<BookingService> services;
  final DateTime bookingDate;
  final String bookingTime;
  final String branch;
  final String? address; // Address for home services
  final double totalPrice;
  final int totalDuration;
  final String status; // 'upcoming', 'past', 'cancelled'
  final String paymentMethod;
  final bool emailConfirmation;
  final bool smsConfirmation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    this.id,
    required this.userId,
    required this.customerName,
    required this.services,
    required this.bookingDate,
    required this.bookingTime,
    required this.branch,
    this.address,
    required this.totalPrice,
    required this.totalDuration,
    required this.status,
    required this.paymentMethod,
    required this.emailConfirmation,
    required this.smsConfirmation,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'services': services.map((service) => service.toMap()).toList(),
      'bookingDate': Timestamp.fromDate(bookingDate),
      'bookingTime': bookingTime,
      'branch': branch,
      'address': address,
      'totalPrice': totalPrice,
      'totalDuration': totalDuration,
      'status': status,
      'paymentMethod': paymentMethod,
      'emailConfirmation': emailConfirmation,
      'smsConfirmation': smsConfirmation,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert to Firestore document (alias for toMap)
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // Create Booking from Firestore document
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      services: (data['services'] as List<dynamic>? ?? [])
          .map((service) => BookingService.fromMap(service as Map<String, dynamic>))
          .toList(),
      bookingDate: (data['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookingTime: data['bookingTime'] ?? '',
      branch: data['branch'] ?? '',
      address: data['address'],
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      totalDuration: data['totalDuration'] ?? 0,
      status: data['status'] ?? 'upcoming',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      emailConfirmation: data['emailConfirmation'] ?? false,
      smsConfirmation: data['smsConfirmation'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create Booking from Map
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'] ?? '',
      customerName: map['customerName'] ?? '',
      services: (map['services'] as List<dynamic>? ?? [])
          .map((service) => BookingService.fromMap(service as Map<String, dynamic>))
          .toList(),
      bookingDate: map['bookingDate'] is Timestamp 
          ? (map['bookingDate'] as Timestamp).toDate() 
          : map['bookingDate'] ?? DateTime.now(),
      bookingTime: map['bookingTime'] ?? '',
      branch: map['branch'] ?? '',
      address: map['address'],
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      totalDuration: map['totalDuration'] ?? 0,
      status: map['status'] ?? 'upcoming',
      paymentMethod: map['paymentMethod'] ?? 'cash',
      emailConfirmation: map['emailConfirmation'] ?? false,
      smsConfirmation: map['smsConfirmation'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : map['updatedAt'] ?? DateTime.now(),
    );
  }

  

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class BookingService {
  final String serviceId;
  final String serviceName;
  final String category;
  final int duration;
  final double price;
  final int quantity;

  BookingService({
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.duration,
    required this.price,
    required this.quantity,
  });

  


  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'BookingService{serviceName: $serviceName, quantity: $quantity, totalPrice: $totalPrice}';
  }
}
