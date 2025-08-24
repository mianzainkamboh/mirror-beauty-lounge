import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'lib/firebase_options.dart';
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
    
    // Run notification diagnostics
    await runNotificationDiagnostics();
    
  } catch (e) {
    print('❌ Initialization error: $e');
  }
}

Future<void> runNotificationDiagnostics() async {
  print('\n🔍 Starting Notification Diagnostics...');
  print('=' * 50);
  
  try {
    // Test 1: Check notification permissions
    await checkNotificationPermissions();
    
    // Test 2: Initialize notification service
    await testNotificationServiceInitialization();
    
    // Test 3: Test immediate notification
    await testImmediateNotification();
    
    // Test 4: Test scheduled notification
    await testScheduledNotification();
    
    // Test 5: Check pending notifications
    await checkPendingNotifications();
    
    // Test 6: Test booking confirmation notification
    await testBookingConfirmationNotification();
    
    print('\n✅ All diagnostic tests completed!');
    
  } catch (e) {
    print('❌ Diagnostic execution error: $e');
  }
}

Future<void> checkNotificationPermissions() async {
  print('\n📋 Test 1: Notification Permissions');
  print('-' * 35);
  
  try {
    // Check notification permission status
    PermissionStatus notificationStatus = await Permission.notification.status;
    print('📱 Notification permission status: ${notificationStatus.name}');
    
    if (notificationStatus.isDenied) {
      print('⚠️  Notification permission is denied');
      print('🔧 Requesting notification permission...');
      
      PermissionStatus requestResult = await Permission.notification.request();
      print('📱 Permission request result: ${requestResult.name}');
      
      if (requestResult.isGranted) {
        print('✅ Notification permission granted after request');
      } else {
        print('❌ Notification permission still denied');
        print('💡 User needs to manually enable notifications in device settings');
      }
    } else if (notificationStatus.isGranted) {
      print('✅ Notification permission is already granted');
    } else if (notificationStatus.isPermanentlyDenied) {
      print('❌ Notification permission is permanently denied');
      print('💡 User must enable notifications in device settings manually');
    }
    
    // Check if we can open app settings
    bool canOpenSettings = await openAppSettings();
    print('🔧 Can open app settings: $canOpenSettings');
    
  } catch (e) {
    print('❌ Permission check failed: $e');
  }
}

Future<void> testNotificationServiceInitialization() async {
  print('\n📋 Test 2: Notification Service Initialization');
  print('-' * 45);
  
  try {
    print('🔧 Initializing notification service...');
    await NotificationService().initialize();
    print('✅ Notification service initialized successfully');
    
    // Check if Flutter Local Notifications plugin is working
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
        FlutterLocalNotificationsPlugin();
    
    // Check Android implementation
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      print('✅ Android notification implementation available');
      
      // Check if notifications are enabled
      bool? areNotificationsEnabled = await androidImplementation.areNotificationsEnabled();
      print('📱 Notifications enabled in system: ${areNotificationsEnabled ?? "unknown"}');
      
      // Request exact alarm permission (for scheduled notifications)
      bool? canScheduleExactNotifications = await androidImplementation.canScheduleExactNotifications();
      print('⏰ Can schedule exact notifications: ${canScheduleExactNotifications ?? "unknown"}');
      
      if (canScheduleExactNotifications == false) {
        print('⚠️  Exact alarm permission needed for scheduled notifications');
        await androidImplementation.requestExactAlarmsPermission();
      }
    } else {
      print('❌ Android notification implementation not available');
    }
    
  } catch (e) {
    print('❌ Notification service initialization failed: $e');
  }
}

Future<void> testImmediateNotification() async {
  print('\n📋 Test 3: Immediate Notification');
  print('-' * 32);
  
  try {
    print('📤 Sending immediate test notification...');
    
    await NotificationService().showNotification(
      title: 'Test Notification',
      body: 'This is a test notification to verify the system is working',
      payload: '{"type": "test", "timestamp": "${DateTime.now().toIso8601String()}"}',
      id: 999,
      channelId: 'general_notifications',
    );
    
    print('✅ Immediate notification sent successfully');
    print('👀 Check your device notification panel for the test notification');
    
  } catch (e) {
    print('❌ Immediate notification test failed: $e');
  }
}

