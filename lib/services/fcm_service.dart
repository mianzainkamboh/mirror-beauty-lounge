import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'auth_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String? _fcmToken;
  bool _isInitialized = false;

  // Initialize FCM
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('Initializing FCM Service...');
      
      // Request notification permissions first
      final permissionGranted = await _requestPermission();
      if (!permissionGranted) {
        debugPrint('Notification permissions not granted');
        return;
      }
      
      // Get and save FCM token
      await _getAndSaveToken();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      _isInitialized = true;
      debugPrint('FCM Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM Service: $e');
      rethrow;
    }
  }

  // Request notification permission
  Future<bool> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('User granted permission: ${settings.authorizationStatus}');
      
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  // Get and save FCM token
  Future<void> _getAndSaveToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Save token to Firestore
      if (_fcmToken != null) {
        await _saveFCMTokenToFirestore(_fcmToken!);
      }

      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _saveFCMTokenToFirestore(newToken);
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      rethrow;
    }
  }

  // Set up message handlers
  void _setupMessageHandlers() {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Handle app launch from terminated state
      _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          _handleBackgroundMessageTap(message);
        }
      });
    } catch (e) {
      debugPrint('Error setting up message handlers: $e');
      rethrow;
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveFCMTokenToFirestore(String token) async {
    try {
      String userId = 'user123'; // Replace with actual user ID from auth
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('FCM token saved to Firestore');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    try {
      // Save notification to Firestore first
      _saveNotificationToFirestore(message);

      // Show local notification with sound for foreground messages
      _showForegroundNotification(message);
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  // Handle background message tap
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Background message tapped: ${message.messageId}');
    
    // Save notification to Firestore
    _saveNotificationToFirestore(message);
    
    // Handle navigation
    _handleNotificationNavigation(message.data);
  }

  // Handle notification navigation based on type
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint('Handling notification navigation: $data');
    
    // TODO: Implement navigation logic based on notification type
    // This will be implemented when integrating with the app's navigation
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? bookingId,
    String? offerId,
  }) async {
    try {
      // Create notification object
      NotificationModel notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
        bookingId: bookingId,
        offerId: offerId,
      );

      // Save notification to Firestore
      await _saveNotificationToFirestore(notification);
      
      debugPrint('Notification sent to user: $userId');
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
    }
  }

  // Send offer notification to all users
  Future<void> sendOfferNotification({
    required String title,
    required String body,
    String? offerId,
  }) async {
    try {
      // Create notification object (without specific userId for broadcast)
      NotificationModel notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'all', // Special userId for broadcast notifications
        title: title,
        body: body,
        type: NotificationType.offer,
        isRead: false,
        createdAt: DateTime.now(),
        offerId: offerId,
      );

      // Save notification to Firestore
      await _saveNotificationToFirestore(notification);
      
      debugPrint('Offer notification sent to all users');
    } catch (e) {
      debugPrint('Error sending offer notification: $e');
    }
  }

  // Save notification to Firestore
  Future<void> _saveNotificationToFirestore(dynamic notification) async {
    try {
      if (notification is RemoteMessage) {
        // Handle RemoteMessage from FCM
        final user = _authService.currentUser;
        if (user == null) {
          debugPrint('No authenticated user for saving notification');
          return;
        }
        String userId = user.uid;
        
        NotificationType type = NotificationType.offer;
        if (notification.data['type'] != null) {
          switch (notification.data['type']) {
            case 'offer':
              type = NotificationType.offer;
              break;
            case 'bookingConfirmation':
              type = NotificationType.bookingConfirmation;
              break;
            case 'bookingReminder':
              type = NotificationType.bookingReminder;
              break;
            case 'bookingToday':
              type = NotificationType.bookingToday;
              break;
          }
        }

        NotificationModel notificationModel = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: notification.notification?.title ?? 'New Notification',
          body: notification.notification?.body ?? '',
          type: type,
          userId: userId,
          isRead: false,
          createdAt: DateTime.now(),
          data: notification.data,
          bookingId: notification.data['bookingId'],
          offerId: notification.data['offerId'],
        );

        await _firestore.collection('notifications').doc(notificationModel.id).set(notificationModel.toMap());
      } else if (notification is NotificationModel) {
        // Handle NotificationModel directly
        await _firestore.collection('notifications').doc(notification.id).set(notification.toMap());
      }
      
      debugPrint('Notification saved to Firestore');
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }

  // Subscribe to topic for offer notifications
  Future<void> subscribeToOffers() async {
    try {
      await _firebaseMessaging.subscribeToTopic('offers');
      debugPrint('Subscribed to offers topic');
    } catch (e) {
      debugPrint('Error subscribing to offers: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromOffers() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('offers');
      debugPrint('Unsubscribed from offers topic');
    } catch (e) {
      debugPrint('Error unsubscribing from offers: $e');
    }
  }

  // Get FCM token
  String? get fcmToken => _fcmToken;

  // Show local notification for foreground messages
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      final notificationService = NotificationService();
      
      // Ensure notification service is initialized
      if (!notificationService.isInitialized) {
        await notificationService.initialize();
      }
      
      String title = message.notification?.title ?? 'New Notification';
      String body = message.notification?.body ?? 'You have a new notification';
      
      // Create payload with message data
      Map<String, dynamic> payload = {
        'type': message.data['type'] ?? 'general',
        'messageId': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ...message.data,
      };
      
      // Determine channel based on notification type
      String channelId = 'general_notifications';
      final String? type = message.data['type'];
      
      if (type != null) {
        switch (type.toLowerCase()) {
          case 'booking_confirmation':
          case 'booking_reminder':
          case 'booking_today':
            channelId = 'booking_notifications';
            break;
          case 'offer':
          case 'promotion':
            channelId = 'offer_notifications';
            break;
          default:
            channelId = 'general_notifications';
        }
      }
      
      // Generate unique ID for notification
      int notificationId = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;
      
      await notificationService.showNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: jsonEncode(payload),
        channelId: channelId,
      );
      
      debugPrint('Foreground notification displayed: $title (ID: $notificationId, Channel: $channelId)');
    } catch (e) {
      debugPrint('Error showing foreground notification: $e');
    }
  }

  // Check if FCM is initialized
  bool get isInitialized => _isInitialized;
}

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
  
  try {
    // Initialize notification service for background handling
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Show local notification for background messages
    String title = message.notification?.title ?? 'New Notification';
    String body = message.notification?.body ?? 'You have a new message';
    String channelId = message.data['type'] == 'offer' ? 'offer_notifications' : 'general_notifications';
    
    await notificationService.showNotification(
      title: title,
      body: body,
      channelId: channelId,
      payload: jsonEncode(message.data),
    );
    
    // Save notification to Firestore
    await FCMService()._saveNotificationToFirestore(message);
  } catch (e) {
    debugPrint('Error handling background message: $e');
  }
}