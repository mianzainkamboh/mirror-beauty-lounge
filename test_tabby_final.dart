import 'dart:convert';
import 'dart:io';

void main() async {
  print('Testing Tabby API with imageBase64 excluded...');
  
  // Simulate clean cart items (without imageBase64)
  final cleanCartItems = [
    {
      'id': '1',
      'name': 'Haircut',
      'price': 50.0,
      'duration': 30,
      'quantity': 1,
      'category': 'hair'
    },
    {
      'id': '2', 
      'name': 'Styling',
      'price': 30.0,
      'duration': 60,
      'quantity': 1,
      'category': 'hair'
    }
  ];
  
  // Format items like TabbyService.formatItems
  final tabbyItems = cleanCartItems.map((item) => {
    'title': item['name'] ?? 'Service',
    'description': 'Beauty service',
    'quantity': item['quantity'] ?? 1,
    'unit_price': double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
    'reference_id': item['id']?.toString() ?? '',
    'image_url': '',
    'product_url': '',
    'gender': 'unisex',
    'category': 'Beauty & Personal Care',
  }).toList();
  
  final totalAmount = cleanCartItems.fold<double>(0.0, (sum, item) => 
    sum + ((item['price'] as double? ?? 0.0) * (item['quantity'] as int? ?? 1)));
  
  final requestBody = {
    'amount': totalAmount,
    'currency': 'AED',
    'description': 'Beauty services booking',
    'buyer': {
      'phone': '+971501234567',
      'email': 'test@example.com',
      'name': 'Test User',
      'dob': '1990-01-01',
    },
    'shipping_address': {
      'city': 'Dubai',
      'address': 'Test Address',
      'zip': '12345',
    },
    'order': {
      'reference_id': 'MBL_test_${DateTime.now().millisecondsSinceEpoch}',
      'items': tabbyItems,
    },
    'buyer_history': {
      'registered_since': '2020-01-01T00:00:00Z',
      'loyalty_level': 0,
    },
    'order_history': [
      {
        'purchased_at': '2023-01-01T00:00:00Z',
        'amount': '100.00',
        'status': 'new',
      }
    ],
    'meta': {
      'order_id': 'MBL_test_${DateTime.now().millisecondsSinceEpoch}',
      'customer': 'Test User',
    },
    'lang': 'en',
    'merchant_code': 'MirrorsBeautyLounge',
    'merchant_urls': {
      'success': 'https://example.com/success',
      'cancel': 'https://example.com/cancel',
      'failure': 'https://example.com/failure',
    },
  };
  
  print('Request body created successfully');
  print('Total amount: ${requestBody['amount']}');
  print('Items count: ${tabbyItems.length}');
  
  // Test JSON encoding
  try {
    final jsonString = json.encode(requestBody);
    print('✅ JSON encoding successful');
    print('JSON length: ${jsonString.length}');
    
    // Make actual API call
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('https://api.tabby.ai/api/v2/checkout'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer pk_test_7d2ba58d-faf7-401d-b555-9c0c84a2941a');
    request.write(jsonString);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('\n=== API RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Body: $responseBody');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ SUCCESS: Tabby API call successful!');
    } else {
      print('❌ ERROR: API call failed');
    }
    
  } catch (e) {
    print('❌ JSON encoding failed: $e');
  }
}