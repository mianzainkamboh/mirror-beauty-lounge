import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/models/cart_item.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';
import 'package:mirrorsbeautylounge/services/auth_service.dart';
import 'package:mirrorsbeautylounge/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  bool isLoading = true;
  double totalPrice = 0.0;
  int totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Widget _buildServiceImage(String imageBase64) {
    try {
      // Handle both data URL format and raw base64
      String base64String;
      if (imageBase64.startsWith('data:image/')) {
        base64String = imageBase64.split(',')[1];
      } else {
        base64String = imageBase64;
      }
      
      // Validate base64 string
      if (base64String.isEmpty) {
        return _buildFallbackImage();
      }
      
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      );
    } catch (e) {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.greyColor.withOpacity(0.1),
      child: Icon(
        Icons.spa,
        color: AppColors.primaryColor,
        size: 24,
      ),
    );
  }

  Future<void> _loadCartItems() async {
    try {
      final authService = AuthService();
      final user = authService.currentUser;
      if (user != null) {
        final items = await FirebaseService.getCartItems(user.uid);
        setState(() {
          cartItems = items;
          _calculateTotals();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateTotals() {
    totalPrice = cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    totalDuration = cartItems.fold(0, (sum, item) => sum + (item.duration * item.quantity));
  }

  Widget _buildBookingOptionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: AppColors.greyColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 40 : 48,
              height: isSmallScreen ? 40 : 48,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.greyColor,
              size: isSmallScreen ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: isSmallScreen ? 60 : 80,
                        color: AppColors.greyColor,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Text(
                        'Add some services to get started',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Service Image
                                Container(
                                  width: isSmallScreen ? 60 : 80,
                                  height: isSmallScreen ? 60 : 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greyColor.withOpacity(0.1),
                                  ),
                                  child: ClipOval(
                                    child: item.imageBase64 != null
                                        ? _buildServiceImage(item.imageBase64!)
                                        : Icon(
                                            Icons.spa,
                                            color: AppColors.primaryColor,
                                            size: isSmallScreen ? 24 : 32,
                                          ),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 12 : 16),
                                // Service Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.serviceName,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 4 : 6),
                                      Text(
                                        '${item.duration} min • \$${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          color: AppColors.greyColor,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 8 : 12),
                                      Row(
                                        children: [
                                          // Quantity Controls
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.greyColor.withOpacity(0.3),
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    if (item.quantity > 1) {
                                                      await FirebaseService.updateCartItemQuantity(
                                                        item.id!,
                                                        item.quantity - 1,
                                                      );
                                                      _loadCartItems();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: isSmallScreen ? 16 : 18,
                                                      color: AppColors.textColor,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isSmallScreen ? 12 : 16,
                                                    vertical: isSmallScreen ? 6 : 8,
                                                  ),
                                                  child: Text(
                                                    '${item.quantity}',
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen ? 14 : 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.textColor,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    await FirebaseService.updateCartItemQuantity(
                                                      item.id!,
                                                      item.quantity + 1,
                                                    );
                                                    _loadCartItems();
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: isSmallScreen ? 16 : 18,
                                                      color: AppColors.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          // Remove Button
                                          InkWell(
                                            onTap: () async {
                                              await FirebaseService.removeFromCart(item.id!);
                                              _loadCartItems();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.delete_outline,
                                                size: isSmallScreen ? 18 : 20,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Bottom Summary and Checkout
                    if (cartItems.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Duration:',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                                Text(
                                  '$totalDuration min',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Price:',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                Text(
                                  '\$${totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutScreen(
                                        cartItems: cartItems.map((item) => {
                                          'id': item.id ?? '',
                                          'serviceName': item.serviceName,
                                          'category': item.category,
                                          'duration': item.duration,
                                          'price': item.price,
                                          'quantity': item.quantity,
                                          'imageBase64': item.imageBase64 ?? '',
                                          'name': item.serviceName,
                                          'date': DateTime.now(),
                                          'branch': 'Marina',
                                          'time': '10:00 AM',
                                        }).toList(),
                                        totalPrice: totalPrice,
                                        totalDuration: totalDuration,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 14 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                  ),
                                ),
                                child: Text(
                                  'Proceed to Checkout',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
