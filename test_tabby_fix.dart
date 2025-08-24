import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Tabby API with numeric fields...');
  
  // Create minimal request body to test basic structure
  final requestBody = {
    'amount': '100.00', // Try as string format
    'currency': 'AED',
    'description': 'Test payment',
    'buyer': {
      'phone': '+971501234567',
      'email': 'test@example.com',
      'name': 'Test User',
      'dob': '1990-01-01',
    },
    'shipping_address': {
      'city': 'Dubai',
      'address': 'Dubai, UAE',
      'zip': '00000',
    },
    'order': {
      'updated_at': DateTime.now().toIso8601String(),
      'reference_id': 'test-order-123',
      'items': [
        {
          'title': 'Test Service',
          'description': 'Test beauty service',
          'quantity': 1,
          'unit_price': '100.00', // Try as string format
          'reference_id': 'service-1',
          'image_url': '',
          'product_url': '',
          'gender': 'unisex',
          'category': 'Beauty & Personal Care',
        }
      ],
    },
    'buyer_history': {
      'registered_since': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
      'loyalty_level': 0,
    },
    'order_history': {
      'registered_since': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
      'loyalty_level': 0,
      'wishlist_count': 0,
      'is_first_order': false,
      'is_guest_user': false,
    },
    'meta': {
      'order_id': 'test-order-123',
      'customer': 'test@example.com',
    },
    'lang': 'en',
    'merchant_code': '200200002364',
    'merchant_urls': {
      'success': 'https://mirrorsbeautylounge.com/success',
      'cancel': 'https://mirrorsbeautylounge.com/cancel',
      'failure': 'https://mirrorsbeautylounge.com/failure',
    },
  };
  
  print('Request body structure:');
  print(json.encode(requestBody));
  
  // Test the API call
  try {
    final response = await http.post(
      Uri.parse('https://api.tabby.ai/api/v2/checkout'),
      headers: {
        'Authorization': 'Bearer sk_test_7b21f833-a0ee-467e-8983-b7912051de7b',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );
    
    print('\nTabby API Response Status: ${response.statusCode}');
    print('Tabby API Response Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print('✅ Success! Checkout session created.');
      print('Response data keys: ${responseData.keys.toList()}');
    } else {
      print('❌ API Error: ${response.statusCode}');
      final errorData = json.decode(response.body);
      print('Error details: $errorData');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}