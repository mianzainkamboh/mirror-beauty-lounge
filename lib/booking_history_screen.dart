import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> upcomingBookings = [];
  List<Map<String, dynamic>> pastBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Mock data
    upcomingBookings = [
      {
        'id': 'B001',
        'service': 'Haircut & Styling',
        'date': '2023-12-15',
        'time': '11:00 AM',
        'branch': 'Marina Branch',
        'price': 800,
        'status': 'Confirmed',
        'canCancel': true,
      },
      {
        'id': 'B002',
        'service': 'Facial Treatment',
        'date': '2023-12-18',
        'time': '02:30 PM',
        'branch': 'City Center',
        'price': 1500,
        'status': 'Pending',
        'canCancel': true,
      },
    ];
    pastBookings = [
      {
        'id': 'B003',
        'service': 'Manicure & Pedicure',
        'date': '2023-11-20',
        'time': '10:00 AM',
        'branch': 'Marina Branch',
        'price': 1200,
        'status': 'Completed',
        'rating': 4.5,
      },
      {
        'id': 'B004',
        'service': 'Beard Trim',
        'date': '2023-11-15',
        'time': '04:00 PM',
        'branch': 'City Center',
        'price': 500,
        'status': 'Cancelled',
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search bookings...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.greyColor,
              indicatorColor: AppColors.primaryColor,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Upcoming'),
                      if (upcomingBookings.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: Text(
                              upcomingBookings.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(text: 'Past'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Tab
                _buildBookingList(upcomingBookings, isUpcoming: true),

                // Past Tab
                _buildBookingList(pastBookings, isUpcoming: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textColor,
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const Icon(Icons.calendar_today,
              size: 24,
              color: AppColors.primaryColor),
          const SizedBox(width: 10),
          const Text(
            'My Bookings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 2,
    );
  }

  Widget _buildBookingList(List<Map<String, dynamic>> bookings,
      {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today,
                size: 64,
                color: AppColors.greyColor),
            const SizedBox(height: 16),
            Text(
              'No ${isUpcoming ? 'upcoming' : 'past'} bookings found',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.greyColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to booking screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Book a Service'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => BookingCard(
        booking: bookings[index],
        isUpcoming: isUpcoming,
        onReschedule: () => _showRescheduleDialog(bookings[index]),
        onCancel: () => _showCancelDialog(bookings[index]),
        onDownload: () {},
      ),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: const Text('Select a new date and time for your appointment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle reschedule logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${booking['service']} rescheduled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle cancel logic
              setState(() {
                upcomingBookings.remove(booking);
                pastBookings.add({
                  ...booking,
                  'status': 'Cancelled',
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${booking['service']} cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isUpcoming;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onDownload;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isUpcoming,
    required this.onReschedule,
    required this.onCancel,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPast = !isUpcoming;
    final Color statusColor = _getStatusColor(booking['status']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['service'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPast ? AppColors.greyColor : AppColors.textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date & Time
            _buildInfoRow(Icons.calendar_today,
                '${booking['date']} • ${booking['time']}'),

            // Branch
            _buildInfoRow(Icons.location_on, booking['branch']),

            // Price
            _buildInfoRow(Icons.attach_money, 'PKR ${booking['price']}'),

            const SizedBox(height: 16),

            // Actions
            if (isUpcoming) _buildUpcomingActions(),
            if (isPast) _buildPastActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final bool isPast = !isUpcoming;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isPast ? AppColors.greyColor : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: booking['canCancel'] ? onReschedule : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 18),
                SizedBox(width: 8),
                Text('Reschedule'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: booking['canCancel'] ? onCancel : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 18),
                SizedBox(width: 8),
                Text('Cancel'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPastActions() {
    return Row(
      children: [
        if (booking['status'] == 'Completed')
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () {},
          ),
        const Spacer(),
        OutlinedButton(
          onPressed: onDownload,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.download, size: 18),
              SizedBox(width: 8),
              Text('Invoice'),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.greyColor;
    }
  }
}