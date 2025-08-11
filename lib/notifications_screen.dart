import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        // Section header
        _buildSectionHeader('Customize your notifications!'),

        const SizedBox(height: 24),

        // Previously section
        _buildSectionHeader('Previously'),
        const SizedBox(height: 16),

        // Notification cards
        _buildNotificationCard(
          title: 'Appointment',
          date: 'Dec 16, 2023',
          description: 'Reminder Your appointment is scheduled for',
        ),
        const SizedBox(height: 16),

        _buildNotificationCard(
          title: 'Special offer',
          date: 'Dec 12, 2023',
          description: 'We are offering 50% on summer vacations.',
        ),
        const SizedBox(height: 16),

        _buildNotificationCard(
          title: 'Services Reminders',
          date: 'Dec 8, 2023',
          description: 'Your next Facial and manicure are due book your glow up now',
        ),
      ],
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
    required String title,
    required String date,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title with brand color
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFF8F8F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Date in gray
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description text
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}