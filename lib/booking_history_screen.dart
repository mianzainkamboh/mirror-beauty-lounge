import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/models/booking.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';
import 'package:mirrorsbeautylounge/services/auth_service.dart';


class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Booking> upcomingBookings = [];
  List<Booking> pastBookings = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Update overdue bookings first
      await FirebaseService.updateOverdueBookings();

      // Load bookings from Firebase
      const String userId = 'user123'; // Replace with actual user ID from auth
      
      final upcoming = await FirebaseService.getUpcomingBookings(userId);
      final past = await FirebaseService.getPastBookings(userId);

      setState(() {
        upcomingBookings = upcoming;
        pastBookings = past;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load bookings: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth <= 600;
    final isLargeScreen = screenWidth > 600;
    
    // Responsive values
    final horizontalPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 24.0);
    final verticalPadding = isSmallScreen ? 6.0 : 8.0;
    final searchBorderRadius = isSmallScreen ? 8.0 : 12.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget(context)
              : Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search bookings...',
                          hintStyle: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(searchBorderRadius),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                              : null,
                        ),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
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
                        labelStyle: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Upcoming',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                if (upcomingBookings.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: isSmallScreen ? 4 : 6),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 4 : 6,
                                        vertical: 2,
                                      ),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryColor,
                                      ),
                                      child: Text(
                                        upcomingBookings.length.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 10 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Past',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Upcoming Tab
                          _buildBookingList(upcomingBookings, isUpcoming: true, context: context),

                          // Past Tab
                          _buildBookingList(pastBookings, isUpcoming: false, context: context),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isSmallScreen ? 48 : 64,
            color: Colors.red,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
            ),
            child: Text(
              errorMessage!,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          ElevatedButton(
            onPressed: _loadBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: isSmallScreen ? 12 : 16,
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textColor,
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: isSmallScreen ? 20 : 24,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: isSmallScreen ? 8 : 10),
          Text(
            'My Bookings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 20,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 2,
    );
  }

  Widget _buildBookingList(List<Booking> bookings,
      {required bool isUpcoming, required BuildContext context}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth <= 600;
    
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: isSmallScreen ? 48 : 64,
              color: AppColors.greyColor,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
              ),
              child: Text(
                'No ${isUpcoming ? 'upcoming' : 'past'} bookings found',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: AppColors.greyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to home/services
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                ),
              ),
              child: Text(
                'Book a Service',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 12 : 16,
          horizontal: isSmallScreen ? 8 : 0,
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) => BookingCard(
          booking: bookings[index],
          isUpcoming: isUpcoming,
          onReschedule: () => _showRescheduleDialog(bookings[index]),
          onCancel: () => _showCancelDialog(bookings[index]),
          onDownload: () {},
        ),
      ),
    );
  }

  void _showRescheduleDialog(Booking booking) async {
    DateTime selectedDate = booking.bookingDate;
    String selectedTime = booking.bookingTime;
    String selectedBranch = booking.branch;
    bool isLoading = false;

    // Get user gender for branch restrictions
    String? userGender;
    try {
      final AuthService authService = AuthService();
      userGender = await authService.getCurrentUserGender();
    } catch (e) {
      // Handle error silently
    }

    // All branches list
    final List<String> allBranches = [
      'Al Muraqqabat',
      'IBN Battuta Mall',
      'Al Bustan',
      'TECOM',
      'Marina',
    ];
 
    // Get available branches based on user gender
    List<String> availableBranches = userGender?.toLowerCase() == 'male' 
        ? ['Marina'] 
        : allBranches;

    // Ensure selected branch is available for the user
    if (userGender?.toLowerCase() == 'male' && selectedBranch != 'Marina') {
      selectedBranch = 'Marina';
    }


    final List<String> timeSlots = [
       "10:00 AM", "11:00 AM", "12:00 PM",
      "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM",
      "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM","9:00 PM","10:00 PM"
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Reschedule Booking',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current booking info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.services.isNotEmpty
                                ? booking.services.first.serviceName
                                : 'Service',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AED ${booking.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Branch Selection
                    Row(
                      children: [
                        const Text(
                          'Branch',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (userGender?.toLowerCase() == 'male')
                          const Expanded(
                            child: Text(
                              ' (Available in Marina only)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBranch,
                          isExpanded: true,
                          items: availableBranches.map((branch) {
                            return DropdownMenuItem(
                              value: branch,
                              child: Text(
                                branch,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedBranch = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Selection
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Time Selection
                    const Text(
                      'Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTime,
                          isExpanded: true,
                          items: timeSlots.map((time) {
                            return DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedTime = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    setState(() {
                      isLoading = true;
                    });
                    
                    try {
                      // Update booking in Firebase
                      if (booking.id != null) {
                        // Create updated booking object
                        Booking updatedBooking = booking.copyWith(
                          bookingDate: selectedDate,
                          bookingTime: selectedTime,
                          branch: selectedBranch,
                          updatedAt: DateTime.now(),
                        );
                        
                        await FirebaseService.updateBooking(
                          booking.id!,
                          updatedBooking,
                        );
                        
                        // Reload bookings to reflect changes
                        await _loadBookings();
                        
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking rescheduled successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to reschedule: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(Booking booking) {
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
            onPressed: () async {
              try {
                // Update booking status to cancelled in Firebase
                if (booking.id != null) {
                  await FirebaseService.updateBookingStatus(booking.id!, 'cancelled');
                }
                
                // Reload bookings to reflect changes
                await _loadBookings();
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel booking: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
  final Booking booking;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth <= 600;
    
    final bool isPast = !isUpcoming;
    final Color statusColor = _getStatusColor(booking.status);
    final String serviceName = booking.services.isNotEmpty 
        ? booking.services.length == 1 
            ? booking.services.first.serviceName
            : '${booking.services.first.serviceName} +${booking.services.length - 1} more'
        : 'No services';

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    serviceName,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: isPast ? AppColors.greyColor : AppColors.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),

            // Date & Time
            _buildInfoRow(
              context,
              Icons.calendar_today,
              '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} • ${booking.bookingTime}',
            ),

            // Branch
            _buildInfoRow(context, Icons.location_on, booking.branch),

            // Price
            _buildInfoRow(context, Icons.attach_money, 'AED ${booking.totalPrice.toStringAsFixed(0)}'),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // Actions
            if (isUpcoming) _buildUpcomingActions(context),
            if (isPast) _buildPastActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final bool isPast = !isUpcoming;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 3 : 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 16 : 18,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: isSmallScreen ? 8 : 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: isPast ? AppColors.greyColor : AppColors.textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final bool canModify = booking.status == 'upcoming';
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: canModify ? onReschedule : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 8 : 12,
                horizontal: isSmallScreen ? 8 : 16,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: isSmallScreen ? 16 : 18),
                SizedBox(width: isSmallScreen ? 4 : 8),
                Text(
                  'Reschedule',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 10),
        Expanded(
          child: ElevatedButton(
            onPressed: canModify ? onCancel : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 8 : 12,
                horizontal: isSmallScreen ? 8 : 16,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: isSmallScreen ? 16 : 18),
                SizedBox(width: isSmallScreen ? 4 : 8),
                Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPastActions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Row(
      children: [
        if (booking.status == 'past')
          IconButton(
            icon: Icon(
              Icons.star,
              color: Colors.amber,
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: () {
              // Handle rating functionality
            },
          ),
        const Spacer(),
        OutlinedButton(
          onPressed: onDownload,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            ),
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 8 : 12,
              horizontal: isSmallScreen ? 12 : 16,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download, size: isSmallScreen ? 16 : 18),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Text(
                'Invoice',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.green;
      case 'past':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.greyColor;
    }
  }
}