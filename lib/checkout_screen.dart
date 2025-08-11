import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';

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
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    _getServiceEmoji(item['name']), // FIXED: Removed extra parenthesis
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item['name']} - ${item['time']} (${item['branch']})',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            )), // removed .toList()
            const SizedBox(height: 12),
            Text(
              'Total Duration: ${widget.totalDuration ~/ 60}h ${widget.totalDuration % 60}min',
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
            ...widget.cartItems.map((item) => Padding(
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
                    'AED ${widget.totalPrice}',
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
            _buildInfoRow('👤', 'Name:', 'Maryam'),
            const SizedBox(height: 12),
            _buildInfoRow('📆', 'Date:', 'Today'),
            const SizedBox(height: 12),
            _buildInfoRow('📍', 'Branch:', 'Marina'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String title, String value) {
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
          onPressed: () {},
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

  Widget _buildConfirmButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle payment confirmation
            },
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