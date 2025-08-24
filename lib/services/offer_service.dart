import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/offer.dart';
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

  // Collection reference
  CollectionReference get _offersCollection => _firestore.collection('offers');
  CollectionReference get _offerUsageCollection => _firestore.collection('offer_usage');
  CollectionReference get _userOffersCollection => _firestore.collection('user_offers');

  // CRUD Operations
  
  // Create a new offer
  Future<String> createOffer(Offer offer) async {
    try {
      DocumentReference docRef = await _offersCollection.add(offer.toFirestore());
      debugPrint('Offer created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating offer: $e');
      throw Exception('Failed to create offer: $e');
    }
  }

  // Get offer by ID
  Future<Offer?> getOfferById(String offerId) async {
    try {
      DocumentSnapshot doc = await _offersCollection.doc(offerId).get();
      if (doc.exists) {
        return Offer.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting offer: $e');
      return null;
    }
  }

  // Update an existing offer
  Future<void> updateOffer(String offerId, Offer offer) async {
    try {
      await _offersCollection.doc(offerId).update(offer.toFirestore());
      debugPrint('Offer updated: $offerId');
    } catch (e) {
      debugPrint('Error updating offer: $e');
      throw Exception('Failed to update offer: $e');
    }
  }

  // Delete an offer
  Future<void> deleteOffer(String offerId) async {
    try {
      await _offersCollection.doc(offerId).delete();
      debugPrint('Offer deleted: $offerId');
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      throw Exception('Failed to delete offer: $e');
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
      Offer offer = Offer(
        id: null,
        title: '$season Special Offer! 🎉',
        description: offerDetails,
        discountType: 'percentage',
        discountValue: double.tryParse(discountPercentage ?? '0') ?? 0,
        validFrom: DateTime.now().toIso8601String(),
        validTo: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        isActive: true,
        usageLimit: null,
        usedCount: 0,
        offerType: OfferType.seasonal,
        targetServices: [],
        targetBranches: [],
        userEligibility: UserEligibility.all,
        requiresPromoCode: false,
        isStackable: false,
      );
      
      await createOffer(offer);

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

  // Offer Retrieval Methods
  
  // Get all active offers
  Future<List<Offer>> getActiveOffers() async {
    try {
      String now = DateTime.now().toIso8601String();
      QuerySnapshot snapshot = await _offersCollection
          .where('isActive', isEqualTo: true)
          .where('validFrom', isLessThanOrEqualTo: now)
          .where('validTo', isGreaterThan: now)
          .get();
      
      return snapshot.docs.map((doc) => Offer.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting active offers: $e');
      return [];
    }
  }

  // Get offers by type
  Future<List<Offer>> getOffersByType(OfferType offerType) async {
    try {
      String now = DateTime.now().toIso8601String();
      QuerySnapshot snapshot = await _offersCollection
          .where('isActive', isEqualTo: true)
          .where('offerType', isEqualTo: offerType.toString().split('.').last)
          .where('validFrom', isLessThanOrEqualTo: now)
          .where('validTo', isGreaterThan: now)
          .get();
      
      return snapshot.docs.map((doc) => Offer.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting offers by type: $e');
      return [];
    }
  }

  // Get offers for specific service
  Future<List<Offer>> getOffersForService(String serviceId) async {
    try {
      String now = DateTime.now().toIso8601String();
      QuerySnapshot snapshot = await _offersCollection
          .where('isActive', isEqualTo: true)
          .where('validFrom', isLessThanOrEqualTo: now)
          .where('validTo', isGreaterThan: now)
          .get();
      
      List<Offer> allOffers = snapshot.docs.map((doc) => Offer.fromFirestore(doc)).toList();
      
      // Filter offers that apply to this service or have no service restrictions
      return allOffers.where((offer) => 
          offer.targetServices.isEmpty || offer.isValidForService(serviceId)
      ).toList();
    } catch (e) {
      debugPrint('Error getting offers for service: $e');
      return [];
    }
  }

  // Get offers for specific branch
  Future<List<Offer>> getOffersForBranch(String branchId) async {
    try {
      String now = DateTime.now().toIso8601String();
      QuerySnapshot snapshot = await _offersCollection
          .where('isActive', isEqualTo: true)
          .where('validFrom', isLessThanOrEqualTo: now)
          .where('validTo', isGreaterThan: now)
          .get();
      
      List<Offer> allOffers = snapshot.docs.map((doc) => Offer.fromFirestore(doc)).toList();
      
      // Filter offers that apply to this branch or have no branch restrictions
      return allOffers.where((offer) => 
          offer.targetBranches.isEmpty || offer.isValidForBranch(branchId)
      ).toList();
    } catch (e) {
      debugPrint('Error getting offers for branch: $e');
      return [];
    }
  }

  // Promotional Code Validation and Application
  
  // Validate promotional code
  Future<Offer?> validatePromoCode(String promoCode, {
    String? userId,
    String? serviceId,
    String? branchId,
    double? orderAmount,
  }) async {
    try {
      String now = DateTime.now().toIso8601String();
      QuerySnapshot snapshot = await _offersCollection
          .where('isActive', isEqualTo: true)
          .where('requiresPromoCode', isEqualTo: true)
          .where('promoCode', isEqualTo: promoCode)
          .where('validFrom', isLessThanOrEqualTo: now)
          .where('validTo', isGreaterThan: now)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null; // Invalid promo code
      }
      
      Offer offer = Offer.fromFirestore(snapshot.docs.first);
      
      // Validate service targeting
      if (serviceId != null && !offer.isValidForService(serviceId)) {
        return null;
      }
      
      // Validate branch targeting
      if (branchId != null && !offer.isValidForBranch(branchId)) {
        return null;
      }
      
      // Validate order amount
      if (orderAmount != null && !offer.isValidForAmount(orderAmount)) {
        return null;
      }
      
      // Validate user eligibility
      if (userId != null && !await _isUserEligibleForOffer(userId, offer)) {
        return null;
      }
      
      // Check usage limits
      if (!await _checkOfferUsageLimits(offer.id!, userId)) {
        return null;
      }
      
      return offer;
    } catch (e) {
      debugPrint('Error validating promo code: $e');
      return null;
    }
  }
  
  // Apply offer and calculate discount
  Future<Map<String, dynamic>> applyOffer({
    required String offerId,
    required double orderAmount,
    String? userId,
    String? serviceId,
    String? branchId,
  }) async {
    try {
      Offer? offer = await getOfferById(offerId);
      if (offer == null) {
        return {'success': false, 'message': 'Offer not found'};
      }
      
      // Validate offer conditions
      DateTime now = DateTime.now();
      DateTime validFrom = DateTime.parse(offer.validFrom);
      DateTime validTo = DateTime.parse(offer.validTo);
      
      if (!offer.isActive || 
          now.isBefore(validFrom) || 
          now.isAfter(validTo)) {
        return {'success': false, 'message': 'Offer is not valid'};
      }
      
      if (serviceId != null && !offer.isValidForService(serviceId)) {
        return {'success': false, 'message': 'Offer not valid for this service'};
      }
      
      if (branchId != null && !offer.isValidForBranch(branchId)) {
        return {'success': false, 'message': 'Offer not valid for this branch'};
      }
      
      if (!offer.isValidForAmount(orderAmount)) {
        return {'success': false, 'message': 'Order amount does not meet minimum requirement'};
      }
      
      if (userId != null && !await _isUserEligibleForOffer(userId, offer)) {
        return {'success': false, 'message': 'User not eligible for this offer'};
      }
      
      if (!await _checkOfferUsageLimits(offerId, userId)) {
        return {'success': false, 'message': 'Offer usage limit exceeded'};
      }
      
      // Calculate discount
      double discountAmount = offer.calculateDiscount(orderAmount);
      double finalAmount = orderAmount - discountAmount;
      
      // Record offer usage
      if (userId != null) {
        await _recordOfferUsage(offerId, userId, discountAmount);
      }
      
      return {
        'success': true,
        'discountAmount': discountAmount,
        'finalAmount': finalAmount,
        'offer': offer,
      };
    } catch (e) {
      debugPrint('Error applying offer: $e');
      return {'success': false, 'message': 'Failed to apply offer'};
    }
  }
  
  // Deactivate offer
  Future<void> deactivateOffer(String offerId) async {
    try {
      await _offersCollection.doc(offerId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Offer deactivated: $offerId');
    } catch (e) {
      debugPrint('Error deactivating offer: $e');
      throw Exception('Failed to deactivate offer: $e');
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

  // Helper Methods
  
  // Check if user is eligible for offer based on user type
  Future<bool> _isUserEligibleForOffer(String userId, Offer offer) async {
    try {
      // For now, we'll assume all users are eligible
      // This can be enhanced to check user registration date, VIP status, etc.
      if (offer.userEligibility == UserEligibility.all) {
        return true;
      }
      
      // Get user data to check eligibility
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return false;
      }
      
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      switch (offer.userEligibility) {
        case UserEligibility.newCustomers:
          // Check if user has made any previous bookings
          QuerySnapshot bookings = await _firestore
              .collection('bookings')
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'completed')
              .limit(1)
              .get();
          return bookings.docs.isEmpty;
          
        case UserEligibility.existingCustomers:
          // Check if user has made at least one booking
          QuerySnapshot existingBookings = await _firestore
              .collection('bookings')
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'completed')
              .limit(1)
              .get();
          return existingBookings.docs.isNotEmpty;
          
        case UserEligibility.vipCustomers:
          // Check if user has VIP status
          return userData['isVip'] == true;
          
        default:
          return true;
      }
    } catch (e) {
      debugPrint('Error checking user eligibility: $e');
      return false;
    }
  }
  
  // Check offer usage limits
  Future<bool> _checkOfferUsageLimits(String offerId, String? userId) async {
    try {
      Offer? offer = await getOfferById(offerId);
      if (offer == null) return false;
      
      // Check global usage limit
      if (offer.usageLimit != null) {
        if (offer.usedCount >= offer.usageLimit!) {
          return false;
        }
      }
      
      // Check per-user usage limit
      if (userId != null && offer.maxUsesPerUser != null) {
        QuerySnapshot userUsage = await _offerUsageCollection
            .where('offerId', isEqualTo: offerId)
            .where('userId', isEqualTo: userId)
            .get();
        
        if (userUsage.docs.length >= offer.maxUsesPerUser!) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking usage limits: $e');
      return false;
    }
  }
  
  // Record offer usage
  Future<void> _recordOfferUsage(String offerId, String userId, double discountAmount) async {
    try {
      // Record in usage collection
      await _offerUsageCollection.add({
        'offerId': offerId,
        'userId': userId,
        'discountAmount': discountAmount,
        'usedAt': FieldValue.serverTimestamp(),
      });
      
      // Update offer usage count
      await _offersCollection.doc(offerId).update({
        'usedCount': FieldValue.increment(1),
      });
      
      debugPrint('Offer usage recorded: $offerId for user: $userId');
    } catch (e) {
      debugPrint('Error recording offer usage: $e');
    }
  }
  
  // Analytics Methods
  
  // Get offer analytics
  Future<Map<String, dynamic>> getOfferAnalytics(String offerId) async {
    try {
      Offer? offer = await getOfferById(offerId);
      if (offer == null) {
        return {'error': 'Offer not found'};
      }
      
      // Get usage statistics
      QuerySnapshot usageSnapshot = await _offerUsageCollection
          .where('offerId', isEqualTo: offerId)
          .get();
      
      double totalDiscountGiven = 0;
      Set<String> uniqueUsers = {};
      
      for (var doc in usageSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalDiscountGiven += (data['discountAmount'] ?? 0.0);
        uniqueUsers.add(data['userId']);
      }
      
      return {
        'offerId': offerId,
        'title': offer.title,
        'totalUsages': usageSnapshot.docs.length,
        'uniqueUsers': uniqueUsers.length,
        'totalDiscountGiven': totalDiscountGiven,
        'usageLimit': offer.usageLimit,
        'remainingUses': offer.usageLimit != null ? 
            (offer.usageLimit! - offer.usedCount) : null,
        'conversionRate': offer.usageLimit != null ? 
            (offer.usedCount / offer.usageLimit! * 100) : null,
      };
    } catch (e) {
      debugPrint('Error getting offer analytics: $e');
      return {'error': 'Failed to get analytics'};
    }
  }
  
  // Get user's offer history
  Future<List<Map<String, dynamic>>> getUserOfferHistory(String userId) async {
    try {
      QuerySnapshot snapshot = await _offerUsageCollection
          .where('userId', isEqualTo: userId)
          .orderBy('usedAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> history = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Offer? offer = await getOfferById(data['offerId']);
        
        if (offer != null) {
          history.add({
            'offer': offer,
            'discountAmount': data['discountAmount'],
            'usedAt': data['usedAt'],
          });
        }
      }
      
      return history;
    } catch (e) {
      debugPrint('Error getting user offer history: $e');
      return [];
    }
  }
  
  // Notification Methods (Legacy support)
  
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
      // Create offer using new model
      Offer offer = Offer(
        id: null,
        title: title,
        description: description,
        imageUrl: imageUrl,
        discountType: 'percentage',
        discountValue: double.tryParse(discountPercentage ?? '0') ?? 0,
        validFrom: DateTime.now().toIso8601String(),
        validTo: (validUntil ?? DateTime.now().add(const Duration(days: 30))).toIso8601String(),
        isActive: true,
        usageLimit: null,
        usedCount: 0,
        offerType: OfferType.promotional,
        targetServices: applicableServices ?? [],
        targetBranches: [],
        userEligibility: UserEligibility.all,
        requiresPromoCode: false,
        isStackable: false,
      );
      
      String offerId = await createOffer(offer);
      
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
}