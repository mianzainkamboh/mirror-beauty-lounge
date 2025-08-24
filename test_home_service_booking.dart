import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/services/firebase_service.dart';
import 'lib/models/booking.dart';
import 'lib/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
    
    await testHomeServiceBookingFlow();
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testHomeServiceBookingFlow() async {
  try {
    print('\n🧪 Testing Home Service Booking Flow...');
    
    // Test 1: Create a home service booking
    print('\n📝 Test 1: Creating home service booking...');
    final testBooking = Booking(
      id: '',
      userId: 'test_user_home_service_123',
      customerName: 'Test Home Service Customer',
      services: [
        BookingService(
          serviceId: 'test_service_1',
          serviceName: 'Home Facial Treatment',
          category: 'Facial',
          duration: 60,
          price: 150.0,
          quantity: 1,
        ),
      ],
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      bookingTime: '14:00',
      branch: 'Home Service',
      address: '123 Test Street, Test City, Test Area',
      totalPrice: 150.0,
      totalDuration: 60,
      status: 'upcoming',
      paymentMethod: 'Cash',
      emailConfirmation: false,
      smsConfirmation: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    String bookingId = await FirebaseService.createBooking(testBooking);
    print('✅ Home service booking created with ID: $bookingId');
    print('📍 Address: ${testBooking.address}');
    print('🏢 Branch: ${testBooking.branch}');
    
    // Test 2: Retrieve the booking
    print('\n📋 Test 2: Retrieving home service bookings...');
    List<Booking> upcomingBookings = await FirebaseService.getUpcomingBookings('test_user_home_service_123');
    print('📊 Retrieved ${upcomingBookings.length} upcoming bookings');
    
    if (upcomingBookings.isNotEmpty) {
      final retrievedBooking = upcomingBookings.first;
      print('✅ Home service booking retrieved successfully:');
      print('   - ID: ${retrievedBooking.id}');
      print('   - Customer: ${retrievedBooking.customerName}');
      print('   - Branch: ${retrievedBooking.branch}');
      print('   - Address: ${retrievedBooking.address}');
      print('   - Status: ${retrievedBooking.status}');
      print('   - Services: ${retrievedBooking.services.map((s) => s.serviceName).join(', ')}');
      
      // Test 3: Test notification for home service booking
      print('\n🔔 Test 3: Testing notification for home service booking...');
      try {
        await NotificationService().initialize();
        await NotificationService().sendBookingConfirmationNotification(retrievedBooking);
        print('✅ Notification sent successfully for home service booking');
      } catch (e) {
        print('❌ Notification test failed: $e');
      }
    } else {
      print('❌ No home service bookings found after creation');
    }
    
    // Test 4: Check all user bookings
    print('\n📚 Test 4: Checking all user bookings...');
    List<Booking> allBookings = await FirebaseService.getUserBookings('test_user_home_service_123');
    print('📊 Total bookings for user: ${allBookings.length}');
    
    for (int i = 0; i < allBookings.length; i++) {
      final booking = allBookings[i];
      print('   Booking ${i + 1}:');
      print('     - Branch: ${booking.branch}');
      print('     - Address: ${booking.address ?? 'N/A'}');
      print('     - Status: ${booking.status}');
      print('     - Is Home Service: ${booking.branch == 'Home Service'}');
    }
    
    print('\n🎉 Home service booking test completed successfully!');
    
  } catch (e) {
    print('❌ Home service booking test failed: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}