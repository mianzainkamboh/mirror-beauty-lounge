import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/cartscreen.dart';
import 'package:mirrorsbeautylounge/services_by_category_screen.dart';
import 'package:mirrorsbeautylounge/models/booking.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';
import 'package:mirrorsbeautylounge/services/auth_service.dart';
import 'package:mirrorsbeautylounge/services/notification_service.dart';
import 'package:mirrorsbeautylounge/booking_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final int totalDuration;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.totalDuration,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'cash';
  bool emailConfirmation = true;
  bool smsConfirmation = true;
  bool showPromoField = false;
  TextEditingController promoController = TextEditingController();
  String? userGender;
  final AuthService _authService = AuthService();
  
  // Editable booking information
  late List<Map<String, dynamic>> editableCartItems;
  late String customerName;
  late DateTime selectedDate;
  late String selectedBranch;
  late String selectedTime;
  
  @override
  void initState() {
    super.initState();
    editableCartItems = widget.cartItems.map((item) => {
      'id': item['id'] ?? '',
      'name': item['name'] ?? item['serviceName'] ?? 'Unknown Service',
      'price': item['price'] ?? 0,
      'duration': item['duration'] ?? 30,
      'imageBase64': item['imageBase64'] ?? '',
      'quantity': item['quantity'] ?? 1,
    }).toList();
    
    customerName = 'Guest';
    selectedDate = DateTime.now();
    selectedBranch = 'Marina'; // Default to Marina, user can change
    selectedTime = '10:00 AM'; // Default to first time slot, user can change
    
    _loadUserGender();
    _loadUserName();
  }

  Future<void> _loadUserGender() async {
    try {
      final gender = await _authService.getCurrentUserGender();
      setState(() {
        userGender = gender;
      });
    } catch (e) {
      // Handle error silently, default to showing all branches
    }
  }

  Future<void> _loadUserName() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (userData != null && userData['name'] != null) {
          setState(() {
            customerName = userData['name'] as String;
          });
        } else {
          // Fallback to display name if available
          setState(() {
            customerName = user.displayName ?? 'Guest';
          });
        }
      } else {
        setState(() {
          customerName = 'Guest';
        });
      }
    } catch (e) {
      // Handle error silently, use fallback name
      setState(() {
        customerName = 'Guest';
      });
    }
  }

  List<String> get availableBranches {
    final List<String> allBranches = [
      'Al Muraqqabat',
      'IBN Battuta Mall',
      'Al Bustan',
      'TECOM',
      'Marina',
    ];
    
    if (userGender?.toLowerCase() == 'male') {
      return ['Marina'];
    }
    return allBranches;
  }

  bool isBranchAvailable(String branch) {
    if (userGender?.toLowerCase() == 'male') {
      return branch == 'Marina';
    }
    return true;
  }

  void _showBranchRestrictionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This branch is only available on Marina branch for men'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Services Section
            _buildServicesSection(),
            const SizedBox(height: 24),

            // Price Summary Section
            _buildPriceSection(),
            const SizedBox(height: 24),

            // Booking Info Section
            _buildBookingInfoSection(),
            const SizedBox(height: 24),

            // Payment Method Section
            _buildPaymentSection(),
            const SizedBox(height: 24),

            // Confirmation Options
            _buildConfirmationOptions(),
            const SizedBox(height: 32),

            // Confirm & Pay Button
            _buildConfirmButton(),
          ],
        ),
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
      title: const Text(
        'Review & Pay',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.textColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt),
          color: AppColors.primaryColor,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.primaryColor,
                  onPressed: _showEditServicesDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...editableCartItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    _getServiceEmoji(item['name']),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item['name']} - $selectedTime ($selectedBranch)',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    color: Colors.red,
                    onPressed: () => _removeService(item),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Text(
              'Total Duration: ${_calculateTotalDuration() ~/ 60}h ${_calculateTotalDuration() % 60}min',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyColor,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _addMoreServices,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 8),
                  Text('Add More Services'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getServiceEmoji(String serviceName) {
    if (serviceName.toLowerCase().contains('hair')) return '💇';
    if (serviceName.toLowerCase().contains('facial')) return '💆';
    if (serviceName.toLowerCase().contains('massage')) return '💆‍♂️';
    if (serviceName.toLowerCase().contains('nail')) return '💅';
    return '✨';
  }

  // Helper methods for calculations
  double _calculateTotalPrice() {
    return editableCartItems.fold(0.0, (sum, item) => sum + (item['price'] as num).toDouble());
  }

  int _calculateTotalDuration() {
    return editableCartItems.fold(0, (sum, item) => sum + (item['duration'] as int));
  }

  // Service editing methods
  void _removeService(Map<String, dynamic> item) {
    setState(() {
      editableCartItems.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} removed from booking'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _addMoreServices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServicesByCategoryScreen(
          categoryName: 'All Services',
          categoryId: 'all',
        ),
      ),
    );
  }

  void _showEditServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Services'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('You can remove services by tapping the remove icon next to each service.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addMoreServices();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add More Services'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Booking information editing methods
  void _editName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController(text: customerName);
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  customerName = nameController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _editBranch() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Select Branch'),
              if (userGender?.toLowerCase() == 'male') ...[
                const SizedBox(width: 8),
                const Text(
                  '(Available in Marina only)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableBranches.map((branch) {
              return RadioListTile<String>(
                title: Text(
                  branch,
                  style: const TextStyle(
                    color: AppColors.textColor,
                  ),
                ),
                value: branch,
                groupValue: selectedBranch,
                activeColor: AppColors.primaryColor,
                onChanged: (String? value) {
                  setState(() {
                    selectedBranch = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editTime() {
    final List<String> timeSlots = [
      '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM',
      '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM',
      '8:00 PM', '9:00 PM', '10:00 PM',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Time'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final time = timeSlots[index];
                return RadioListTile<String>(
                  title: Text(time),
                  value: time,
                  groupValue: selectedTime,
                  activeColor: AppColors.primaryColor,
                  onChanged: (String? value) {
                    setState(() {
                      selectedTime = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmBooking() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Confirming booking...'),
            ],
          ),
        ),
      );

      // Convert cart items to booking services
      List<BookingService> bookingServices = editableCartItems.map((item) => BookingService(
        serviceId: item['id'] ?? '',
        serviceName: item['name'] ?? '',
        category: item['category'] ?? '',
        duration: item['duration'] ?? 0,
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        quantity: item['quantity'] ?? 1,
      )).toList();

      // Create booking object
      Booking booking = Booking(
        id: '',
        userId: 'user123', // Replace with actual user ID from auth
        customerName: customerName,
        services: bookingServices,
        bookingDate: selectedDate,
        bookingTime: selectedTime,
        branch: selectedBranch,
        totalPrice: _calculateTotalPrice(),
        totalDuration: _calculateTotalDuration(),
        status: 'upcoming',
        paymentMethod: selectedPaymentMethod,
        emailConfirmation: emailConfirmation,
        smsConfirmation: smsConfirmation,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save booking to Firebase
      String bookingId = await FirebaseService.createBooking(booking);
      
      // Create booking with ID for notifications
      Booking bookingWithId = booking.copyWith(id: bookingId);
      
      // Send booking confirmation notification
      await NotificationService().sendBookingConfirmationNotification(bookingWithId);
      
      // Clear cart after successful booking
      await FirebaseService.clearCart('user123'); // Replace with actual user ID

      // Close loading dialog
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Confirmed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text('Your booking has been confirmed for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at $selectedTime'),
              const SizedBox(height: 8),
              Text('Booking ID: ${bookingId.substring(0, 8).toUpperCase()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingHistoryScreen()),
                );
              },
              child: const Text('View Bookings'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.popUntil(context, (route) => route.isFirst); // Go to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Failed'),
          content: Text('Failed to confirm booking: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPriceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...editableCartItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    'AED ${item['price']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            )),
            const Divider(thickness: 1, height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    'AED ${_calculateTotalPrice()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!showPromoField)
              TextButton(
                onPressed: () => setState(() => showPromoField = true),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 4),
                    Text('Apply Promo Code'),
                  ],
                ),
              ),
            if (showPromoField)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promoController,
                      decoration: const InputDecoration(
                        hintText: 'Enter promo code',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('👤', 'Name:', customerName, _editName),
            const SizedBox(height: 16),
            _buildBranchSelection(),
            const SizedBox(height: 16),
            _buildDateSelection(),
            const SizedBox(height: 16),
            _buildTimeSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String title, String value, VoidCallback onEdit) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
        ),
        TextButton(
          onPressed: onEdit,
          child: const Text(
            'Change',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption('💳', 'Stripe (Card)', 'Stripe', 'images/stripe_logo.png'),
            const SizedBox(height: 12),
            _buildPaymentOption('📲', 'PayPal', 'PayPal', 'images/paypal.png'),
            const SizedBox(height: 12),
            _buildPaymentOption('💵', 'Cash on Arrival', 'cash'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 8),
                  Text('Add New Card'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String emoji, String title, String value, [String? logoAsset]) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedPaymentMethod == value
              ? AppColors.primaryColor
              : Colors.grey.shade300,
          width: selectedPaymentMethod == value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile(
        title: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
              ),
            ),
            if (logoAsset != null) ...[
              const Spacer(),
              Image.asset(logoAsset, height: 24),
            ],
          ],
        ),
        value: value,
        groupValue: selectedPaymentMethod,
        activeColor: AppColors.primaryColor,
        onChanged: (String? value) {
          setState(() {
            selectedPaymentMethod = value!;
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildConfirmationOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Email Confirmation',
                style: TextStyle(color: AppColors.textColor),
              ),
              subtitle: const Text('Receive booking details via email'),
              value: emailConfirmation,
              activeColor: AppColors.primaryColor,
              onChanged: (value) => setState(() => emailConfirmation = value),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text(
                'SMS Confirmation',
                style: TextStyle(color: AppColors.textColor),
              ),
              subtitle: const Text('Receive booking details via SMS'),
              value: smsConfirmation,
              activeColor: AppColors.primaryColor,
              onChanged: (value) => setState(() => smsConfirmation = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelection() {
    final branches = ['Marina', 'Al Bustan', 'Battuta', 'Muraqabat', 'Tecom'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('📍', style: TextStyle(fontSize: 18)),
            SizedBox(width: 12),
            Text(
              'Select Branch:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: branches.map((branch) {
              final isSelected = selectedBranch == branch;
              final isAvailable = _isBranchAvailable(branch);
              
              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor.withAlpha(20) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        branch,
                        style: TextStyle(
                          fontSize: 16,
                          color: isAvailable ? AppColors.textColor : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (!isAvailable) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock, size: 16, color: Colors.grey),
                      ],
                    ],
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                      : null,
                  onTap: isAvailable
                      ? () {
                          setState(() {
                            selectedBranch = branch;
                          });
                        }
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('📆', style: TextStyle(fontSize: 18)),
            SizedBox(width: 12),
            Text(
              'Select Date:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
              ),
            ),
            trailing: const Icon(Icons.calendar_today, color: AppColors.primaryColor),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    final timeSlots = [
      '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM',
      '04:00 PM', '05:00 PM', '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM', '10:00 PM'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('🕐', style: TextStyle(fontSize: 18)),
            SizedBox(width: 12),
            Text(
              'Select Time:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((time) {
                final isSelected = selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : AppColors.textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  bool _isBranchAvailable(String branch) {
    // For male users, only Marina branch is available
    if (userGender == 'male' && branch != 'Marina') {
      return false;
    }
    return true;
  }

  Widget _buildConfirmButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'CONFIRM & PAY NOW',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '🔒 100% Secure Payments | Powered by Stripe/JazzCash',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.greyColor,
          ),
        ),
      ],
    );
  }
}