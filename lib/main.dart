import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
