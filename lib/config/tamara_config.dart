class TamaraConfig {
  // Tamara public key for payment processing
  // Get this from your Tamara merchant dashboard
  
  // Public key (safe to use in client-side code)
  static const String publicKey = '62bca9cc-4ce8-4023-9ef5-6e3119ce446d';
  
  // API token for server-side authentication (keep secure)
  static const String apiToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhY2NvdW50SWQiOiJiN2Q3OGFlMC1kYWFiLTRmNDgtODU1OC0yY2Q1ZmVmZDY3NTYiLCJ0eXBlIjoibWVyY2hhbnQiLCJzYWx0IjoiZTVlNDA4ZTYtN2RlYi00ZTk3LWJlNTQtNDg2ZTdiMWQ1OTlkIiwicm9sZXMiOlsiUk9MRV9NRVJDSEFOVCJdLCJpc010bHMiOmZhbHNlLCJpYXQiOjE3NTU4NjMwMzMsImlzcyI6IlRhbWFyYSBQUCJ9.WiuvkQHhPO0M84bD6V-WOakTXqY45TigHPcpYe_P0zBaCcoTUe7clOcblJnS0YRCNrF7Ft36vsGy4sQursfNJCg5a2YNIN3eHUBV2W8G_0xzPzoJJV2oT09QE3sqE9TpDn55OfKNHBtbyHeLfNWsxxVIJ2XDWilaIg-_bEl7hQs_ohBaiy5vBkioWlLZk8ALuTCeqQ-7Jg3jM0Idy2nHfgtpzUEGXMivDCm_XmAJ26Qvs1mu-RCYi0Ah6GEXAfaQsQ6NTUEylfvN-iKIyMXIzzxmveZJggQY40IZOx2uf9fMOUMvcTietJ1tHBI4hd4P6e7wEwgukjTTrK-IxPev0w';
  
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