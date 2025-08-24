import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get totalPrice {
    return _items.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }

  int get totalDuration {
    return _items.fold(0, (total, item) => total + (item.duration * item.quantity));
  }

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  Future<void> loadCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _items = await FirebaseService.getCartItems(user.uid);
      }
    } catch (e) {
      print('Error loading cart items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(CartItem item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseService.addToCart(item);
        await loadCartItems(); // Reload to get updated list
      }
    } catch (e) {
      print('Error adding item to cart: $e');
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await FirebaseService.removeFromCart(itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        if (quantity <= 0) {
          await removeItem(itemId);
        } else {
          await FirebaseService.updateCartItemQuantity(itemId, quantity);
          _items[itemIndex] = CartItem(
            id: _items[itemIndex].id,
            userId: _items[itemIndex].userId,
            serviceId: _items[itemIndex].serviceId,
            serviceName: _items[itemIndex].serviceName,
            category: _items[itemIndex].category,
            price: _items[itemIndex].price,
            duration: _items[itemIndex].duration,
            description: _items[itemIndex].description,
            imageBase64: _items[itemIndex].imageBase64,
            quantity: quantity,
            createdAt: _items[itemIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Remove all items from Firebase
        for (final item in _items) {
          if (item.id != null) {
            await FirebaseService.removeFromCart(item.id!);
          }
        }
        _items.clear();
        notifyListeners();
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  void listenToCartChanges() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseService.getCartItemsStream(user.uid).listen((cartItems) {
        _items = cartItems;
        notifyListeners();
      });
    }
  }
}