import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/tabby_config.dart';
import '../screens/webview_payment_screen.dart';

class TabbyService {
  static final TabbyService _instance = TabbyService._internal();
  factory TabbyService() => _instance;
  TabbyService._internal();

  // Initialize Tabby service
  static Future<void> init() async {
    if (!TabbyConfig.isConfigured) {
      throw Exception('Tabby is not configured. Please check tabby_config.dart');
    }
    print('Tabby service initialized with secret key: ${TabbyConfig.secretKey.substring(0, 8)}...');
  }

  // Create Tabby checkout session
  Future<Map<String, dynamic>> createCheckoutSession({
    required double amount,
    required String currency,
    required String description,
    required Map<String, dynamic> buyer,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> order,
    required Map<String, dynamic> buyerHistory,
    required Map<String, dynamic> orderHistory,
    required Map<String, dynamic> meta,
  }) async {
    try {
      // Validate amount is positive
      if (amount <= 0) {
        throw Exception('Payment amount must be positive. Current amount: $amount');
      }

      // Correct Tabby API request structure - flat structure without 'payment' wrapper
      final requestBody = {
        'amount': amount.toStringAsFixed(2), // Convert to string with 2 decimal places
        'currency': currency,
        'description': description,
        'buyer': buyer,
        'shipping_address': shippingAddress,
        'order': order,
        'buyer_history': buyerHistory,
        'order_history': orderHistory,
        'meta': meta,
        'lang': 'en',
        'merchant_code': TabbyConfig.currentMerchantCode,
        'merchant_urls': {
          'success': 'https://mirrorsbeautylounge.com/success',
          'cancel': 'https://mirrorsbeautylounge.com/cancel',
          'failure': 'https://mirrorsbeautylounge.com/failure',
        },
      };

      print('Tabby API Request Body: ${json.encode(requestBody)}');

      // Debug: Log request body with detailed inspection
      print('Creating Tabby checkout session...');
      print('Amount: ${requestBody['amount']}, Currency: ${requestBody['currency']}');

      final response = await http.post(
        Uri.parse(TabbyConfig.checkoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${TabbyConfig.currentSecretKey}',
        },
        body: json.encode(requestBody),
      );

      print('Tabby API Response Status: ${response.statusCode}');
      print('Tabby API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Tabby API Success Response: ${json.encode(responseData)}');
        
        // Extract checkout URL from response - try multiple possible paths
        String? checkoutUrl;
        
        // Try different possible response structures
        if (responseData['configuration'] != null &&
            responseData['configuration']['available_products'] != null &&
            responseData['configuration']['available_products']['installments'] != null &&
            responseData['configuration']['available_products']['installments'].isNotEmpty) {
          checkoutUrl = responseData['configuration']['available_products']['installments'][0]['web_url'];
        } else if (responseData['web_url'] != null) {
          checkoutUrl = responseData['web_url'];
        } else if (responseData['checkout_url'] != null) {
          checkoutUrl = responseData['checkout_url'];
        } else if (responseData['payment'] != null && responseData['payment']['web_url'] != null) {
          checkoutUrl = responseData['payment']['web_url'];
        }
        
        print('Extracted checkout URL: $checkoutUrl');
        
        return {
          'success': true,
          'data': responseData,
          'checkout_url': checkoutUrl,
        };
      } else {
        String errorBody = response.body;
        Map<String, dynamic>? errorData;
        
        try {
          errorData = json.decode(errorBody);
        } catch (e) {
          print('Failed to parse error response: $e');
        }
        
        print('Tabby API Error: ${errorData ?? errorBody}');
        return {
          'success': false,
          'error': errorData?['message'] ?? errorData?['error'] ?? 'API request failed with status ${response.statusCode}',
          'details': errorData ?? {'raw_response': errorBody},
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception in createCheckoutSession: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Check payment status
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('${TabbyConfig.baseUrl}/api/v2/payments/$paymentId'),
        headers: {
          'Authorization': 'Bearer ${TabbyConfig.currentSecretKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get payment status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting payment status: $e');
      return null;
    }
  }

  // Format customer info for Tabby
  static Map<String, dynamic> formatCustomerInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    String? city,
  }) {
    return {
      'phone': phone,
      'email': email,
      'name': '$firstName $lastName',
      'dob': '1990-01-01', // Default DOB, should be collected from user
    };
  }

  // Format items for Tabby
  static List<Map<String, dynamic>> formatItems(List<Map<String, dynamic>> cartItems) {
    return cartItems.map((item) {
      final price = (item['price'] ?? 0.0).toDouble();
      final quantity = (item['quantity'] ?? 1).toInt();
      
      // Ensure positive amounts
      if (price <= 0) {
        throw Exception('Item price must be positive: ${item['name']} has price $price');
      }
      
      return {
        'title': item['name'] ?? 'Service',
        'description': item['description'] ?? 'Beauty service',
        'quantity': quantity,
        'unit_price': price.toStringAsFixed(2),
        'discount_amount': '0.00',
        'reference_id': item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'image_url': item['image'] ?? '',
        'product_url': item['url'] ?? '',
        'gender': 'Female',
        'category': item['category'] ?? 'Beauty',
      };
    }).toList();
  }

  // Launch Tabby checkout with WebView
  Future<Map<String, dynamic>?> launchCheckout({
    required BuildContext context,
    required String checkoutUrl,
    String? successUrl,
    String? failureUrl,
    String? cancelUrl,
  }) async {
    try {
      print('Launching Tabby checkout: $checkoutUrl');
      
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => WebViewPaymentScreen(
            checkoutUrl: checkoutUrl,
            paymentProvider: 'tabby',
            successUrl: successUrl ?? 'https://example.com/success',
            failureUrl: failureUrl ?? 'https://example.com/failure',
            cancelUrl: cancelUrl ?? 'https://example.com/cancel',
          ),
        ),
      );
      
      return result;
    } catch (e) {
      print('Error launching Tabby checkout: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'provider': 'tabby',
      };
    }
  }

  // Capture payment (for authorized payments)
  Future<Map<String, dynamic>?> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      final requestBody = {
        'amount': amount.toString(),
      };

      final response = await http.post(
        Uri.parse('${TabbyConfig.baseUrl}/api/v2/payments/$paymentId/captures'),
        headers: {
          'Authorization': 'Bearer ${TabbyConfig.currentSecretKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('Failed to capture payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error capturing payment: $e');
      return null;
    }
  }

  // Refund payment
  Future<Map<String, dynamic>?> refundPayment({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final requestBody = {
        'amount': amount.toString(),
        'comment': reason ?? 'Refund requested by customer',
      };

      final response = await http.post(
        Uri.parse('${TabbyConfig.baseUrl}/api/v2/payments/$paymentId/refunds'),
        headers: {
          'Authorization': 'Bearer ${TabbyConfig.currentSecretKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('Failed to refund payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error refunding payment: $e');
      return null;
    }
  }

  // Dispose resources
  void dispose() {
    // Clean up any resources if needed
  }
}

// Payment result class for Tabby
class TabbyPaymentResult {
  final bool success;
  final String? paymentId;
  final String? checkoutUrl;
  final String? error;
  final String? message;
  
  TabbyPaymentResult({
    required this.success,
    this.paymentId,
    this.checkoutUrl,
    this.error,
    this.message,
  });
}