Future<void> testScheduledNotification() async {
  print('\n📋 Test 4: Scheduled Notification');
  print('-' * 32);
  
  try {
    print('⏰ Scheduling test notification for 10 seconds from now...');
    
    DateTime scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    
    await NotificationService().scheduleNotification(
      id: 998,
      title: 'Scheduled Test Notification',
      body: 'This scheduled notification was sent 10 seconds after the test',
      scheduledDate: scheduledTime,
      payload: '{"type": "scheduled_test", "timestamp": "${scheduledTime.toIso8601String()}"}',
      channelId: 'booking_notifications',
    );
    
    print('✅ Scheduled notification set successfully');
    print('⏰ Notification scheduled for: ${scheduledTime.toString()}');
    print('👀 Watch for the notification in 10 seconds');
    
  } catch (e) {
    print('❌ Scheduled notification test failed: $e');
  }
}

Future<void> checkPendingNotifications() async {
  print('\n📋 Test 5: Pending Notifications');
  print('-' * 30);
  
  try {
    print('📋 Checking pending notifications...');
    
    List<PendingNotificationRequest> pendingNotifications = 
        await NotificationService().getPendingNotifications();
    
    print('📊 Total pending notifications: ${pendingNotifications.length}');
    
    if (pendingNotifications.isNotEmpty) {
      print('📝 Pending notifications details:');
      for (var notification in pendingNotifications) {
        print('   - ID: ${notification.id}');
        print('     Title: ${notification.title}');
        print('     Body: ${notification.body}');
        print('     Payload: ${notification.payload}');
        print('   ---');
      }
    } else {
      print('📭 No pending notifications found');
    }
    
  } catch (e) {
    print('❌ Pending notifications check failed: $e');
  }
}

Future<void> testBookingConfirmationNotification() async {
  print('\n📋 Test 6: Booking Confirmation Notification');
  print('-' * 42);
  
  try {
    // Create a mock booking for testing
    final mockBooking = Booking(
      id: 'test_booking_notification_123',
      userId: 'test_user_123',
      customerName: 'Test Customer',
      services: [
        BookingService(
          serviceId: 'test_service_1',
          serviceName: 'Test Notification Service',
          category: 'Beauty',
          duration: 60,
          price: 100.0,
          quantity: 1,
        ),
      ],
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      bookingTime: '14:00',
      branch: 'Home Service',
      address: '123 Test Street, Test City',
      totalPrice: 100.0,
      totalDuration: 60,
      status: 'upcoming',
      paymentMethod: 'cash',
      emailConfirmation: false,
      smsConfirmation: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    print('📤 Sending booking confirmation notification...');
    print('📝 Booking details:');
    print('   - Customer: ${mockBooking.customerName}');
    print('   - Service: ${mockBooking.services.first.serviceName}');
    print('   - Branch: ${mockBooking.branch}');
    print('   - Address: ${mockBooking.address}');
    print('   - Date: ${mockBooking.bookingDate}');
    print('   - Time: ${mockBooking.bookingTime}');
    
    await NotificationService().sendBookingConfirmationNotification(mockBooking);
    
    print('✅ Booking confirmation notification sent successfully');
    print('👀 Check your device for the booking confirmation notification');
    
    // Wait a moment and check pending notifications again
    await Future.delayed(const Duration(seconds: 2));
    
    List<PendingNotificationRequest> pendingAfterBooking = 
        await NotificationService().getPendingNotifications();
    
    print('📊 Pending notifications after booking: ${pendingAfterBooking.length}');
    
  } catch (e) {
    print('❌ Booking confirmation notification test failed: $e');
  }
}

class NotificationDiagnosticApp extends StatelessWidget {
  const NotificationDiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notification Diagnostic'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active,
                size: 64,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Notification Diagnostic Running',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Check console for detailed results',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}