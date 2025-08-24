import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/models/offer.dart';
import 'package:mirrorsbeautylounge/models/service.dart';
import 'package:mirrorsbeautylounge/models/branch.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';

import 'package:mirrorsbeautylounge/services/auth_service.dart';
import 'package:mirrorsbeautylounge/checkout_screen.dart';

class OfferServicesScreen extends StatefulWidget {
  final Offer offer;

  const OfferServicesScreen({
    Key? key,
    required this.offer,
  }) : super(key: key);

  @override
  State<OfferServicesScreen> createState() => _OfferServicesScreenState();
}

class _OfferServicesScreenState extends State<OfferServicesScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<Service> _services = [];
  List<Branch> _branches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferData();
  }

  Future<void> _loadOfferData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Debug logging to see what's in the offer
      print('DEBUG: Offer ID: ${widget.offer.id}');
      print('DEBUG: Offer Title: ${widget.offer.title}');
      print('DEBUG: Target Services: ${widget.offer.targetServices}');
      print('DEBUG: Target Branches: ${widget.offer.targetBranches}');
      print('DEBUG: Target Services Length: ${widget.offer.targetServices.length}');
      print('DEBUG: Target Branches Length: ${widget.offer.targetBranches.length}');

      // Load services if targetServices is specified
      if (widget.offer.targetServices.isNotEmpty) {
        try {
          final services = await FirebaseService.getServices();
          _services = services.where((service) => widget.offer.targetServices.contains(service.id)).toList();
          
          // Check if any targeted services were found
          if (_services.isEmpty) {
            throw Exception('No services found for this offer. The targeted services may no longer be available.');
          }
        } catch (e) {
          throw Exception('Failed to load services: ${e.toString()}');
        }
      } else {
        // Load all services if no specific services are targeted
        try {
          final services = await FirebaseService.getServices();
          _services = services;
          
          if (_services.isEmpty) {
            throw Exception('No services are currently available.');
          }
        } catch (e) {
          throw Exception('Failed to load services: ${e.toString()}');
        }
      }

      // Load branches if targetBranches is specified
      try {
        if (widget.offer.targetBranches.isNotEmpty) {
          print('DEBUG: Loading targeted branches: ${widget.offer.targetBranches}');
          _branches = widget.offer.targetBranches
              .map((branchId) => Branch.getBranchById(branchId))
              .where((branch) => branch != null)
              .cast<Branch>()
              .toList();
          
          print('DEBUG: Found ${_branches.length} targeted branches');
          for (var branch in _branches) {
            print('DEBUG: Branch - ID: ${branch.id}, Name: ${branch.name}');
          }
          
          // Check if any targeted branches were found
          if (_branches.isEmpty) {
            throw Exception('No branches found for this offer. The targeted branches may no longer be available.');
          }
        } else {
          print('DEBUG: No target branches specified, loading all branches');
          // Show all branches if no specific branches are targeted
          _branches = Branch.allBranches;
          
          print('DEBUG: Loaded ${_branches.length} total branches');
          
          if (_branches.isEmpty) {
            throw Exception('No branches are currently available.');
          }
        }
      } catch (e) {
        // Don't fail the entire load if branches fail, just show a warning
        print('Warning: Failed to load branches: ${e.toString()}');
        _branches = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  double _calculateDiscountedPrice(double originalPrice) {
    if (widget.offer.discountType == 'percentage') {
      double discountAmount = originalPrice * (widget.offer.discountValue / 100);
      if (widget.offer.maximumDiscountAmount != null) {
        discountAmount = discountAmount > widget.offer.maximumDiscountAmount!
            ? widget.offer.maximumDiscountAmount!
            : discountAmount;
      }
      return originalPrice - discountAmount;
    } else {
      // Fixed discount
      double discountedPrice = originalPrice - widget.offer.discountValue;
      return discountedPrice > 0 ? discountedPrice : 0;
    }
  }

  String _getDiscountText() {
    if (widget.offer.discountType == 'percentage') {
      return '${widget.offer.discountValue.toInt()}% OFF';
    } else {
      return 'AED ${widget.offer.discountValue.toInt()} OFF';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _bookNow(Service service) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final authService = AuthService();
      final user = authService.currentUser;
      if (user == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Please log in to book services'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      final discountedPrice = _calculateDiscountedPrice(service.price);
      
      // Create cart item for checkout without adding to cart
      final cartItem = {
        'id': service.id!,
        'name': service.name,
        'serviceName': service.name,
        'category': service.category,
        'duration': service.duration,
        'price': discountedPrice,
        'description': service.description,
        'imageBase64': service.imageBase64,
        'quantity': 1,
      };

      // Navigate directly to checkout with the service
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen(
              cartItems: [cartItem],
              totalPrice: discountedPrice,
              totalDuration: service.duration,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to proceed to booking';
        
        // Provide more specific error messages
        if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please try logging in again.';
        }
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _bookNow(service),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.offer.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF8F8F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                           color: Colors.grey[600],
                         ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOfferData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Offer Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFFF8F8F), const Color(0xFFFF8F8F).withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8F8F).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getDiscountText(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.local_offer,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.offer.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.offer.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.offer.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Offer validity period
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Valid: ${_formatDate(widget.offer.validFrom)} - ${_formatDate(widget.offer.validTo)}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Available Branches Section
                      if (_branches.isNotEmpty) ...[
                        Text(
                          'Available at these branches:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                           children: _branches.map((branch) {
                             return Container(
                               width: double.infinity,
                               margin: const EdgeInsets.only(bottom: 8),
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: const Color(0xFFFF8F8F).withOpacity(0.05),
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(
                                   color: const Color(0xFFFF8F8F).withOpacity(0.2),
                                 ),
                               ),
                               child: Row(
                                 children: [
                                   Icon(
                                     Icons.location_on,
                                     size: 18,
                                     color: const Color(0xFFFF8F8F),
                                   ),
                                   const SizedBox(width: 8),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           branch.name,
                                           style: const TextStyle(
                                             color: Color(0xFFFF8F8F),
                                             fontWeight: FontWeight.w600,
                                             fontSize: 14,
                                           ),
                                         ),
                                         const SizedBox(height: 2),
                                         Text(
                                           branch.address,
                                           style: TextStyle(
                                             color: Colors.grey[600],
                                             fontSize: 12,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ],
                               ),
                             );
                           }).toList(),
                         ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Services Section
                      Text(
                        'Services with Discount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_services.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.spa_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No services available for this offer',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            final originalPrice = service.price;
                            final discountedPrice = _calculateDiscountedPrice(originalPrice);
                            final savings = originalPrice - discountedPrice;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Blue container removed as requested
                                  // Service card
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      service.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                         color: Colors.black87,
                                                       ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      service.category,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    if (service.description.isNotEmpty) ...[
                                                      const SizedBox(height: 8),
                                                      Text(
                                        service.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  if (savings > 0) ...[
                                                    Text(
                                      'AED ${originalPrice.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                                    const SizedBox(height: 2),
                                                  ],
                                                  Text(
                                                    'AED ${discountedPrice.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFFFF8F8F),
                                                    ),
                                                  ),
                                                  if (savings > 0) ...[
                                                    const SizedBox(height: 2),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'Save AED ${savings.toStringAsFixed(0)}',
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.green,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${service.duration} mins',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const Spacer(),
                                              ElevatedButton(
                                                onPressed: () => _bookNow(service),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFFF8F8F),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                ),
                                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}