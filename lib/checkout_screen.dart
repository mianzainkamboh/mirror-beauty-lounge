import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/cartscreen.dart';
import 'package:mirrorsbeautylounge/services_by_category_screen.dart';
import 'package:mirrorsbeautylounge/models/booking.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';
import 'package:mirrorsbeautylounge/services/auth_service.dart';
import 'package:mirrorsbeautylounge/services/notification_service.dart';
import 'package:mirrorsbeautylounge/booking_history_screen.dart';
import 'package:mirrorsbeautylounge/services/stripe_service.dart';
import 'package:mirrorsbeautylounge/services/tamara_service.dart';
import 'package:mirrorsbeautylounge/services/tabby_service.dart';
import 'package:mirrorsbeautylounge/config/tamara_config.dart';
import 'package:mirrorsbeautylounge/config/tabby_config.dart';
import 'package:mirrorsbeautylounge/branches.dart';
import 'package:mirrorsbeautylounge/models/branch.dart';
import 'package:mirrorsbeautylounge/services/offer_service.dart';
import 'package:mirrorsbeautylounge/models/offer.dart';

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
  bool showPromoField = false;
  TextEditingController promoCodeController = TextEditingController();
  String? userGender;
  final AuthService _authService = AuthService();
  final OfferService _offerService = OfferService();
  
  // Promotional code state
  Offer? appliedOffer;
  double discountAmount = 0.0;
  bool isApplyingPromo = false;
  String? promoError;
  
  // Editable booking information
  late List<Map<String, dynamic>> editableCartItems;
  late String customerName;
  late DateTime selectedDate;
  late String selectedBranch;
  late String selectedTime;
  
  // Home services state
  bool isHomeService = false;
  TextEditingController addressController = TextEditingController();
  String? addressError;
  
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
      'category': item['category'] ?? '',
    }).toList();
    
    customerName = 'Guest';
    selectedDate = DateTime.now();
    selectedBranch = 'Marina'; // Default to Marina, user can change
    selectedTime = '10:00 AM'; // Default to first time slot, user can change
    
    _loadUserGender();
    _loadUserName();
    _checkMensServicesAndSetBranch();
  }

  // Check for men's services during initialization and set branch accordingly
  Future<void> _checkMensServicesAndSetBranch() async {
    await _containsMensServices();
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
  
  double _calculateFinalPrice() {
    double basePrice = _calculateTotalPrice();
    return basePrice - discountAmount;
  }

  int _calculateTotalDuration() {
    return editableCartItems.fold(0, (sum, item) => sum + (item['duration'] as int));
  }
  
  // Promotional code methods
  Future<void> _applyPromoCode() async {
    if (promoCodeController.text.trim().isEmpty) {
      setState(() {
        promoError = 'Please enter a promo code';
      });
      return;
    }
    
    setState(() {
      isApplyingPromo = true;
      promoError = null;
    });
    
    try {
      final user = _authService.currentUser;
      final userId = user?.uid;
      
      // Get service names for targeting validation
      final serviceNames = editableCartItems.map((item) => item['name'] as String).toList();
      
      // Validate promo code
      final offer = await _offerService.validatePromoCode(
        promoCodeController.text.trim(),
        userId: userId,
        orderAmount: _calculateTotalPrice(),
      );
      
      if (offer != null) {
        // Apply the offer
        final result = await _offerService.applyOffer(
          offerId: offer.id!,
          orderAmount: _calculateTotalPrice(),
          userId: userId,
        );
        
        if (result['success'] == true) {
          setState(() {
            appliedOffer = offer;
            discountAmount = result['discountAmount'] ?? 0.0;
            promoError = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Promo code applied! You saved AED ${discountAmount.toStringAsFixed(2)}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            promoError = result['error'] ?? 'Failed to apply promo code';
          });
        }
      } else {
        setState(() {
          promoError = 'Invalid or expired promo code';
        });
      }
    } catch (e) {
      setState(() {
        promoError = 'Error applying promo code: ${e.toString()}';
      });
    } finally {
      setState(() {
        isApplyingPromo = false;
      });
    }
  }
  
  void _removePromoCode() {
    setState(() {
      appliedOffer = null;
      discountAmount = 0.0;
      promoCodeController.clear();
      promoError = null;
      showPromoField = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Promo code removed'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
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



  void _showEditServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Services'),
          content: const Text('You can remove services by tapping the remove icon next to each service.'),
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
    print('DEBUG: =========================');
    print('DEBUG: _confirmBooking method started');
    print('DEBUG: Cart items count: ${editableCartItems.length}');
    print('DEBUG: Selected payment method: $selectedPaymentMethod');
    print('DEBUG: Is home service: $isHomeService');
    print('DEBUG: Customer name: $customerName');
    print('DEBUG: Selected date: $selectedDate');
    print('DEBUG: Selected time: $selectedTime');
    print('DEBUG: Selected branch: $selectedBranch');
    
    try {
      // Check if cart is empty
      if (editableCartItems.isEmpty) {
        print('DEBUG: Cart is empty, showing error dialog');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Services Selected'),
            content: const Text('Please add services to your cart before confirming.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      print('DEBUG: Cart validation passed');

      // Validate address if home service is selected
      if (isHomeService) {
        print('DEBUG: Validating home service address');
        print('DEBUG: Address: ${addressController.text.trim()}');
        
        if (addressController.text.trim().isEmpty) {
          print('DEBUG: Address is empty, showing error');
          setState(() {
            addressError = 'Please enter your address for home service';
          });
          return;
        }
        if (addressController.text.trim().length < 10) {
          print('DEBUG: Address too short, showing error');
          setState(() {
            addressError = 'Please provide a more detailed address';
          });
          return;
        }
        print('DEBUG: Address validation passed');
      }

      // Validate total amount is positive
      final totalAmount = _calculateTotalPrice();
      if (totalAmount <= 0) {
        _showErrorDialog('Invalid Order', 'Order total must be greater than zero. Please check your cart.');
        return;
      }
      print('DEBUG: Total amount validation passed: $totalAmount');

      // Show loading dialog
      print('DEBUG: Showing loading dialog');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing payment...'),
            ],
          ),
        ),
      );

      // Handle Stripe payment if selected
      if (selectedPaymentMethod.toLowerCase().contains('stripe')) {
        print('DEBUG: Processing Stripe payment for amount: ${_calculateTotalPrice()}');
        final paymentResult = await StripeService.processPayment(
          amount: _calculateTotalPrice(),
          currency: 'AED',
          customerName: customerName,
          metadata: {
            'booking_date': selectedDate.toIso8601String(),
            'booking_time': selectedTime,
            'branch': selectedBranch,
            'services': editableCartItems.map((item) => item['name']).join(', '),
          },
        );
        
        print('DEBUG: Stripe payment result - Success: ${paymentResult.success}');
        if (!paymentResult.success) {
          print('DEBUG: Stripe payment failed: ${paymentResult.error}');
          // Close loading dialog
          Navigator.pop(context);
          
          // Show payment error
          _showErrorDialog('Payment Failed', paymentResult.error ?? 'Payment was cancelled or failed');
          return;
        }
        print('DEBUG: Stripe payment completed successfully');
      }
      
      // Handle Tamara payment if selected
      if (selectedPaymentMethod.toLowerCase().contains('tamara')) {
        final totalAmount = _calculateTotalPrice();
        
        // Check if order amount is valid for Tamara
        if (!TamaraConfig.isOrderAmountValid(totalAmount)) {
          Navigator.pop(context);
          _showErrorDialog('Payment Error', 
            'Order amount must be between ${TamaraConfig.minimumOrderAmount} and ${TamaraConfig.maximumOrderAmount} AED for Tamara payments');
          return;
        }
        
        try {
          // Format customer info for Tamara
          final customerInfo = TamaraService.formatCustomerInfo(
            firstName: customerName.split(' ').first,
            lastName: customerName.split(' ').length > 1 ? customerName.split(' ').last : '',
            email: 'customer@example.com', // Replace with actual user email
            phone: '+971501234567', // Replace with actual user phone
          );
          
          // Format items for Tamara
          final tamaraItems = TamaraService.formatItems(editableCartItems);
          
          // Create Tamara checkout session
          final tamaraService = TamaraService();
          final checkoutSession = await tamaraService.createCheckoutSession(
            amount: totalAmount,
            currency: 'AED',
            customerInfo: customerInfo,
            items: tamaraItems,
            orderId: 'MBL_${DateTime.now().millisecondsSinceEpoch}',
            successUrl: 'https://mirrorsbeautylounge.com/success',
            cancelUrl: 'https://mirrorsbeautylounge.com/cancel',
          );
          
          if (checkoutSession == null || checkoutSession['checkout_url'] == null) {
            Navigator.pop(context);
            _showErrorDialog('Payment Error', 'Failed to create Tamara checkout session. Please try again.');
            return;
          }
          
          // Launch Tamara checkout with WebView
          final paymentResult = await tamaraService.launchCheckout(
            context: context,
            checkoutUrl: checkoutSession['checkout_url'],
            successUrl: 'https://mirrorsbeautylounge.com/success',
            failureUrl: 'https://mirrorsbeautylounge.com/failure',
            cancelUrl: 'https://mirrorsbeautylounge.com/cancel',
          );
          
          if (paymentResult == null || paymentResult['status'] != 'success') {
            Navigator.pop(context);
            String errorMessage = 'Payment was cancelled or failed';
            if (paymentResult != null && paymentResult['error'] != null) {
              errorMessage = paymentResult['error'];
            }
            _showErrorDialog('Payment Error', 'Tamara payment failed: $errorMessage');
            return;
          }
          
          print('Tamara payment completed successfully: $paymentResult');
          
        } catch (e) {
          Navigator.pop(context);
          _showErrorDialog('Payment Error', 'Tamara payment failed: $e');
          return;
        }
      }
      
      // Handle Tabby payment if selected
      if (selectedPaymentMethod.toLowerCase().contains('tabby')) {
        final totalAmount = _calculateTotalPrice();
        
        // Check if order amount is valid for Tabby
        if (!TabbyConfig.isOrderAmountValid(totalAmount)) {
          Navigator.pop(context);
          _showErrorDialog('Payment Error', 
            'Order amount must be between ${TabbyConfig.minimumOrderAmount} and ${TabbyConfig.maximumOrderAmount} AED for Tabby payments');
          return;
        }
        
        try {
          // Format customer info for Tabby
          final customerInfo = TabbyService.formatCustomerInfo(
            firstName: customerName.split(' ').first,
            lastName: customerName.split(' ').length > 1 ? customerName.split(' ').last : '',
            email: 'customer@example.com', // Replace with actual user email
            phone: '+971501234567', // Replace with actual user phone
          );
          
          // Format items for Tabby - exclude imageBase64 to prevent JSON encoding issues
          final cleanCartItems = editableCartItems.map((item) => {
            'id': item['id'],
            'name': item['name'],
            'price': item['price'],
            'duration': item['duration'],
            'quantity': item['quantity'],
            'category': item['category'],
            // Exclude imageBase64 field to prevent JSON encoding issues
          }).toList();
          final tabbyItems = TabbyService.formatItems(cleanCartItems);
          final orderId = 'MBL_${DateTime.now().millisecondsSinceEpoch}';
          
          // Prepare data for new Tabby API structure
          final buyer = {
            'phone': customerInfo['phone'] ?? '+971501234567',
            'email': customerInfo['email'] ?? 'customer@example.com',
            'name': customerInfo['name'] ?? customerName,
            'dob': customerInfo['dob'] ?? '1990-01-01',
          };
          
          final shippingAddress = {
            'city': customerInfo['city'] ?? 'Dubai',
            'address': customerInfo['address'] ?? 'Dubai, UAE',
            'zip': customerInfo['zip'] ?? '00000',
          };
          
          final order = {
            'updated_at': DateTime.now().toIso8601String(),
            'reference_id': orderId,
            'items': tabbyItems,
          };
          
          final buyerHistory = {
            'registered_since': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
            'loyalty_level': 0,
          };
          
          final orderHistory = {
            'registered_since': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
            'loyalty_level': 0,
            'wishlist_count': 0,
            'is_first_order': false,
            'is_guest_user': false,
          };
          
          final meta = {
            'order_id': orderId,
            'customer': customerInfo['email'] ?? 'customer@example.com',
          };
          
          // Create Tabby checkout session
          final tabbyService = TabbyService();
          final checkoutSession = await tabbyService.createCheckoutSession(
            amount: totalAmount,
            currency: 'AED',
            description: 'Mirror Beauty Lounge Services',
            buyer: buyer,
            shippingAddress: shippingAddress,
            order: order,
            buyerHistory: buyerHistory,
            orderHistory: orderHistory,
            meta: meta,
          );
          
          if (checkoutSession['success'] != true) {
            Navigator.pop(context);
            String errorMessage = 'Failed to create Tabby checkout session. Please try again.';
            if (checkoutSession['error'] != null) {
              errorMessage = checkoutSession['error'];
            }
            print('Tabby checkout session error: ${checkoutSession['details']}');
            _showErrorDialog('Payment Error', errorMessage);
            return;
          }
          
          final checkoutUrl = checkoutSession['checkout_url'];
          if (checkoutUrl == null || checkoutUrl.isEmpty) {
            Navigator.pop(context);
            print('Tabby response data: ${checkoutSession['data']}');
            _showErrorDialog('Payment Error', 'Invalid checkout URL received from Tabby. Please try again.');
            return;
          }
          
          // Launch Tabby checkout with WebView
          final paymentResult = await tabbyService.launchCheckout(
            context: context,
            checkoutUrl: checkoutUrl,
            successUrl: 'https://mirrorsbeautylounge.com/success',
            failureUrl: 'https://mirrorsbeautylounge.com/failure',
            cancelUrl: 'https://mirrorsbeautylounge.com/cancel',
          );
          
          if (paymentResult == null || paymentResult['status'] != 'success') {
            Navigator.pop(context);
            String errorMessage = 'Payment was cancelled or failed';
            if (paymentResult != null && paymentResult['error'] != null) {
              errorMessage = paymentResult['error'];
            }
            _showErrorDialog('Payment Error', 'Tabby payment failed: $errorMessage');
            return;
          }
          
          print('Tabby payment completed successfully: $paymentResult');
          
        } catch (e) {
          Navigator.pop(context);
          _showErrorDialog('Payment Error', 'Tabby payment failed: $e');
          return;
        }
      }

      // Convert cart items to booking services
      List<BookingService> bookingServices = editableCartItems.map((item) => BookingService(
        serviceId: item['id'] ?? '',
        serviceName: item['name'] ?? '',
        category: item['category'] ?? '',
        duration: item['duration'] ?? 0,
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        quantity: item['quantity'] ?? 1,
      )).toList();

      // Get current user ID
      print('DEBUG: Getting current user for booking creation');
      final user = _authService.currentUser;
      if (user == null) {
        print('DEBUG: ERROR - No authenticated user found');
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog('Authentication Error', 'Please log in to complete your booking.');
        return;
      }
      print('DEBUG: User authenticated - UID: ${user.uid}');

      // Create booking object
      Booking booking = Booking(
        id: '',
        userId: user.uid,
        customerName: customerName,
        services: bookingServices,
        bookingDate: selectedDate,
        bookingTime: selectedTime,
        branch: selectedBranch,
        totalPrice: _calculateTotalPrice(),
        totalDuration: _calculateTotalDuration(),
        status: 'upcoming',
        paymentMethod: selectedPaymentMethod,
        emailConfirmation: false,
        smsConfirmation: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        address: isHomeService ? addressController.text.trim() : null,
      );

      // Debug: Log booking creation attempt
      print('DEBUG: ========================');
      print('DEBUG: CheckoutScreen._confirmBooking() called');
      print('DEBUG: Current timestamp: ${DateTime.now()}');
      print('DEBUG: Creating booking for user: ${user.uid}');
      print('DEBUG: Booking data: ${booking.toString()}');
      print('DEBUG: Services count: ${bookingServices.length}');
      
      // Save booking to Firebase
      print('DEBUG: Attempting to save booking to Firebase...');
      print('DEBUG: Booking object details:');
      print('DEBUG: - User ID: ${booking.userId}');
      print('DEBUG: - Customer Name: ${booking.customerName}');
      print('DEBUG: - Services: ${booking.services.map((s) => s.serviceName).join(', ')}');
      print('DEBUG: - Date: ${booking.bookingDate}');
      print('DEBUG: - Time: ${booking.bookingTime}');
      print('DEBUG: - Branch: ${booking.branch}');
      print('DEBUG: - Total Price: ${booking.totalPrice}');
      print('DEBUG: - Status: ${booking.status}');
      print('DEBUG: - CreatedAt: ${booking.createdAt}');
      print('DEBUG: - Address: ${booking.address}');
      
      String bookingId = await FirebaseService.createBooking(booking);
      print('DEBUG: ✅ Booking created successfully with ID: $bookingId');
      print('DEBUG: Booking saved to Firebase with status: ${booking.status}');
      
      // Create booking with ID for notifications
      Booking bookingWithId = booking.copyWith(id: bookingId);
      
      // Send booking confirmation notification
      await NotificationService().sendBookingConfirmationNotification(bookingWithId);
      print('DEBUG: Notification sent for booking: $bookingId');
      
      // Clear cart after successful booking
      await FirebaseService.clearCart(user.uid);
      print('DEBUG: Cart cleared for user: ${user.uid}');

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
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                print('DEBUG: User clicked "View Bookings" button');
                print('DEBUG: Navigating to BookingHistoryScreen after booking creation');
                print('DEBUG: BookingId for reference: $bookingId');
                print('DEBUG: User ID for reference: ${user.uid}');
                
                // Add a small delay to ensure Firebase data is fully committed
                print('DEBUG: Waiting 500ms for Firebase data to be fully committed...');
                await Future.delayed(const Duration(milliseconds: 500));
                print('DEBUG: Delay completed, navigating now...');
                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingHistoryScreen(shouldRefresh: true)),
                );
                print('DEBUG: Navigation to BookingHistoryScreen initiated');
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
      print('DEBUG: ❌ Booking creation failed: $e');
      
      // Close loading dialog if open
      Navigator.pop(context);
      
      // Determine error type and show appropriate message
      String errorTitle = 'Booking Failed';
      String errorMessage = 'Failed to confirm booking';
      
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorTitle = 'Connection Error';
        errorMessage = 'Please check your internet connection and try again.';
      } else if (e.toString().contains('permission') || e.toString().contains('auth')) {
        errorTitle = 'Authentication Error';
        errorMessage = 'Please log out and log back in, then try again.';
      } else if (e.toString().contains('Firebase') || e.toString().contains('firestore')) {
        errorTitle = 'Database Error';
        errorMessage = 'Our servers are temporarily unavailable. Please try again in a few moments.';
      } else {
        errorMessage = 'An unexpected error occurred: ${e.toString()}';
      }
      
      // Show enhanced error dialog with retry option
      _showEnhancedErrorDialog(errorTitle, errorMessage);
    }
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showEnhancedErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'What you can try:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Check your internet connection'),
            const Text('• Try again in a few moments'),
            const Text('• Restart the app if the problem persists'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry booking after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                _confirmBooking();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  'AED ${_calculateTotalPrice().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            // Discount (if applied)
            if (appliedOffer != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Discount (',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        appliedOffer!.promoCode ?? appliedOffer!.title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '):',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '-AED ${discountAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _removePromoCode,
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
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
                    'AED ${_calculateFinalPrice().toStringAsFixed(2)}',
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
            if (!showPromoField && appliedOffer == null)
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
            if (showPromoField) ...[
              if (promoError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          promoError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promoCodeController,
                      enabled: appliedOffer == null && !isApplyingPromo,
                      decoration: InputDecoration(
                        hintText: 'Enter promo code',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        suffixIcon: appliedOffer != null
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: appliedOffer != null || isApplyingPromo || promoCodeController.text.trim().isEmpty
                        ? null
                        : _applyPromoCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                    ),
                    child: isApplyingPromo
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(appliedOffer != null ? 'Applied' : 'Apply'),
                  ),
                ],
              ),
            ],
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
            _buildPaymentOption('💳', 'Card', 'Stripe'),
            const SizedBox(height: 12),
            _buildPaymentOption('🛍️', 'Tabby - Buy Now, Pay Later', 'Tabby'),
            const SizedBox(height: 12),
            _buildPaymentOption('💰', 'Tamara - Split in 4 payments', 'Tamara'),
            const SizedBox(height: 12),
            _buildPaymentOption('💵', 'Cash on Arrival', 'cash'),
            const SizedBox(height: 16),
            // OutlinedButton(
            //   onPressed: () {},
            //   style: OutlinedButton.styleFrom(
            //     foregroundColor: AppColors.primaryColor,
            //     side: BorderSide(color: AppColors.primaryColor),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   child: const Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.add, size: 18),
            //       SizedBox(width: 8),
            //       Text('Add New Card'),
            //     ],
            //   ),
            // ),
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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            if (logoAsset != null) ...[
              const SizedBox(width: 8),
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
              'Select Service Location:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<bool>(
          future: _containsMensServices(),
          builder: (context, snapshot) {
            final hasMensServices = snapshot.data ?? false;
            
            return Column(
              children: [
                if (hasMensServices) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryColor.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Men services are only available at Marina branch or Home Services',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Home Services Option
                      Container(
                        decoration: BoxDecoration(
                          color: isHomeService ? AppColors.primaryColor.withAlpha(20) : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              const Icon(Icons.home, size: 20, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Home Services',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textColor,
                                  fontWeight: isHomeService ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          trailing: isHomeService
                              ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              isHomeService = true;
                              selectedBranch = 'Home Service';
                              addressError = null;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                      ),
                      const Divider(height: 1),
                      // Branch Options
                      ...branches.map((branch) {
                        final isSelected = !isHomeService && selectedBranch == branch;
                        final isAvailable = !hasMensServices || branch == 'Marina';
                        
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
                                      isHomeService = false;
                                      selectedBranch = branch;
                                      addressController.clear();
                                      addressError = null;
                                    });
                                    
                                    // Branch selected directly without navigation
                                  }
                                : () {
                                    // Show restriction message when trying to select unavailable branch
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Men services are only available at Marina branch or Home Services'),
                                        backgroundColor: AppColors.primaryColor,
                                      ),
                                    );
                                  },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                // Address Input for Home Services
                if (isHomeService) ...[
                  const SizedBox(height: 16),
                  _buildAddressInput(),
                ],
              ],
            );
          },
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

  // Check if selected services contain men's services
  Future<bool> _containsMensServices() async {
    try {
      print('=== DEBUG: _containsMensServices called ===');
      print('Cart items count: ${editableCartItems.length}');
      
      for (int i = 0; i < editableCartItems.length; i++) {
        var item = editableCartItems[i];
        String categoryName = item['category'] ?? '';
        print('Item $i: category name = "$categoryName"');
        print('Item $i: full item data = $item');
        
        final category = await FirebaseService.getCategoryByName(categoryName);
        print('Item $i: Firebase category result = $category');
        
        if (category != null) {
          print('Item $i: category.gender = "${category.gender}"');
          if (category.gender == 'men') {
            print('=== FOUND MEN\'S SERVICE! Auto-setting branch to Marina ===');
            // Automatically set branch to Marina for men's services
            setState(() {
              selectedBranch = 'Marina';
            });
            return true;
          }
        } else {
          print('Item $i: Category not found in Firebase for name "$categoryName"');
        }
      }
      
      print('=== No men\'s services found, returning false ===');
      return false;
    } catch (e) {
      print('Error checking men\'s services: $e');
      return false;
    }
  }

  // Check if branch is available based on selected services
  Future<bool> _isBranchAvailable(String branch) async {
    // If services contain men's services, only Marina branch is available
    bool hasMensServices = await _containsMensServices();
    if (hasMensServices && branch != 'Marina') {
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
      ],
    );
  }

  // Branch selection is now handled directly without navigation

  Widget _buildAddressInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, size: 20, color: AppColors.primaryColor),
              SizedBox(width: 8),
              Text(
                'Enter Your Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your full address including building, street, area, and landmarks...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              errorText: addressError,
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (value) {
              if (addressError != null) {
                setState(() {
                  addressError = null;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide a detailed address for accurate service delivery',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}