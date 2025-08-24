class StripeConfig {
  // PRODUCTION CONFIGURATION - Using live keys for production
  // Get your actual keys from Stripe Dashboard: https://dashboard.stripe.com/apikeys
  
  // Live publishable key (safe to use in client-side code)
  // Updated with live key for production use
  static const String publishableKey = 'pk_live_51PgnPgAVqidqxLYOI7TFPqsSOZvW8aOTJIKU1LyrEkWjw9T9QoBGGvLelMY1VyQsMU6XbggqZ179plGqno4sQJlE00Nrj0P81I';
  
  // Live secret key (should be kept secure)
  // WARNING: Replace with your actual live secret key from Stripe Dashboard
  // IMPORTANT: This should be handled by your backend server in production
  static const String secretKey = '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';
  
  // Production mode flag - Set to false for production with live keys
  static const bool isTestMode = false;
  
  // Supported currencies
  static const String defaultCurrency = 'aed';
  
  // Merchant display name
  static const String merchantName = 'Mirror Beauty Lounge';
  
  // Initialize Stripe configuration
  static bool get isConfigured {
    bool pubKeyValid = publishableKey.startsWith('pk_') &&
                      publishableKey != 'pk_test_YOUR_PUBLISHABLE_KEY_HERE' &&
                      publishableKey != 'pk_live_YOUR_PUBLISHABLE_KEY_HERE';
    
    bool secretKeyValid = secretKey.startsWith('sk_') &&
                         secretKey != 'sk_test_YOUR_SECRET_KEY_HERE' &&
                         secretKey != 'sk_live_YOUR_SECRET_KEY_HERE';
    
    // Validate key consistency (both should be test or both should be live)
    bool keysConsistent = (publishableKey.startsWith('pk_test_') && secretKey.startsWith('sk_test_')) ||
                         (publishableKey.startsWith('pk_live_') && secretKey.startsWith('sk_live_'));
    
    return pubKeyValid && secretKeyValid && keysConsistent;
  }
  
  // Get current environment keys with validation
  static String get currentPublishableKey {
    if (!isConfigured) {
      throw Exception(
        'Stripe keys not configured properly. Please update stripe_config.dart with your actual keys.\n'
        'Make sure both publishable and secret keys are from the same environment (test or live).\n'
        'Get your keys from: https://dashboard.stripe.com/apikeys'
      );
    }
    return publishableKey;
  }

  static String get currentSecretKey {
    if (!isConfigured) {
      throw Exception(
        'Stripe keys not configured properly. Please update stripe_config.dart with your actual keys.\n'
        'Make sure both publishable and secret keys are from the same environment (test or live).\n'
        'Get your keys from: https://dashboard.stripe.com/apikeys'
      );
    }
    return secretKey;
  }
  
  // Validation helper methods
  static String get environmentType {
    if (publishableKey.startsWith('pk_test_')) return 'test';
    if (publishableKey.startsWith('pk_live_')) return 'live';
    return 'unknown';
  }
  
  static bool get isLiveMode => environmentType == 'live' && !isTestMode;
  
  // Configuration status for debugging
  static Map<String, dynamic> get configStatus => {
    'isConfigured': isConfigured,
    'environmentType': environmentType,
    'isTestMode': isTestMode,
    'isLiveMode': isLiveMode,
    'publishableKeyValid': publishableKey.startsWith('pk_') && publishableKey.length > 20,
    'secretKeyValid': secretKey.startsWith('sk_') && secretKey.length > 20,
  };
}