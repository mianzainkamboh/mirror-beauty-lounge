# Stripe Payment Configuration Guide

## Overview
This guide explains how to properly configure Stripe payments for both development and production environments.

## Current Issue Fixed
The app was showing "unexpected error" because:
- Live publishable key was mixed with test secret key placeholder
- Configuration validation was failing
- Key environment mismatch caused authentication errors

## Development Setup

### 1. Get Your Test Keys
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/apikeys)
2. Make sure you're in **Test mode** (toggle in the left sidebar)
3. Copy your **Publishable key** (starts with `pk_test_`)
4. Copy your **Secret key** (starts with `sk_test_`)

### 2. Update Configuration
Edit `lib/config/stripe_config.dart`:

```dart
class StripeConfig {
  // Replace with your actual TEST keys
  static const String publishableKey = 'pk_test_YOUR_ACTUAL_TEST_KEY_HERE';
  static const String secretKey = 'sk_test_YOUR_ACTUAL_TEST_KEY_HERE';
  
  // Keep as true for development
  static const bool isTestMode = true;
  
  // ... rest of the configuration
}
```

### 3. Test the Payment Flow
- Use test card numbers from [Stripe Testing](https://stripe.com/docs/testing)
- Successful test card: `4242 4242 4242 4242`
- Any future expiry date and any 3-digit CVC

## Production Deployment

### 1. Get Your Live Keys
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/apikeys)
2. Switch to **Live mode** (toggle in the left sidebar)
3. Copy your **Live Publishable key** (starts with `pk_live_`)
4. Copy your **Live Secret key** (starts with `sk_live_`)

### 2. Update for Production
**IMPORTANT**: Never commit live keys to version control!

#### Option A: Environment Variables (Recommended)
Create environment-specific configuration:

```dart
class StripeConfig {
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_YOUR_TEST_KEY_HERE'
  );
  
  static const String secretKey = String.fromEnvironment(
    'STRIPE_SECRET_KEY',
    defaultValue: 'sk_test_YOUR_TEST_KEY_HERE'
  );
  
  static const bool isTestMode = bool.fromEnvironment(
    'STRIPE_TEST_MODE',
    defaultValue: true
  );
}
```

#### Option B: Direct Configuration (Less Secure)
Update the configuration file directly:

```dart
static const String publishableKey = 'pk_live_YOUR_ACTUAL_LIVE_KEY_HERE';
static const String secretKey = 'sk_live_YOUR_ACTUAL_LIVE_KEY_HERE';
static const bool isTestMode = false;
```

### 3. Build Commands

#### For Environment Variables:
```bash
# Development build
flutter build apk

# Production build
flutter build apk --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_your_key --dart-define=STRIPE_SECRET_KEY=sk_live_your_key --dart-define=STRIPE_TEST_MODE=false
```

## Security Best Practices

1. **Never commit live keys to version control**
2. **Use environment variables for production**
3. **Keep secret keys secure** - consider backend processing
4. **Regularly rotate your keys**
5. **Monitor your Stripe dashboard** for suspicious activity

## Troubleshooting

### "Unexpected Error" Issues
1. Check that both keys are from the same environment (both test or both live)
2. Verify keys are not placeholder values
3. Ensure `isTestMode` matches your key environment
4. Check network connectivity

### Validation Errors
- Use the `StripeConfig.configStatus` getter to debug configuration
- Check console logs for detailed error messages

### Test Card Failures
- Ensure you're using valid test card numbers
- Check that you're in test mode with test keys

## Support
- [Stripe Documentation](https://stripe.com/docs)
- [Stripe Testing Guide](https://stripe.com/docs/testing)
- [Flutter Stripe Plugin](https://pub.dev/packages/flutter_stripe)

## Configuration Status Check
You can check your current configuration status by calling:
```dart
print(StripeConfig.configStatus);
```

This will show you the current state of your Stripe configuration and help identify any issues.