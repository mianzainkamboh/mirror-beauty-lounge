import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';
import 'services/stripe_service.dart';
import 'services/tamara_service.dart';
import 'services/tabby_service.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with proper error handling
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase already initialized');
    }
    
    // Initialize notification services after Firebase
    await _initializeNotificationServices();
    
    // Initialize payment services
    await _initializeStripe();
    await _initializeTamara();
    await _initializeTabby();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue app execution even if Firebase fails
  }
  
  runApp(const MyApp());
}

// Initialize notification services
Future<void> _initializeNotificationServices() async {
  try {
    // Initialize local notifications
    await NotificationService().initialize();
    debugPrint('Local notifications initialized');
    
    // Initialize FCM
    await FCMService().initialize();
    debugPrint('FCM service initialized');
  } catch (e) {
    debugPrint('Error initializing notification services: $e');
  }
}

// Initialize Stripe payment service
Future<void> _initializeStripe() async {
  try {
    await StripeService.init();
    debugPrint('Stripe service initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Stripe: $e');
    // Continue app execution even if Stripe fails
    // User will see error when trying to make payments
  }
}

// Initialize Tamara payment service
Future<void> _initializeTamara() async {
  try {
    await TamaraService.init();
    debugPrint('Tamara service initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Tamara: $e');
    // Continue app execution even if Tamara fails
    // User will see error when trying to make payments
  }
}

// Initialize Tabby payment service
Future<void> _initializeTabby() async {
  try {
    await TabbyService.init();
    debugPrint('Tabby service initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Tabby: $e');
    // Continue app execution even if Tabby fails
    // User will see error when trying to make payments
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFFF8F8F), // #ff8f8f
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF8F8F),
            foregroundColor: Colors.white,
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
