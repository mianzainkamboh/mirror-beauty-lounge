import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/booking.dart';
import '../models/notification_model.dart';
import 'fcm_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Notification service already initialized');
      return;
    }

    try {
      debugPrint('Initializing Notification Service...');
      
      // Initialize timezone
      tz.initializeTimeZones();

      // Request notification permissions
      await _requestPermissions();

      // Create notification channels for Android
      await _createNotificationChannels();

      // Android initialization settings with sound and vibration
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_notification');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      final initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      if (initialized != true) {
        throw Exception('Failed to initialize local notifications plugin');
      }

      _isInitialized = true;
      debugPrint('Local notifications initialized successfully');
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
      rethrow;
    }
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    try {
      final AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
         'general_notifications',
         'General Notifications',
         description: 'General app notifications',
         importance: Importance.high,
         enableVibration: true,
         vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
         enableLights: true,
         ledColor: const Color(0xFFFF8F8F),
         playSound: true,
         showBadge: true,
       );

       final AndroidNotificationChannel bookingChannel = AndroidNotificationChannel(
         'booking_notifications',
         'Booking Notifications',
         description: 'Booking confirmations and reminders',
         importance: Importance.max,
         enableVibration: true,
         vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
         enableLights: true,
         ledColor: const Color(0xFFFF8F8F),
         playSound: true,
         showBadge: true,
       );

       final AndroidNotificationChannel offerChannel = AndroidNotificationChannel(
         'offer_notifications',
         'Offer Notifications',
         description: 'Special offers and promotions',
         importance: Importance.high,
         enableVibration: true,
         vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
         enableLights: true,
         ledColor: const Color(0xFFFF8F8F),
         playSound: true,
         showBadge: true,
       );

      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(generalChannel);
        await androidPlugin.createNotificationChannel(bookingChannel);
        await androidPlugin.createNotificationChannel(offerChannel);
        
        debugPrint('Notification channels created successfully');
      } else {
        debugPrint('Android plugin not available for notification channels');
      }
    } catch (e) {
      debugPrint('Error creating notification channels: $e');
      rethrow;
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // Request notification permission
      PermissionStatus status = await Permission.notification.request();
      
      if (status.isGranted) {
        debugPrint('Notification permission granted');
      } else {
        debugPrint('Notification permission denied');
      }

      // For Android 13+ (API level 33+), request POST_NOTIFICATIONS permission
        if (defaultTargetPlatform == TargetPlatform.android) {
          // Request notification permissions for Android 13+
          await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission();
        }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  // Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    String? type = data['type'];
    
    switch (type) {
      case 'offer':
        // Navigate to offers screen
        break;
      case 'bookingConfirmation':
      case 'bookingReminder':
      case 'bookingToday':
        // Navigate to booking details or booking history
        String? bookingId = data['bookingId'];
        if (bookingId != null) {
          // Navigate to booking details
        }
        break;
      default:
        // Navigate to notifications screen
        break;
    }
  }

  // Show immediate notification with sound and vibration
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
    String channelId = 'general_notifications',
  }) async {
    try {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        vibrationPattern: _getVibrationPattern(channelId),
        enableLights: true,
        ledColor: const Color(0xFFFF8F8F),
        autoCancel: false,
        ongoing: false,
        timeoutAfter: null,
        showWhen: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        icon: '@drawable/ic_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_notification'),
        ticker: title,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      
      debugPrint('Local notification shown: $title - $body');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Helper methods for channel configuration
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case 'booking_notifications':
        return 'Booking Notifications';
      case 'offer_notifications':
        return 'Offer Notifications';
      default:
        return 'General Notifications';
    }
  }

  static String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'booking_notifications':
        return 'Booking confirmations and reminders';
      case 'offer_notifications':
        return 'Special offers and promotions';
      default:
        return 'General app notifications';
    }
  }

  static Int64List _getVibrationPattern(String channelId) {
    switch (channelId) {
      case 'booking_notifications':
        return Int64List.fromList([0, 1000, 500, 1000]);
      case 'offer_notifications':
        return Int64List.fromList([0, 500, 250, 500]);
      default:
        return Int64List.fromList([0, 1000, 500, 1000]);
    }
  }

  // Schedule notification with sound and vibration
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'booking_notifications',
  }) async {
    try {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        vibrationPattern: _getVibrationPattern(channelId),
        enableLights: true,
        ledColor: const Color(0xFFFF8F8F),
        autoCancel: false,
        ongoing: false,
        visibility: NotificationVisibility.public,
        icon: '@drawable/ic_notification',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('Notification scheduled for: $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Schedule booking notifications
  Future<void> scheduleBookingNotifications(Booking booking) async {
    try {
      DateTime bookingDateTime = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
        int.parse(booking.bookingTime.split(':')[0]),
        int.parse(booking.bookingTime.split(':')[1]),
      );

      String serviceName = booking.services.isNotEmpty ? booking.services.first.serviceName : 'appointment';

      // Schedule same-day notification (at 9 AM on booking day)
      DateTime sameDayNotification = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
        9, // 9 AM
        0,
      );

      if (sameDayNotification.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: booking.id.hashCode,
          title: 'Booking Today! 📅',
          body: 'You have a $serviceName booking today at ${booking.bookingTime} at ${booking.branch}',
          scheduledDate: sameDayNotification,
          payload: jsonEncode({
            'type': 'bookingToday',
            'bookingId': booking.id,
          }),
        );
      }

      // Schedule 1-hour before notification
      DateTime oneHourBefore = bookingDateTime.subtract(const Duration(hours: 1));
      
      if (oneHourBefore.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: (booking.id! + '_1hour').hashCode,
          title: 'Booking Reminder ⏰',
          body: 'Your $serviceName appointment is in 1 hour at ${booking.branch}',
          scheduledDate: oneHourBefore,
          payload: jsonEncode({
            'type': 'bookingReminder',
            'bookingId': booking.id,
          }),
        );
      }

      debugPrint('Booking notifications scheduled for booking: ${booking.id}');
    } catch (e) {
      debugPrint('Error scheduling booking notifications: $e');
    }
  }

  // Send booking confirmation notification
  Future<void> sendBookingConfirmationNotification(Booking booking) async {
    try {
      String serviceName = booking.services.isNotEmpty ? booking.services.first.serviceName : 'appointment';
      
      // Show immediate notification
      await showNotification(
        title: 'Booking Confirmed! ✅',
        body: 'Your $serviceName appointment on ${booking.bookingDate.day}/${booking.bookingDate.month} at ${booking.bookingTime} has been confirmed.',
        payload: jsonEncode({
          'type': 'bookingConfirmation',
          'bookingId': booking.id,
        }),
        channelId: 'booking_notifications',
      );

      // Send FCM notification
      await FCMService().sendNotificationToUser(
        userId: booking.userId,
        title: 'Booking Confirmed! ✅',
        body: 'Your $serviceName appointment on ${booking.bookingDate.day}/${booking.bookingDate.month} at ${booking.bookingTime} has been confirmed.',
        type: NotificationType.bookingConfirmation,
        bookingId: booking.id,
      );

      // Schedule future notifications
      await scheduleBookingNotifications(booking);
    } catch (e) {
      debugPrint('Error sending booking confirmation notification: $e');
    }
  }

  // Send offer notification
  Future<void> sendOfferNotification({
    required String title,
    required String body,
    String? offerId,
  }) async {
    try {
      // Show immediate notification
      await showNotification(
        title: title,
        body: body,
        payload: jsonEncode({
          'type': 'offer',
          'offerId': offerId,
        }),
        channelId: 'offer_notifications',
      );

      // Send FCM notification
      await FCMService().sendOfferNotification(
        title: title,
        body: body,
        offerId: offerId,
      );
    } catch (e) {
      debugPrint('Error sending offer notification: $e');
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Notification cancelled: $id');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  // Check if service is initialized
  bool get isInitialized => _isInitialized;
}