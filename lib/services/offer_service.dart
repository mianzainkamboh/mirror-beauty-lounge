import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'fcm_service.dart';
import 'notification_service.dart';

class OfferService {
  static final OfferService _instance = OfferService._internal();
  factory OfferService() => _instance;
  OfferService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FCMService _fcmService = FCMService();
  final NotificationService _notificationService = NotificationService();

  // Create and send offer notification
  Future<void> createOfferNotification({
    required String title,
    required String description,
    String? imageUrl,
    String? discountPercentage,
    DateTime? validUntil,
    List<String>? applicableServices,
  }) async {
    try {
      // Create offer document
      Map<String, dynamic> offerData = {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'discountPercentage': discountPercentage,
        'validUntil': validUntil,
        'applicableServices': applicableServices ?? [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save offer to Firestore
      DocumentReference offerRef = await _firestore.collection('offers').add(offerData);
      String offerId = offerRef.id;

      // Create notification body
      String notificationBody = description;
      if (discountPercentage != null) {
        notificationBody = '$discountPercentage% OFF! $description';
      }

      // Send offer notification to all users
      await _fcmService.sendOfferNotification(
        title: title,
        body: notificationBody,
        offerId: offerId,
      );

      // Also send local notification for immediate display
      await _notificationService.sendOfferNotification(
        title: title,
        body: notificationBody,
        offerId: offerId,
      );

      debugPrint('Offer notification created and sent: $offerId');
    } catch (e) {
      debugPrint('Error creating offer notification: $e');
      throw Exception('Failed to create offer notification: $e');
    }
  }

  // Send special promotion notification
  Future<void> sendPromotionNotification({
    required String title,
    required String message,
    String? promoCode,
  }) async {
    try {
      String notificationBody = message;
      if (promoCode != null) {
        notificationBody += ' Use code: $promoCode';
      }

      await createOfferNotification(
        title: title,
        description: notificationBody,
      );

      debugPrint('Promotion notification sent: $title');
    } catch (e) {
      debugPrint('Error sending promotion notification: $e');
    }
  }

  // Send seasonal offer notification
  Future<void> sendSeasonalOffer({
    required String season, // e.g., "Summer", "Winter", "Holiday"
    required String offerDetails,
    String? discountPercentage,
  }) async {
    try {
      String title = '$season Special Offer! 🎉';
      String description = offerDetails;

      await createOfferNotification(
        title: title,
        description: description,
        discountPercentage: discountPercentage,
        validUntil: DateTime.now().add(const Duration(days: 30)), // Valid for 30 days
      );

      debugPrint('Seasonal offer sent: $season');
    } catch (e) {
      debugPrint('Error sending seasonal offer: $e');
    }
  }

  // Send new service launch notification
  Future<void> sendNewServiceNotification({
    required String serviceName,
    required String serviceDescription,
    String? introductoryOffer,
  }) async {
    try {
      String title = 'New Service Available! ✨';
      String description = 'Introducing $serviceName - $serviceDescription';
      
      if (introductoryOffer != null) {
        description += ' $introductoryOffer';
      }

      await createOfferNotification(
        title: title,
        description: description,
        applicableServices: [serviceName],
      );

      debugPrint('New service notification sent: $serviceName');
    } catch (e) {
      debugPrint('Error sending new service notification: $e');
    }
  }

  // Send birthday/anniversary offer
  Future<void> sendPersonalizedOffer({
    required String userId,
    required String customerName,
    required String occasionType, // "birthday", "anniversary"
    String? specialDiscount,
  }) async {
    try {
      String title = 'Happy ${occasionType.toUpperCase()}! 🎂';
      String description = 'Happy $occasionType $customerName! ';
      
      if (specialDiscount != null) {
        description += 'Enjoy $specialDiscount off your next appointment!';
      } else {
        description += 'Enjoy a special treat on your next visit!';
      }

      // Send personalized notification to specific user
      await _fcmService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: description,
        type: NotificationType.offer,
      );

      debugPrint('Personalized offer sent to user: $userId');
    } catch (e) {
      debugPrint('Error sending personalized offer: $e');
    }
  }

  // Get active offers
  Future<List<Map<String, dynamic>>> getActiveOffers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting active offers: $e');
      return [];
    }
  }

  // Deactivate offer
  Future<void> deactivateOffer(String offerId) async {
    try {
      await _firestore.collection('offers').doc(offerId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Offer deactivated: $offerId');
    } catch (e) {
      debugPrint('Error deactivating offer: $e');
    }
  }

  // Send flash sale notification
  Future<void> sendFlashSaleNotification({
    required String saleTitle,
    required String saleDescription,
    required Duration saleDuration,
    String? discountPercentage,
  }) async {
    try {
      String title = '⚡ FLASH SALE: $saleTitle';
      String description = '$saleDescription - Limited time only!';
      
      if (discountPercentage != null) {
        description = '$discountPercentage% OFF! $description';
      }

      await createOfferNotification(
        title: title,
        description: description,
        discountPercentage: discountPercentage,
        validUntil: DateTime.now().add(saleDuration),
      );

      debugPrint('Flash sale notification sent: $saleTitle');
    } catch (e) {
      debugPrint('Error sending flash sale notification: $e');
    }
  }

  // Send loyalty reward notification
  Future<void> sendLoyaltyRewardNotification({
    required String userId,
    required String customerName,
    required String rewardDetails,
  }) async {
    try {
      String title = 'Loyalty Reward Unlocked! 🏆';
      String description = 'Congratulations $customerName! $rewardDetails';

      await _fcmService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: description,
        type: NotificationType.offer,
      );

      debugPrint('Loyalty reward notification sent to: $userId');
    } catch (e) {
      debugPrint('Error sending loyalty reward notification: $e');
    }
  }

  // Send general offer notification
  Future<void> sendGeneralOffer({
    required String title,
    required String description,
    String? discountPercentage,
    String? imageUrl,
    DateTime? validUntil,
  }) async {
    try {
      await createOfferNotification(
        title: title,
        description: description,
        discountPercentage: discountPercentage,
        imageUrl: imageUrl,
        validUntil: validUntil,
      );

      debugPrint('General offer sent: $title');
    } catch (e) {
      debugPrint('Error sending general offer: $e');
    }
  }
}