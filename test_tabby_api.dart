import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/config/tabby_config.dart';
import 'lib/services/tabby_service.dart';

void main() async {
  // Test Tabby API integration
  print('Testing Tabby API integration...');
  
  try {
    // Initialize Tabby service
    await TabbyService.init();
    print('✅ Tabby service initialized successfully');
    
    // Create test data
    final buyer = {
      'phone': '+971501234567',
      'email': 'test@example.com',
      'name': 'Test Customer',
      'dob': '1990-01-01',
    };
    
    final shippingAddress = {
      'city': 'Dubai',
      'address': 'Dubai, UAE',
      'zip': '00000',
    };
    
    final order = {
      'tax_amount': '0.00',
      'shipping_amount': '0.00',
      'discount_amount': '0.00',
      'updated_at': DateTime.now().toIso8601String(),
      'reference_id': 'TEST_${DateTime.now().millisecondsSinceEpoch}',
      'items': [
        {
          'title': 'Test Service',
          'description': 'Beauty service test',
          'quantity': 1,
          'unit_price': '100.00',
          'discount_amount': '0.00',
          'reference_id': 'test_item_1',
          'image_url': '',
          'product_url': '',
          'gender': 'unisex',
          'category': 'Beauty & Personal Care',
        }
      ],
    };
    
    final buyerHistory = {
      'registered_since': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
      'loyalty_level': 0,
    };
    
    final orderHistory = {
      'registered_since': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
      'loyalty_level': 0,
      'wishlist_count': 0,
      'is_first_order': false,
      'is_guest_user': false,
    };
    
    final meta = {
      'order_id': 'TEST_ORDER_123',
      'customer': 'test@example.com',
    };
    
    // Test checkout session creation
    final tabbyService = TabbyService();
    final result = await tabbyService.createCheckoutSession(
      amount: 100.0,
      currency: 'AED',
      description: 'Test Payment',
      buyer: buyer,
      shippingAddress: shippingAddress,
      order: order,
      buyerHistory: buyerHistory,
      orderHistory: orderHistory,
      meta: meta,
    );
    
    if (result['success'] == true) {
      print('✅ Tabby checkout session created successfully!');
      print('Checkout URL: ${result['checkout_url']}');
    } else {
      print('❌ Tabby checkout session failed:');
      print('Error: ${result['error']}');
      print('Details: ${result['details']}');
    }
    
  } catch (e) {
    print('❌ Test failed with exception: $e');
  }
}