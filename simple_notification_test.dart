import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'lib/firebase_options.dart';
import 'lib/services/notification_service.dart';
import 'lib/models/booking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Starting Simple Notification Test...');
  
  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');
    }
    
    // Check notification permission
    PermissionStatus status = await Permission.notification.status;
    print('📱 Notification permission: ${status.name}');
    
    if (status.isDenied) {
      print('⚠️  Requesting notification permission...');
      PermissionStatus result = await Permission.notification.request();
      print('📱 Permission result: ${result.name}');
    }
    
    // Initialize notification service
    print('🔧 Initializing notification service...');
    await NotificationService().initialize();
    print('✅ Notification service initialized');
    
    // Test immediate notification
    print('📤 Sending test notification...');
    await NotificationService().showNotification(
      title: 'Test Notification',
      body: 'Testing notification system',
      payload: '{"type": "test"}',
      id: 999,
      channelId: 'general_notifications',
    );
    print('✅ Test notification sent');
    
    // Wait 3 seconds
    await Future.delayed(Duration(seconds: 3));
    
    // Test booking confirmation notification
    print('📤 Testing booking confirmation notification...');
    
    final testBooking = Booking(
      id: 'test_booking_123',
      userId: 'test_user',
      customerName: 'Test Customer',
      services: [
        BookingService(
          serviceId: 'home_service_1',
          serviceName: 'Home Facial Treatment',
          category: 'Beauty',
          duration: 90,
          price: 150.0,
          quantity: 1,
        ),
      ],
      bookingDate: DateTime.now().add(Duration(days: 1)),
      bookingTime: '15:00',
      branch: 'Home Service',
      address: '123 Test Street, Test City',
      totalPrice: 150.0,
      totalDuration: 90,
      status: 'upcoming',
      paymentMethod: 'cash',
      emailConfirmation: false,
      smsConfirmation: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await NotificationService().sendBookingConfirmationNotification(testBooking);
    print('✅ Booking confirmation notification sent');
    
    print('\n🎉 All tests completed successfully!');
    print('👀 Check your device notification panel');
    
    // Keep the app running for a moment
    runApp(SimpleTestApp());
    
  } catch (e) {
    print('❌ Test failed: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}

class SimpleTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Notification Test'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'Notification Test Completed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Check your notification panel',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}