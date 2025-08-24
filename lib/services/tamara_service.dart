import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/tamara_config.dart';
import '../screens/webview_payment_screen.dart';

class TamaraService {
  static final TamaraService _instance = TamaraService._internal();
  factory TamaraService() => _instance;
  TamaraService._internal();

  // Initialize Tamara service
  static Future<void> init() async {
    if (!TamaraConfig.isConfigured) {
      throw Exception('Tamara is not configured. Please check tamara_config.dart');
    }
    print('Tamara service initialized with API token: ${TamaraConfig.apiToken.substring(0, 8)}...');
  }

  // Create Tamara checkout session
  Future<Map<String, dynamic>?> createCheckoutSession({
    required double amount,
    required String currency,
    required Map<String, dynamic> customerInfo,
    required List<Map<String, dynamic>> items,
    required String orderId,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      // Validate order amount
      if (!TamaraConfig.isOrderAmountValid(amount)) {
        throw Exception(
          'Order amount must be between ${TamaraConfig.minimumOrderAmount} and ${TamaraConfig.maximumOrderAmount} AED'
        );
      }

      // Validate amount is positive
      if (amount <= 0) {
        throw Exception('Payment amount must be positive. Current amount: $amount');
      }

      final requestBody = {
        'total_amount': {
          'amount': amount.toStringAsFixed(2),
          'currency': currency,
        },
        'shipping_amount': {
          'amount': '0.00',
          'currency': currency,
        },
        'tax_amount': {
          'amount': '0.00',
          'currency': currency,
        },
        'order_reference_id': orderId,
        'order_number': orderId,
        'items': items,
        'consumer': customerInfo,
        'country_code': 'AE',
        'payment_type': 'PAY_BY_INSTALMENTS',
        'instalments': 3,
        'locale': 'en_US',
        'merchant_url': {
          'success': successUrl ?? 'https://mirrorsbeautylounge.com/success',
          'failure': cancelUrl ?? 'https://mirrorsbeautylounge.com/failure',
          'cancel': cancelUrl ?? 'https://mirrorsbeautylounge.com/cancel',
          'notification': 'https://mirrorsbeautylounge.com/webhook',
        },
      };

      print('Tamara API Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('${TamaraConfig.checkoutUrl}'),
        headers: {
          'Authorization': 'Bearer ${TamaraConfig.apiToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Tamara API Response Status: ${response.statusCode}');
      print('Tamara API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final checkoutUrl = responseData['checkout_url'] ?? responseData['redirect_url'];
        if (checkoutUrl == null) {
          throw Exception('No checkout URL received from Tamara API');
        }
        return checkoutUrl;
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'No error details';
        throw Exception('Failed to create Tamara checkout session: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('Error creating Tamara checkout session: $e');
      return null;
    }
  }

  // Check payment status
  Future<Map<String, dynamic>?> getPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${TamaraConfig.baseUrl}/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer ${TamaraConfig.currentApiToken}',
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

  // Format customer info for Tamara
  static Map<String, dynamic> formatCustomerInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phone,
      'email': email,
    };
  }

  // Format items for Tamara
  static List<Map<String, dynamic>> formatItems(List<Map<String, dynamic>> cartItems) {
    return cartItems.map((item) {
      final price = (item['price'] ?? 0.0).toDouble();
      final quantity = (item['quantity'] ?? 1).toInt();
      final totalAmount = price * quantity;
      
      // Ensure positive amounts
      if (price <= 0) {
        throw Exception('Item price must be positive: ${item['name']} has price $price');
      }
      
      return {
        'name': item['name'] ?? 'Unknown Item',
        'type': 'Physical',
        'reference_id': item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'sku': item['sku'] ?? item['id']?.toString() ?? 'SKU-${DateTime.now().millisecondsSinceEpoch}',
        'quantity': quantity,
        'unit_price': {
          'amount': price.toStringAsFixed(2),
          'currency': 'AED',
        },
        'total_amount': {
          'amount': totalAmount.toStringAsFixed(2),
          'currency': 'AED',
        },
      };
    }).toList();
  }

  // Launch Tamara checkout with WebView
  Future<Map<String, dynamic>?> launchCheckout({
    required BuildContext context,
    required String checkoutUrl,
    String? successUrl,
    String? failureUrl,
    String? cancelUrl,
  }) async {
    try {
      print('Launching Tamara checkout: $checkoutUrl');
      
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => WebViewPaymentScreen(
            checkoutUrl: checkoutUrl,
            paymentProvider: 'tamara',
            successUrl: successUrl ?? 'https://example.com/success',
            failureUrl: failureUrl ?? 'https://example.com/failure',
            cancelUrl: cancelUrl ?? 'https://example.com/cancel',
          ),
        ),
      );
      
      return result;
    } catch (e) {
      print('Error launching Tamara checkout: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'provider': 'tamara',
      };
    }
  }

  // Dispose resources
  void dispose() {
    // Clean up any resources if needed
  }
}