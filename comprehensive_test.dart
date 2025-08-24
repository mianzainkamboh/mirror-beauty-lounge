import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firebase_service.dart';
import 'lib/services/notification_service.dart';
import 'lib/services/auth_service.dart';
import 'lib/models/booking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    }
    
    // Initialize notification service
    await NotificationService().initialize();
    print('✅ Notification service initialized');
    
    // Run comprehensive tests
    await runComprehensiveTests();
    
  } catch (e) {
    print('❌ Initialization error: $e');
  }
}

Future<void> runComprehensiveTests() async {
  print('\n🧪 Starting Comprehensive Tests...');
  print('=' * 50);
  
  try {
    // Test 1: Check current user authentication
    await testUserAuthentication();
    
    // Test 2: Create a home service booking
    String? bookingId = await testHomeServiceBookingCreation();
    
    if (bookingId != null) {
      // Test 3: Verify notification sending
      await testNotificationSending(bookingId);
      
      // Test 4: Verify booking appears in history
      await testBookingHistoryRetrieval(bookingId);
      
      // Test 5: Check home service specific fields
      await testHomeServiceFields(bookingId);
    }
    
    print('\n✅ All tests completed!');
    
  } catch (e) {
    print('❌ Test execution error: $e');
  }
}

Future<void> testUserAuthentication() async {
  print('\n📋 Test 1: User Authentication');
  print('-' * 30);
  
  try {
    final authService = AuthService();
    final user = authService.currentUser;
    
    if (user != null) {
      print('✅ User authenticated: ${user.uid}');
      print('   Email: ${user.email}');
    } else {
      print('❌ No authenticated user found');
      throw Exception('User authentication required for testing');
    }
  } catch (e) {
    print('❌ Authentication test failed: $e');
    rethrow;
  }
}

