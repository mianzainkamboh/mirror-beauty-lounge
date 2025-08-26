class TamaraConfig {
  // Tamara public key for payment processing
  // Get this from your Tamara merchant dashboard
  
  // Public key (safe to use in client-side code)
  static const String publicKey = 'x';
  
  // API token for server-side authentication (keep secure)
  static const String apiToken = 'x.x.x-x-xx-xx-x-x-x';
  
  // Merchant display name
  static const String merchantName = 'Mirror Beauty Lounge';
  
  // Supported currencies
  static const String defaultCurrency = 'AED';
  
  // Tamara API base URL
  static const String baseUrl = 'https://api-sandbox.tamara.co';
  
  // Test mode flag - Set to false for production
  static const bool isTestMode = true;
  
  // Minimum order amount for Tamara (in AED)
  static const double minimumOrderAmount = 100.0;
  
  // Maximum order amount for Tamara (in AED)
  static const double maximumOrderAmount = 10000.0;
  
  // Initialize Tamara configuration
  static bool get isConfigured {
    return publicKey.isNotEmpty && publicKey.length > 10 &&
           apiToken.isNotEmpty && apiToken.startsWith('eyJ');
  }
  
  // Get current public key
  static String get currentPublicKey {
    if (!isConfigured) {
      throw Exception('Tamara keys not configured. Please update tamara_config.dart with your actual keys.');
    }
    return publicKey;
  }
  
  // Get current API token
  static String get currentApiToken {
    if (!isConfigured) {
      throw Exception('Tamara keys not configured. Please update tamara_config.dart with your actual keys.');
    }
    return apiToken;
  }
  
  // Check if order amount is within Tamara limits
  static bool isOrderAmountValid(double amount) {
    return amount >= minimumOrderAmount && amount <= maximumOrderAmount;
  }
  
  // Get Tamara checkout URL
  static String get checkoutUrl {
    return '$baseUrl/checkout/session';
  }
  
  // Get payment options available
  static List<String> get paymentOptions {
    return [
      'Pay in 3 installments',
      'Pay in 4 installments',
      'Pay next month'
    ];
  }
}
