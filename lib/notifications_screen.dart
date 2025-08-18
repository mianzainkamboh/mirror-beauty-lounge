import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Color(0xFFFF8F8F),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF8F8F),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error loading notifications: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading notifications',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Trigger rebuild to retry
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F8F),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<NotificationModel> notifications = [];
        if (snapshot.hasData && snapshot.data != null) {
          try {
            final docs = snapshot.data!.docs;
            if (docs.isNotEmpty) {
              notifications = docs
                  .map((doc) {
                    try {
                      final data = doc.data() as Map<String, dynamic>?;
                      if (data == null || data.isEmpty) {
                        debugPrint('Empty data for notification ${doc.id}');
                        return null;
                      }
                      
                      // Validate required fields
                      if (!data.containsKey('title') || !data.containsKey('body') || !data.containsKey('createdAt')) {
                        debugPrint('Missing required fields for notification ${doc.id}');
                        return null;
                      }
                      
                      return NotificationModel.fromFirestore(doc);
                    } catch (e) {
                      debugPrint('Error parsing notification ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((notification) => notification != null)
                  .cast<NotificationModel>()
                  .toList();
            }
          } catch (e) {
            debugPrint('Error processing notifications: $e');
            return _buildErrorState('Failed to load notifications. Please try again.');
          }
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            // Section header
            _buildSectionHeader('Your Notifications'),
            const SizedBox(height: 24),

            if (notifications.isEmpty)
              _buildEmptyState()
            else
              ..._buildNotificationsList(notifications),
          ],
        );
      },
    );
  }

  // Get notifications stream for current user
  Stream<QuerySnapshot> _getNotificationsStream() {
    String userId = 'user123'; // Replace with actual user ID from auth
    
    try {
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', whereIn: [userId, 'all']) // Include user-specific and broadcast notifications
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .handleError((error) {
            debugPrint('Firestore stream error: $error');
            return const Stream.empty();
          });
    } catch (e) {
      debugPrint('Error creating notifications stream: $e');
      return const Stream.empty();
    }
  }

  // Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you about offers, bookings, and updates',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build notifications list
  List<Widget> _buildNotificationsList(List<NotificationModel> notifications) {
    List<Widget> widgets = [];
    
    // Group notifications by date
    Map<String, List<NotificationModel>> groupedNotifications = {};
    
    for (var notification in notifications) {
      String dateKey = DateFormat('yyyy-MM-dd').format(notification.createdAt);
      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }
      groupedNotifications[dateKey]!.add(notification);
    }
    
    // Sort dates in descending order
    List<String> sortedDates = groupedNotifications.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    for (String dateKey in sortedDates) {
      DateTime date = DateTime.parse(dateKey);
      String dateLabel = _getDateLabel(date);
      
      // Add date header
      widgets.add(_buildDateHeader(dateLabel));
      widgets.add(const SizedBox(height: 12));
      
      // Add notifications for this date
      for (var notification in groupedNotifications[dateKey]!) {
        widgets.add(_buildNotificationCard(notification: notification));
        widgets.add(const SizedBox(height: 12));
      }
      
      widgets.add(const SizedBox(height: 8));
    }
    
    return widgets;
  }

  // Get date label (Today, Yesterday, or formatted date)
  String _getDateLabel(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime notificationDate = DateTime(date.year, date.month, date.day);
    
    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  // Build date header
  Widget _buildDateHeader(String dateLabel) {
    return Text(
      dateLabel,
      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel notification,
  }) {
    String formattedTime = DateFormat('HH:mm').format(notification.createdAt);
    return GestureDetector(
      onTap: () => _markAsRead(notification),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead 
              ? null 
              : Border.all(color: const Color(0xFFFF8F8F).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon and time row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Type icon and badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8F8F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notification.typeIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      notification.typeDisplayName,
                      style: const TextStyle(
                        color: Color(0xFFFF8F8F),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF8F8F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ]
                  ],
                ),
                // Time
                Text(
                  formattedTime,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              notification.title,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Body text
            Text(
              notification.body,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build error state widget
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild to retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8F8F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Mark notification as read with better error handling
  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notification.id)
            .update({'isRead': true});
            
        debugPrint('Notification marked as read: ${notification.id}');
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
        setState(() {
          _errorMessage = 'Failed to mark notification as read';
        });
        
        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to mark notification as read'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}