Future<String?> testHomeServiceBookingCreation() async {
  print('\n📋 Test 2: Home Service Booking Creation');
  print('-' * 40);
  
  try {
    final authService = AuthService();
    final user = authService.currentUser!;
    
    // Create a test home service booking
    final booking = Booking(
      userId: user.uid,
      customerName: 'Test Customer',
      services: [
        BookingService(
          serviceId: 'test_service_1',
          serviceName: 'Test Home Service',
          category: 'Beauty',
          duration: 60,
          price: 100.0,
          quantity: 1,
        ),
      ],
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      bookingTime: '14:00',
      branch: 'Home Service', // This is key for home service
      address: '123 Test Street, Test City', // This should be set for home service
      totalPrice: 100.0,
      totalDuration: 60,
      status: 'upcoming',
      paymentMethod: 'cash',
      emailConfirmation: false,
      smsConfirmation: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    print('📝 Creating booking with:');
    print('   Branch: ${booking.branch}');
    print('   Address: ${booking.address}');
    print('   Customer: ${booking.customerName}');
    print('   Service: ${booking.services.first.serviceName}');
    
    // Save booking to Firebase
    String bookingId = await FirebaseService.createBooking(booking);
    print('✅ Home service booking created with ID: $bookingId');
    
    return bookingId;
    
  } catch (e) {
    print('❌ Home service booking creation failed: $e');
    return null;
  }
}

Future<void> testNotificationSending(String bookingId) async {
  print('\n📋 Test 3: Notification Sending');
  print('-' * 30);
  
  try {
    // Retrieve the booking we just created
    final authService = AuthService();
    final user = authService.currentUser!;
    
    // Get user bookings to find our test booking
    List<Booking> bookings = await FirebaseService.getUserBookings(user.uid);
    Booking? testBooking;
    try {
      testBooking = bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      throw Exception('Test booking not found');
    }
    
    print('📝 Sending notification for booking: ${testBooking.id}');
    
    // Send booking confirmation notification
    await NotificationService().sendBookingConfirmationNotification(testBooking);
    print('✅ Notification sent successfully');
    
    // Check pending notifications
    final pendingNotifications = await NotificationService().getPendingNotifications();
    print('📱 Pending notifications count: ${pendingNotifications.length}');
    
    for (var notification in pendingNotifications) {
      print('   - ID: ${notification.id}, Title: ${notification.title}');
    }
    
  } catch (e) {
    print('❌ Notification sending test failed: $e');
  }
}

Future<void> testBookingHistoryRetrieval(String bookingId) async {
  print('\n📋 Test 4: Booking History Retrieval');
  print('-' * 35);
  
  try {
    final authService = AuthService();
    final user = authService.currentUser!;
    
    // Test upcoming bookings
    List<Booking> upcomingBookings = await FirebaseService.getUpcomingBookings(user.uid);
    print('📊 Total upcoming bookings: ${upcomingBookings.length}');
    
    // Look for our test booking
    Booking? testBooking;
    try {
      testBooking = upcomingBookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      testBooking = null;
    }
    
    if (testBooking != null) {
      print('✅ Test booking found in upcoming bookings');
      print('   ID: ${testBooking.id}');
      print('   Branch: ${testBooking.branch}');
      print('   Address: ${testBooking.address}');
    } else {
      print('❌ Test booking NOT found in upcoming bookings');
      
      // Check all user bookings
      List<Booking> allBookings = await FirebaseService.getUserBookings(user.uid);
      try {
        testBooking = allBookings.firstWhere((b) => b.id == bookingId);
      } catch (e) {
        testBooking = null;
      }
      
      if (testBooking != null) {
        print('⚠️  Test booking found in all bookings but not in upcoming');
        print('   Status: ${testBooking.status}');
        print('   Date: ${testBooking.bookingDate}');
      } else {
        print('❌ Test booking not found anywhere!');
      }
    }
    
    // Check for home service bookings specifically
    List<Booking> homeServiceBookings = upcomingBookings
        .where((b) => b.branch == 'Home Service' || (b.address != null && b.address!.isNotEmpty))
        .toList();
    
    print('🏠 Home service bookings found: ${homeServiceBookings.length}');
    for (var booking in homeServiceBookings) {
      print('   - ${booking.customerName} at ${booking.address}');
    }
    
  } catch (e) {
    print('❌ Booking history retrieval test failed: $e');
  }
}

Future<void> testHomeServiceFields(String bookingId) async {
  print('\n📋 Test 5: Home Service Fields Verification');
  print('-' * 40);
  
  try {
    final authService = AuthService();
    final user = authService.currentUser!;
    
    // Get all user bookings
    List<Booking> allBookings = await FirebaseService.getUserBookings(user.uid);
    Booking? testBooking;
    try {
      testBooking = allBookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      testBooking = null;
    }
    
    if (testBooking != null) {
      print('📝 Verifying home service fields:');
      print('   Branch: "${testBooking.branch}"');
      print('   Address: "${testBooking.address}"');
      print('   Is Home Service: ${testBooking.branch == "Home Service"}');
      print('   Has Address: ${testBooking.address != null && testBooking.address!.isNotEmpty}');
      
      // Check if it meets home service criteria
      bool isHomeService = testBooking.branch == 'Home Service' || 
                          (testBooking.address != null && testBooking.address!.isNotEmpty);
      
      if (isHomeService) {
        print('✅ Booking correctly identified as home service');
      } else {
        print('❌ Booking NOT identified as home service');
      }
      
      // Test the filtering logic used in booking history screen
      print('\n🔍 Testing booking history filtering logic:');
      
      // Simulate the filtering that happens in booking_history_screen.dart
      List<Booking> filteredBookings = allBookings.where((booking) {
        // This should match the logic in the booking history screen
        return booking.status == 'upcoming';
      }).toList();
      
      bool foundInFiltered = filteredBookings.any((b) => b.id == bookingId);
      print('   Found in filtered upcoming: $foundInFiltered');
      
      if (!foundInFiltered) {
        print('   Booking status: ${testBooking.status}');
        print('   Booking date: ${testBooking.bookingDate}');
        print('   Current date: ${DateTime.now()}');
        print('   Is future date: ${testBooking.bookingDate.isAfter(DateTime.now())}');
      }
      
    } else {
      print('❌ Test booking not found for field verification');
    }
    
  } catch (e) {
    print('❌ Home service fields verification failed: $e');
  }
}

class ComprehensiveTestApp extends StatelessWidget {
  const ComprehensiveTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Comprehensive Test'),
        ),
        body: const Center(
          child: Text(
            'Check console for test results',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}