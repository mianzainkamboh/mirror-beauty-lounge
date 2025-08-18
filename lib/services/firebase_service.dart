import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/service.dart';
import '../models/offer.dart';
import '../models/cart_item.dart';
import '../models/booking.dart';

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
          .get();
      
      List<Offer> offers = querySnapshot.docs
          .map((doc) => Offer.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt in the app instead of in the query
      offers.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return offers;
    } catch (e) {
      throw Exception('Error getting active offers: $e');
    }
  }

  // ==================== CART FUNCTIONS ====================

  // Get cart collection reference
  static CollectionReference get _cartCollection =>
      _firestore.collection('cart');

  // Add item to cart
  static Future<String> addToCart(CartItem cartItem) async {
    try {
      // Check if item already exists in cart for this user
      QuerySnapshot existingItems = await _cartCollection
          .where('userId', isEqualTo: cartItem.userId)
          .where('serviceId', isEqualTo: cartItem.serviceId)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Update quantity if item already exists
        DocumentSnapshot existingItem = existingItems.docs.first;
        CartItem existing = CartItem.fromFirestore(existingItem);
        CartItem updated = existing.copyWith(
          quantity: existing.quantity + cartItem.quantity,
          updatedAt: DateTime.now(),
        );
        await _cartCollection.doc(existingItem.id).update(updated.toMap());
        return existingItem.id;
      } else {
        // Add new item to cart
        DocumentReference docRef = await _cartCollection.add(cartItem.toMap());
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Update cart item quantity
  static Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      await _cartCollection.doc(cartItemId).update({
        'quantity': quantity,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartCollection.doc(cartItemId).delete();
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  // Get cart items for a user
  static Future<List<CartItem>> getCartItems(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      List<CartItem> cartItems = querySnapshot.docs
           .map((doc) => CartItem.fromFirestore(doc))
           .toList();
       
       // Sort by createdAt in the app instead of in the query
       cartItems.sort((a, b) {
         if (a.createdAt == null && b.createdAt == null) return 0;
         if (a.createdAt == null) return 1;
         if (b.createdAt == null) return -1;
         return b.createdAt!.compareTo(a.createdAt!);
       });
       
       return cartItems;
    } catch (e) {
      throw Exception('Error getting cart items: $e');
    }
  }

  // Listen to cart changes (real-time)
  static Stream<List<CartItem>> getCartItemsStream(String userId) {
    return _cartCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          List<CartItem> cartItems = snapshot.docs
              .map((doc) => CartItem.fromFirestore(doc))
              .toList();
          
          // Sort by createdAt in the app instead of in the query
          cartItems.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          
          return cartItems;
        });
  }

  // Clear all cart items for a user
  static Future<void> clearCart(String userId) async {
    try {
      QuerySnapshot cartItems = await _cartCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  // Get cart total for a user
  static Future<double> getCartTotal(String userId) async {
    try {
      final cartItems = await getCartItems(userId);
      return cartItems.fold<double>(0.0, (total, item) => total + item.totalPrice);
    } catch (e) {
      print('Error getting cart total: $e');
      return 0.0;
    }
  }

  // Get cart item count for a user
  static Future<int> getCartItemCount(String userId) async {
    try {
      final cartItems = await getCartItems(userId);
      return cartItems.fold<int>(0, (total, item) => total + item.quantity);
    } catch (e) {
      print('Error getting cart item count: $e');
      return 0;
    }
  }

  // ==================== BOOKING FUNCTIONS ====================

  // Get bookings collection reference
  static CollectionReference get _bookingsCollection =>
      _firestore.collection('bookings');

  // Create new booking
  static Future<String> createBooking(Booking booking) async {
    try {
      DocumentReference docRef = await _bookingsCollection.add(booking.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Update booking
  static Future<void> updateBooking(String bookingId, Booking booking) async {
    try {
      await _bookingsCollection.doc(bookingId).update(booking.toFirestore());
    } catch (e) {
      throw Exception('Error updating booking: $e');
    }
  }

  // Update booking status
  static Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }

  // Get bookings for a user
  static Future<List<Booking>> getUserBookings(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      List<Booking> bookings = querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt in the app instead of in the query
      bookings.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return bookings;
    } catch (e) {
      throw Exception('Error getting user bookings: $e');
    }
  }

  // Get bookings by status for a user
  static Future<List<Booking>> getUserBookingsByStatus(String userId, String status) async {
    try {
      QuerySnapshot querySnapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .get();
      
      List<Booking> bookings = querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt in the app instead of in the query
      bookings.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return bookings;
    } catch (e) {
      throw Exception('Error getting user bookings by status: $e');
    }
  }

  // Listen to user bookings changes (real-time)
  static Stream<List<Booking>> getUserBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          List<Booking> bookings = snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
          
          // Sort by createdAt in the app instead of in the query
          bookings.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          
          return bookings;
        });
  }

  // Get upcoming bookings for a user
  static Future<List<Booking>> getUpcomingBookings(String userId) async {
    try {
      return await getUserBookingsByStatus(userId, 'upcoming');
    } catch (e) {
      throw Exception('Error getting upcoming bookings: $e');
    }
  }

  // Get past bookings for a user
  static Future<List<Booking>> getPastBookings(String userId) async {
    try {
      return await getUserBookingsByStatus(userId, 'past');
    } catch (e) {
      throw Exception('Error getting past bookings: $e');
    }
  }

  // Update overdue bookings to past status
  static Future<void> updateOverdueBookings() async {
    try {
      QuerySnapshot upcomingBookings = await _bookingsCollection
          .where('status', isEqualTo: 'upcoming')
          .get();
      
      WriteBatch batch = _firestore.batch();
      DateTime now = DateTime.now();
      
      for (DocumentSnapshot doc in upcomingBookings.docs) {
        Booking booking = Booking.fromFirestore(doc);
        if (booking.isPastDue) {
          batch.update(doc.reference, {
            'status': 'past',
            'updatedAt': Timestamp.fromDate(now),
          });
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Error updating overdue bookings: $e');
    }
  }

  // Delete booking
  static Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).delete();
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }
}