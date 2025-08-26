class TabbyConfig {
  // Tabby secret key for payment processing
  // Get this from your Tabby merchant dashboard
  
  // Public key for client-side integration
  static const String publicKey = 'xa';
  
  // Secret key (should be kept secure - consider using environment variables)
  static const String secretKey = 'x';
  
  // Merchant code
  static const String merchantCode = 'x'; // Add your actual merchant code
  
  // Merchant display name
  static const String merchantName = 'Mirror Beauty Lounge';
  
  // Supported currencies
  static const String defaultCurrency = 'AED';
  
  // Tabby API base URL
  static const String baseUrl = 'https://api.tabby.ai';
  
  // Test mode flag - Set to false for production
  static const bool isTestMode = true;
  
  // Minimum order amount for Tabby (in AED)
  static const double minimumOrderAmount = 50.0;
  
  // Maximum order amount for Tabby (in AED)
  static const double maximumOrderAmount = 10000.0;
  
  // Initialize Tabby configuration
  static bool get isConfigured {
    return publicKey.isNotEmpty && publicKey.startsWith('pk_') &&
           secretKey.isNotEmpty && secretKey.startsWith('sk_');
  }
  
  // Get current public key
  static String get currentPublicKey {
    if (!isConfigured) {
      throw Exception('Tabby keys not configured. Please update tabby_config.dart with your actual keys.');
    }
    return publicKey;
  }
  
  // Get current secret key
  static String get currentSecretKey {
    if (!isConfigured) {
      throw Exception('Tabby keys not configured. Please update tabby_config.dart with your actual keys.');
    }
    return secretKey;
  }
  
  // Check if order amount is within Tabby limits
  static bool isOrderAmountValid(double amount) {
    return amount >= minimumOrderAmount && amount <= maximumOrderAmount;
  }
  
  // Get Tabby checkout URL
  static String get checkoutUrl {
    return '$baseUrl/api/v2/checkout';
  }
  
  // Get payment options available
  static List<String> get paymentOptions {
    return [
      'Pay in 4 installments',
      'Pay in 3 installments',
      'Pay later'
    ];
  }
  
  // Get merchant code
  static String get currentMerchantCode => merchantCode;
}
