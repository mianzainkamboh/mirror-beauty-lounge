import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/service.dart';
import '../models/offer.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CATEGORIES FUNCTIONS ====================

  // Get categories collection reference
  static CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');

  // Add new category
  static Future<String> addCategory(Category category) async {
    try {
      DocumentReference docRef = await _categoriesCollection.add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  // Update category
  static Future<void> updateCategory(String categoryId, Category category) async {
    try {
      await _categoriesCollection.doc(categoryId).update(category.toFirestore());
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  // Delete category
  static Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  // Get all categories
  static Future<List<Category>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await _categoriesCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }

  // Listen to categories changes (real-time)
  static Stream<List<Category>> getCategoriesStream() {
    return _categoriesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  // ==================== SERVICES FUNCTIONS ====================

  // Get services collection reference
  static CollectionReference get _servicesCollection =>
      _firestore.collection('services');

  // Add new service
  static Future<String> addService(Service service) async {
    try {
      DocumentReference docRef = await _servicesCollection.add(service.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding service: $e');
    }
  }

  // Update service
  static Future<void> updateService(String serviceId, Service service) async {
    try {
      await _servicesCollection.doc(serviceId).update(service.toFirestore());
    } catch (e) {
      throw Exception('Error updating service: $e');
    }
  }

  // Delete service
  static Future<void> deleteService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).delete();
    } catch (e) {
      throw Exception('Error deleting service: $e');
    }
  }

  // Get all services
  static Future<List<Service>> getServices() async {
    try {
      QuerySnapshot querySnapshot = await _servicesCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting services: $e');
    }
  }

  // Listen to services changes (real-time)
  static Stream<List<Service>> getServicesStream() {
    return _servicesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Service.fromFirestore(doc))
            .toList());
  }

  // Get services by category
  static Future<List<Service>> getServicesByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _servicesCollection
          .where('category', isEqualTo: category)
          .get();
      
      List<Service> services = querySnapshot.docs
          .map((doc) => Service.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt in memory to avoid composite index requirement
      services.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return services;
    } catch (e) {
      throw Exception('Error getting services by category: $e');
    }
  }

  // ==================== OFFERS FUNCTIONS ====================

  // Get offers collection reference
  static CollectionReference get _offersCollection =>
      _firestore.collection('offers');

  // Add new offer
  static Future<String> addOffer(Offer offer) async {
    try {
      DocumentReference docRef = await _offersCollection.add(offer.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding offer: $e');
    }
  }

  // Update offer
  static Future<void> updateOffer(String offerId, Offer offer) async {
    try {
      await _offersCollection.doc(offerId).update(offer.toFirestore());
    } catch (e) {
      throw Exception('Error updating offer: $e');
    }
  }

  // Delete offer
  static Future<void> deleteOffer(String offerId) async {
    try {
      await _offersCollection.doc(offerId).delete();
    } catch (e) {
      throw Exception('Error deleting offer: $e');
    }
  }

  // Get all offers
  static Future<List<Offer>> getOffers() async {
    try {
      QuerySnapshot querySnapshot = await _offersCollection
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Offer.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting offers: $e');
    }
  }

  // Listen to offers changes (real-time)
  static Stream<List<Offer>> getOffersStream() {
    return _offersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Offer.fromFirestore(doc))
            .toList());
  }

  // Get active offers only
  static Future<List<Offer>> getActiveOffers() async {
    try {
      QuerySnapshot querySnapshot = await _offersCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Offer.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting active offers: $e');
    }
  }
}