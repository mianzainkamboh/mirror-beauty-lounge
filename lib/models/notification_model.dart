import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum NotificationType {
  offer,
  bookingConfirmation,
  bookingReminder,
  bookingToday,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String userId;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? bookingId;
  final String? offerId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.userId,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.bookingId,
    this.offerId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      
      if (data == null) {
        throw Exception('Document data is null for ${doc.id}');
      }
      
      // Handle createdAt field safely
      DateTime createdAt;
      try {
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          createdAt = DateTime.parse(data['createdAt']);
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        debugPrint('Error parsing createdAt for ${doc.id}: $e');
        createdAt = DateTime.now();
      }
      
      // Handle notification type safely
      NotificationType type;
      try {
        final typeString = data['type']?.toString() ?? 'offer';
        type = NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
          orElse: () => NotificationType.offer,
        );
      } catch (e) {
        debugPrint('Error parsing type for ${doc.id}: $e');
        type = NotificationType.offer;
      }
      
      return NotificationModel(
        id: doc.id,
        title: data['title']?.toString() ?? 'Notification',
        body: data['body']?.toString() ?? '',
        type: type,
        userId: data['userId']?.toString() ?? '',
        createdAt: createdAt,
        isRead: data['isRead'] == true,
        data: data['data'] as Map<String, dynamic>?,
        bookingId: data['bookingId']?.toString(),
        offerId: data['offerId']?.toString(),
      );
    } catch (e) {
      debugPrint('Error creating NotificationModel from Firestore: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'data': data,
      'bookingId': bookingId,
      'offerId': offerId,
    };
  }

  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? userId,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? bookingId,
    String? offerId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      bookingId: bookingId ?? this.bookingId,
      offerId: offerId ?? this.offerId,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.offer:
        return 'Special Offer';
      case NotificationType.bookingConfirmation:
        return 'Booking Confirmed';
      case NotificationType.bookingReminder:
        return 'Booking Reminder';
      case NotificationType.bookingToday:
        return 'Booking Today';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.offer:
        return '🎉';
      case NotificationType.bookingConfirmation:
        return '✅';
      case NotificationType.bookingReminder:
        return '⏰';
      case NotificationType.bookingToday:
        return '📅';
    }
  }
}