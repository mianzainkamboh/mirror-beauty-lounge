import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firebase_service.dart';
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
    
    // Test booking creation
    await testBookingCreation();
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testBookingCreation() async {
  try {
    print('\n🧪 Testing booking creation...');
    
    // Create test home service booking
    final testHomeServiceBooking = Booking(
      userId: 'test_user_home_123',
      customerName: 'Test Home Customer',
      services: [
        BookingService(
          serviceId: 'service_home_1',
          serviceName: 'Home Haircut Service',
          category: 'Hair',
          duration: 45,
          price: 75.0,
          quantity: 1,
        ),
      ],
      bookingDate: DateTime.now().add(Duration(days: 1)),
      bookingTime: '2:00 PM',
      branch: 'Home Service',
      address: '123 Test Street, Test City, Test Area',
      totalPrice: 75.0,
      totalDuration: 45,
      status: 'upcoming',
      paymentMethod: 'cash',
      emailConfirmation: false,
      smsConfirmation: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    print('📝 Creating test home service booking...');
    String bookingId = await FirebaseService.createBooking(testHomeServiceBooking);
    print('✅ Home service booking created successfully with ID: $bookingId');

    // Test retrieval
    print('📖 Testing home service booking retrieval...');
    List<Booking> userBookings = await FirebaseService.getUserBookings('test_user_home_123');
    print('✅ Retrieved ${userBookings.length} bookings for test home user');

    // Test by status
    print('📊 Testing home service booking retrieval by status...');
    List<Booking> upcomingBookings = await FirebaseService.getUpcomingBookings('test_user_home_123');
    print('✅ Retrieved ${upcomingBookings.length} upcoming home service bookings');
    
    if (upcomingBookings.isNotEmpty) {
      final booking = upcomingBookings.first;
      print('📋 Home service booking details:');
      print('   - ID: ${booking.id}');
      print('   - Customer: ${booking.customerName}');
      print('   - Date: ${booking.bookingDate}');
      print('   - Status: ${booking.status}');
      print('   - Branch: ${booking.branch}');
      print('   - Address: ${booking.address ?? "No address"}');
      print('   - Services: ${booking.services.map((s) => s.serviceName).join(', ')}');
      
      // Test if this is properly identified as home service
      bool isHomeService = booking.address != null && booking.address!.isNotEmpty;
      print('   - Is Home Service: $isHomeService');
    }
    
    print('\n🎉 All tests completed successfully!');
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}