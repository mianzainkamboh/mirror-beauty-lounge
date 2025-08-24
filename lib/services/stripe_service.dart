import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart';
import 'package:http/http.dart' as http;
import '../config/stripe_config.dart';

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static bool _isInitialized = false;
  
  // Initialize Stripe with configuration
  static Future<void> init() async {
    try {
      // Validate configuration before initialization
      if (!StripeConfig.isConfigured) {
        final configStatus = StripeConfig.configStatus;
        debugPrint('Stripe configuration status: $configStatus');
        throw Exception(
          'Stripe configuration not set properly. Please update your Stripe keys in stripe_config.dart\n'
          'Configuration status: $configStatus\n'
          'See STRIPE_DEPLOYMENT_GUIDE.md for setup instructions.'
        );
      }
      
      // Log configuration details (without exposing keys)
      debugPrint('Initializing Stripe in ${StripeConfig.environmentType} mode');
      debugPrint('Test mode: ${StripeConfig.isTestMode}');
      
      Stripe.publishableKey = StripeConfig.currentPublishableKey;
      await Stripe.instance.applySettings();
      _isInitialized = true;
      
      debugPrint('Stripe initialized successfully in ${StripeConfig.environmentType} mode');
    } catch (e) {
      debugPrint('Failed to initialize Stripe: $e');
      _isInitialized = false;
      rethrow;
    }
  }
  
  // Check if Stripe is initialized
  static bool get isInitialized => _isInitialized;
  
  // Create payment intent on your backend or directly with Stripe
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate initialization
      if (!_isInitialized) {
        throw Exception('Stripe not initialized. Call StripeService.init() first.');
      }
      
      // Validate input parameters
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      
      if (currency.isEmpty) {
        throw Exception('Currency cannot be empty');
      }
      
      debugPrint('Creating payment intent for ${amount.toStringAsFixed(2)} $currency');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.currentSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).round().toString(), // Convert to cents
          'currency': currency.toLowerCase(),
          if (customerId != null) 'customer': customerId,
          if (metadata != null)
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value.toString())),
        },
      );
      
      debugPrint('Payment intent response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint('Payment intent created successfully: ${result['id']}');
        return result;
      } else {
        final errorBody = response.body;
        debugPrint('Payment intent creation failed: $errorBody');
        
        // Parse Stripe error for better user feedback
        try {
          final errorData = json.decode(errorBody);
          final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
          final errorType = errorData['error']?['type'] ?? 'api_error';
          throw Exception('Stripe API Error ($errorType): $errorMessage');
        } catch (parseError) {
          throw Exception('Failed to create payment intent: HTTP ${response.statusCode} - $errorBody');
        }
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      rethrow; // Re-throw to preserve error details
    }
  }
  
  // Process payment with payment sheet
  static Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String customerName,
    String? customerEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate initialization
      if (!_isInitialized) {
        await init(); // Try to initialize if not already done
      }
      
      // Validate input parameters
      if (amount <= 0) {
        return PaymentResult(
          success: false,
          error: 'Invalid amount: Amount must be greater than 0',
        );
      }
      
      if (customerName.trim().isEmpty) {
        return PaymentResult(
          success: false,
          error: 'Customer name is required',
        );
      }
      
      debugPrint('Processing payment for $customerName: ${amount.toStringAsFixed(2)} $currency');
      
      // Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: {
          'customer_name': customerName,
          if (customerEmail != null) 'customer_email': customerEmail,
          'environment': StripeConfig.environmentType,
          'test_mode': StripeConfig.isTestMode.toString(),
          ...?metadata,
        },
      );
      
      if (paymentIntent == null) {
        return PaymentResult(
          success: false,
          error: 'Failed to create payment intent. Please check your network connection and try again.',
        );
      }
      
      final clientSecret = paymentIntent['client_secret'];
      if (clientSecret == null || clientSecret.isEmpty) {
        return PaymentResult(
          success: false,
          error: 'Invalid payment intent: Missing client secret',
        );
      }
      
      debugPrint('Initializing payment sheet...');
      
      // Initialize payment sheet with additional safety checks
      try {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: StripeConfig.merchantName,
            customerEphemeralKeySecret: null, // Optional: for saved cards
            customerId: null, // Optional: for saved cards
            style: ThemeMode.system,
            allowsDelayedPaymentMethods: true,
            billingDetails: BillingDetails(
              name: customerName,
              email: customerEmail,
            ),
          ),
        );
        
        debugPrint('Payment sheet initialized successfully');
      } catch (initError) {
        debugPrint('Failed to initialize payment sheet: $initError');
        throw Exception('Failed to initialize payment sheet: ${initError.toString()}');
      }
      
      debugPrint('Presenting payment sheet...');
      
      // Present payment sheet with error handling
      try {
        await Stripe.instance.presentPaymentSheet();
        debugPrint('Payment sheet presented and completed successfully');
      } catch (presentError) {
        debugPrint('Failed to present payment sheet: $presentError');
        // Check if it's a user cancellation or actual error
        if (presentError.toString().contains('canceled') || 
            presentError.toString().contains('cancelled')) {
          throw StripeException(
            error: LocalizedErrorMessage(
              code: FailureCode.Canceled,
              localizedMessage: 'Payment was cancelled by user',
              message: 'Payment cancelled',
            ),
          );
        } else {
          throw Exception('Failed to present payment sheet: ${presentError.toString()}');
        }
      }
      
      debugPrint('Payment completed successfully');
      
      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntent['id'],
        message: 'Payment completed successfully',
      );
      
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.code} - ${e.error.localizedMessage}');
      
      // Handle specific Stripe error codes using string comparison
      String errorMessage;
      final errorCode = e.error.code?.toString().toLowerCase() ?? '';
      
      if (errorCode.contains('canceled') || errorCode.contains('cancelled')) {
        errorMessage = 'Payment was cancelled';
      } else if (errorCode.contains('failed') || errorCode.contains('payment_failed')) {
        errorMessage = 'Payment failed. Please try again.';
      } else if (errorCode.contains('invalid_request') || errorCode.contains('invalid')) {
        errorMessage = 'Invalid payment request. Please check your payment details.';
      } else if (errorCode.contains('api_connection') || errorCode.contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (errorCode.contains('authentication') || errorCode.contains('invalid_api_key')) {
        errorMessage = 'Authentication error. Please contact support.';
      } else if (errorCode.contains('card_declined')) {
        errorMessage = 'Your card was declined. Please try a different payment method.';
      } else if (errorCode.contains('insufficient_funds')) {
        errorMessage = 'Insufficient funds. Please try a different payment method.';
      } else if (errorCode.contains('expired_card')) {
        errorMessage = 'Your card has expired. Please try a different payment method.';
      } else {
        errorMessage = e.error.localizedMessage ?? 'Payment failed. Please try again.';
      }
      
      return PaymentResult(
        success: false,
        error: errorMessage,
      );
    } catch (e) {
      debugPrint('Payment error: $e');
      
      // Provide more specific error messages based on error type
      String errorMessage;
      if (e.toString().contains('Stripe configuration')) {
        errorMessage = 'Payment system configuration error. Please contact support.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('Invalid amount')) {
        errorMessage = 'Invalid payment amount. Please try again.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again or contact support.';
      }
      
      return PaymentResult(
        success: false,
        error: errorMessage,
      );
    }
  }
  
  // Confirm payment intent (if needed)
  static Future<bool> confirmPaymentIntent(String paymentIntentId) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentId,
      );
      return true;
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      return false;
    }
  }
  
  // Create customer (optional)
  static Future<Map<String, dynamic>?> createCustomer({
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      if (!_isInitialized) {
        throw Exception('Stripe not initialized. Call StripeService.init() first.');
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.currentSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create customer: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating customer: $e');
      return null;
    }
  }
}

// Payment result class
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? error;
  final String? message;
  
  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.error,
    this.message,
  });
  
  @override
  String toString() {
    return 'PaymentResult(success: $success, paymentIntentId: $paymentIntentId, error: $error, message: $message)';
  }
}