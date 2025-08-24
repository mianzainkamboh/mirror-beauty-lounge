import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferType {
  promotional,
  referral,
  newCustomer,
  seasonal,
  loyalty
}

enum UserEligibility {
  all,
  newCustomers,
  existingCustomers,
  vipCustomers
}

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
  final String? imageUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  
  // New fields for enhanced offers system
  final OfferType offerType;
  final String? promoCode;
  final String? referralCode;
  final List<String> targetServices; // Service IDs that this offer applies to
  final List<String> targetBranches; // Branch IDs that this offer applies to
  final double? minimumOrderAmount;
  final double? maximumDiscountAmount;
  final UserEligibility userEligibility;
  final bool requiresPromoCode;
  final int? maxUsesPerUser;
  final bool isStackable; // Can be combined with other offers
  final String? termsAndConditions;

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
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    // New enhanced fields
    this.offerType = OfferType.promotional,
    this.promoCode,
    this.referralCode,
    this.targetServices = const [],
    this.targetBranches = const [],
    this.minimumOrderAmount,
    this.maximumDiscountAmount,
    this.userEligibility = UserEligibility.all,
    this.requiresPromoCode = false,
    this.maxUsesPerUser,
    this.isStackable = false,
    this.termsAndConditions,
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
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      // Enhanced fields
      offerType: _parseOfferType(data['offerType']),
      promoCode: data['promoCode'],
      referralCode: data['referralCode'],
      targetServices: List<String>.from(data['targetServices'] ?? data['selectedServices'] ?? []),
      targetBranches: List<String>.from(data['targetBranches'] ?? data['selectedBranches'] ?? []),
      minimumOrderAmount: data['minimumOrderAmount']?.toDouble(),
      maximumDiscountAmount: data['maximumDiscountAmount']?.toDouble(),
      userEligibility: _parseUserEligibility(data['userEligibility']),
      requiresPromoCode: data['requiresPromoCode'] ?? false,
      maxUsesPerUser: data['maxUsesPerUser'],
      isStackable: data['isStackable'] ?? false,
      termsAndConditions: data['termsAndConditions'],
    );
  }

  // Helper method to parse OfferType from string
  static OfferType _parseOfferType(String? type) {
    switch (type) {
      case 'promotional':
        return OfferType.promotional;
      case 'referral':
        return OfferType.referral;
      case 'newCustomer':
        return OfferType.newCustomer;
      case 'seasonal':
        return OfferType.seasonal;
      case 'loyalty':
        return OfferType.loyalty;
      default:
        return OfferType.promotional;
    }
  }

  // Helper method to parse UserEligibility from string
  static UserEligibility _parseUserEligibility(String? eligibility) {
    switch (eligibility) {
      case 'all':
        return UserEligibility.all;
      case 'newCustomers':
        return UserEligibility.newCustomers;
      case 'existingCustomers':
        return UserEligibility.existingCustomers;
      case 'vipCustomers':
        return UserEligibility.vipCustomers;
      default:
        return UserEligibility.all;
    }
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
      // Enhanced fields
      'offerType': offerType.name,
      'targetServices': targetServices,
      'targetBranches': targetBranches,
      'userEligibility': userEligibility.name,
      'requiresPromoCode': requiresPromoCode,
      'isStackable': isStackable,
    };
    
    // Only include optional fields if they are not null
    if (usageLimit != null) {
      data['usageLimit'] = usageLimit;
    }
    if (imageBase64 != null) {
      data['imageBase64'] = imageBase64;
    }
    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }
    if (promoCode != null) {
      data['promoCode'] = promoCode;
    }
    if (referralCode != null) {
      data['referralCode'] = referralCode;
    }
    if (minimumOrderAmount != null) {
      data['minimumOrderAmount'] = minimumOrderAmount;
    }
    if (maximumDiscountAmount != null) {
      data['maximumDiscountAmount'] = maximumDiscountAmount;
    }
    if (maxUsesPerUser != null) {
      data['maxUsesPerUser'] = maxUsesPerUser;
    }
    if (termsAndConditions != null) {
      data['termsAndConditions'] = termsAndConditions;
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
    String? imageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    // Enhanced fields
    OfferType? offerType,
    String? promoCode,
    String? referralCode,
    List<String>? targetServices,
    List<String>? targetBranches,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    UserEligibility? userEligibility,
    bool? requiresPromoCode,
    int? maxUsesPerUser,
    bool? isStackable,
    String? termsAndConditions,
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
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Enhanced fields
      offerType: offerType ?? this.offerType,
      promoCode: promoCode ?? this.promoCode,
      referralCode: referralCode ?? this.referralCode,
      targetServices: targetServices ?? this.targetServices,
      targetBranches: targetBranches ?? this.targetBranches,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscountAmount: maximumDiscountAmount ?? this.maximumDiscountAmount,
      userEligibility: userEligibility ?? this.userEligibility,
      requiresPromoCode: requiresPromoCode ?? this.requiresPromoCode,
      maxUsesPerUser: maxUsesPerUser ?? this.maxUsesPerUser,
      isStackable: isStackable ?? this.isStackable,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
    );
  }

  // Helper methods for offer validation and application
  bool isValidForService(String serviceId) {
    return targetServices.isEmpty || targetServices.contains(serviceId);
  }

  bool isValidForBranch(String branchId) {
    return targetBranches.isEmpty || targetBranches.contains(branchId);
  }

  bool isValidForUser(bool isNewCustomer, bool isVipCustomer) {
    switch (userEligibility) {
      case UserEligibility.all:
        return true;
      case UserEligibility.newCustomers:
        return isNewCustomer;
      case UserEligibility.existingCustomers:
        return !isNewCustomer;
      case UserEligibility.vipCustomers:
        return isVipCustomer;
    }
  }

  bool isValidForAmount(double orderAmount) {
    return minimumOrderAmount == null || orderAmount >= minimumOrderAmount!;
  }

  double calculateDiscount(double orderAmount) {
    double discount = 0;
    
    if (discountType == 'percentage') {
      discount = orderAmount * (discountValue / 100);
    } else {
      discount = discountValue;
    }
    
    // Apply maximum discount limit if set
    if (maximumDiscountAmount != null && discount > maximumDiscountAmount!) {
      discount = maximumDiscountAmount!;
    }
    
    return discount;
  }
}