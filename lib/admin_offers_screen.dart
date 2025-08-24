import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/models/offer.dart';
import 'package:mirrorsbeautylounge/services/offer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OfferService _offerService = OfferService();
  List<Offer> offers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      final activeOffers = await _offerService.getActiveOffers();
      setState(() {
        offers = activeOffers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load offers: $e';
        isLoading = false;
      });
    }
  }

  void _showCreateOfferDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateOfferDialog(
        onOfferCreated: () {
          _loadOffers();
        },
      ),
    );
  }

  void _showEditOfferDialog(Offer offer) {
    showDialog(
      context: context,
      builder: (context) => CreateOfferDialog(
        offer: offer,
        onOfferCreated: () {
          _loadOffers();
        },
      ),
    );
  }

  Future<void> _deleteOffer(String offerId) async {
    try {
      await _offerService.deleteOffer(offerId);
      _loadOffers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Admin - Offers Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF8F8F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active Offers'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOffersTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOfferDialog,
        backgroundColor: const Color(0xFFFF8F8F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOffersTab() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8F8F),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load offers',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F8F),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No offers created yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first offer to get started!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: const Color(0xFFFF8F8F),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return _buildOfferCard(offer);
        },
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                        offer.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getOfferTypeColor(offer.offerType.name),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          offer.offerType.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditOfferDialog(offer);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(offer);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              offer.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (offer.discountType == 'percentage')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      '${offer.discountValue.toInt()}% OFF',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (offer.discountType == 'fixed')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      'PKR ${offer.discountValue.toInt()} OFF',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (offer.promoCode != null && offer.promoCode!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      'Code: ${offer.promoCode}',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Valid until ${_formatDate(DateTime.parse(offer.validTo))}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: offer.isActive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: offer.isActive ? Colors.green[200]! : Colors.red[200]!,
                    ),
                  ),
                  child: Text(
                    offer.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: offer.isActive ? Colors.green[600] : Colors.red[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Text(
        'Analytics Coming Soon',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  Color _getOfferTypeColor(String offerType) {
    switch (offerType.toLowerCase()) {
      case 'promotional':
        return Colors.purple;
      case 'referral':
        return Colors.blue;
      case 'new_customer':
        return Colors.green;
      case 'seasonal':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(Offer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text('Are you sure you want to delete "${offer.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (offer.id != null) {
                _deleteOffer(offer.id!);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class CreateOfferDialog extends StatefulWidget {
  final Offer? offer;
  final VoidCallback onOfferCreated;

  const CreateOfferDialog({
    Key? key,
    this.offer,
    required this.onOfferCreated,
  }) : super(key: key);

  @override
  State<CreateOfferDialog> createState() => _CreateOfferDialogState();
}

class _CreateOfferDialogState extends State<CreateOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final OfferService _offerService = OfferService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _promoCodeController;
  late TextEditingController _discountValueController;
  late TextEditingController _minOrderAmountController;
  late TextEditingController _maxDiscountAmountController;
  late TextEditingController _maxUsageController;
  late TextEditingController _maxUsagePerUserController;
  
  String _selectedOfferType = 'promotional';
  String _selectedDiscountType = 'percentage';
  String _selectedUserEligibility = 'all';
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isLoading = false;
  
  List<String> _selectedServices = [];
  List<String> _selectedBranches = [];
  
  final List<String> _offerTypes = ['promotional', 'referral', 'new_customer', 'seasonal'];
  final List<String> _discountTypes = ['percentage', 'fixed'];
  final List<String> _userEligibilityOptions = ['all', 'new_customers', 'existing_customers', 'vip_customers'];
  
  final List<String> _availableServices = [
    'Haircut & Styling',
    'Hair Coloring',
    'Facial Treatment',
    'Manicure & Pedicure',
    'Eyebrow Threading',
    'Makeup Application',
    'Hair Treatment',
    'Bridal Package',
  ];
  
  final List<String> _availableBranches = [
    'Main Branch - Gulberg',
    'DHA Branch',
    'Johar Town Branch',
    'Model Town Branch',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.offer != null) {
      _populateFields();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _promoCodeController = TextEditingController();
    _discountValueController = TextEditingController();
    _minOrderAmountController = TextEditingController();
    _maxDiscountAmountController = TextEditingController();
    _maxUsageController = TextEditingController();
    _maxUsagePerUserController = TextEditingController();
  }

  void _populateFields() {
    final offer = widget.offer!;
    _titleController.text = offer.title;
    _descriptionController.text = offer.description;
    _promoCodeController.text = offer.promoCode ?? '';
    _discountValueController.text = offer.discountValue.toString();
    _minOrderAmountController.text = offer.minimumOrderAmount?.toString() ?? '';
    _maxDiscountAmountController.text = offer.maximumDiscountAmount?.toString() ?? '';
    _maxUsageController.text = offer.usageLimit?.toString() ?? '';
    _maxUsagePerUserController.text = offer.maxUsesPerUser?.toString() ?? '';
    
    _selectedOfferType = offer.offerType.name;
    _selectedDiscountType = offer.discountType;
    _selectedUserEligibility = offer.userEligibility.name;
    _validFrom = DateTime.parse(offer.validFrom);
    _validUntil = DateTime.parse(offer.validTo);
    _isActive = offer.isActive;
    _selectedServices = List<String>.from(offer.targetServices);
    _selectedBranches = List<String>.from(offer.targetBranches);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _promoCodeController.dispose();
    _discountValueController.dispose();
    _minOrderAmountController.dispose();
    _maxDiscountAmountController.dispose();
    _maxUsageController.dispose();
    _maxUsagePerUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.offer == null ? 'Create New Offer' : 'Edit Offer',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildDiscountSection(),
                      const SizedBox(height: 24),
                      _buildTargetingSection(),
                      const SizedBox(height: 24),
                      _buildValiditySection(),
                      const SizedBox(height: 24),
                      _buildAdvancedSection(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveOffer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8F8F),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.offer == null ? 'Create Offer' : 'Update Offer',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Offer Title',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter offer title';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter description';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedOfferType,
          decoration: const InputDecoration(
            labelText: 'Offer Type',
            border: OutlineInputBorder(),
          ),
          items: _offerTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.replaceAll('_', ' ').toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedOfferType = value!;
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _promoCodeController,
          decoration: const InputDecoration(
            labelText: 'Promo Code (Optional)',
            border: OutlineInputBorder(),
            hintText: 'e.g., SAVE20, NEWUSER',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Active: '),
            Switch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: const Color(0xFFFF8F8F),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discount Configuration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedDiscountType,
          decoration: const InputDecoration(
            labelText: 'Discount Type',
            border: OutlineInputBorder(),
          ),
          items: _discountTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDiscountType = value!;
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _discountValueController,
          decoration: InputDecoration(
            labelText: _selectedDiscountType == 'percentage' 
                ? 'Discount Percentage' 
                : 'Discount Amount (PKR)',
            border: const OutlineInputBorder(),
            suffixText: _selectedDiscountType == 'percentage' ? '%' : 'PKR',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter discount value';
            }
            final numValue = double.tryParse(value);
            if (numValue == null || numValue <= 0) {
              return 'Please enter a valid positive number';
            }
            if (_selectedDiscountType == 'percentage' && numValue > 100) {
              return 'Percentage cannot exceed 100%';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minOrderAmountController,
                decoration: const InputDecoration(
                  labelText: 'Min Order Amount (PKR)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _maxDiscountAmountController,
                decoration: const InputDecoration(
                  labelText: 'Max Discount (PKR)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Targeting & Eligibility',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedUserEligibility,
          decoration: const InputDecoration(
            labelText: 'User Eligibility',
            border: OutlineInputBorder(),
          ),
          items: _userEligibilityOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option.replaceAll('_', ' ').toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedUserEligibility = value!;
            });
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Target Services (Leave empty for all services)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableServices.map((service) {
            final isSelected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedServices.add(service);
                  } else {
                    _selectedServices.remove(service);
                  }
                });
              },
              selectedColor: const Color(0xFFFF8F8F).withOpacity(0.3),
              checkmarkColor: const Color(0xFFFF8F8F),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Target Branches (Leave empty for all branches)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableBranches.map((branch) {
            final isSelected = _selectedBranches.contains(branch);
            return FilterChip(
              label: Text(branch),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedBranches.add(branch);
                  } else {
                    _selectedBranches.remove(branch);
                  }
                });
              },
              selectedColor: const Color(0xFFFF8F8F).withOpacity(0.3),
              checkmarkColor: const Color(0xFFFF8F8F),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildValiditySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Validity Period',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _validFrom,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _validFrom = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Valid From',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_validFrom.day}/${_validFrom.month}/${_validFrom.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _validUntil,
                    firstDate: _validFrom,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _validUntil = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Valid Until',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_validUntil.day}/${_validUntil.month}/${_validUntil.year}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Usage Limits',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _maxUsageController,
                decoration: const InputDecoration(
                  labelText: 'Max Total Usage',
                  border: OutlineInputBorder(),
                  hintText: 'Leave empty for unlimited',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _maxUsagePerUserController,
                decoration: const InputDecoration(
                  labelText: 'Max Usage Per User',
                  border: OutlineInputBorder(),
                  hintText: 'Leave empty for unlimited',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final offer = Offer(
        id: widget.offer?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        offerType: _selectedOfferType,
        discountType: _selectedDiscountType,
        discountValue: double.parse(_discountValueController.text),
        promoCode: _promoCodeController.text.trim().isEmpty 
            ? null 
            : _promoCodeController.text.trim(),
        validFrom: _validFrom,
        validUntil: _validUntil,
        isActive: _isActive,
        minOrderAmount: _minOrderAmountController.text.isEmpty 
            ? null 
            : double.parse(_minOrderAmountController.text),
        maxDiscountAmount: _maxDiscountAmountController.text.isEmpty 
            ? null 
            : double.parse(_maxDiscountAmountController.text),
        targetServices: _selectedServices.isEmpty ? null : _selectedServices,
        targetBranches: _selectedBranches.isEmpty ? null : _selectedBranches,
        userEligibility: _selectedUserEligibility,
        maxUsage: _maxUsageController.text.isEmpty 
            ? null 
            : int.parse(_maxUsageController.text),
        maxUsagePerUser: _maxUsagePerUserController.text.isEmpty 
            ? null 
            : int.parse(_maxUsagePerUserController.text),
        currentUsage: widget.offer?.currentUsage ?? 0,
        createdAt: widget.offer?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.offer == null) {
        await _offerService.createOffer(offer);
      } else {
        await _offerService.updateOffer(widget.offer!.id, offer.toFirestore());
      }

      Navigator.pop(context);
      widget.onOfferCreated();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.offer == null 
                ? 'Offer created successfully' 
                : 'Offer updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}