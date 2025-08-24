import 'package:flutter/material.dart';
import 'models/offer.dart';
import 'services/firebase_service.dart';
import 'offer_services_screen.dart';
import 'dart:convert';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Offer> offers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final firebaseOffers = await FirebaseService.getOffers();
      final now = DateTime.now();
      
      setState(() {
        offers = firebaseOffers.where((offer) {
          if (!offer.isActive) return false;
          
          // Check if offer is within valid date range
          try {
            final validFrom = DateTime.parse(offer.validFrom);
            final validTo = DateTime.parse(offer.validTo);
            
            // Offer is valid if current date is between validFrom and validTo (inclusive)
            return now.isAfter(validFrom.subtract(const Duration(days: 1))) && 
                   now.isBefore(validTo.add(const Duration(days: 1)));
          } catch (e) {
            // If date parsing fails, don't show the offer
            return false;
          }
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildOfferImage(String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      // Handle data URL format (data:image/...)
      if (imageBase64.startsWith('data:image/')) {
        try {
          // Extract base64 string from data URL
          final parts = imageBase64.split(',');
          if (parts.length < 2) {
            print('Invalid data URL format: missing comma separator');
            return _buildFallbackImage();
          }
          final base64String = parts[1];
          final bytes = base64Decode(base64String);
          return Container(
            height: 200,
            width: double.infinity,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                print('Error displaying data URL image: $error');
                return _buildFallbackImage();
              },
            ),
          );
        } catch (e) {
          print('Error decoding data URL image: $e');
          return _buildFallbackImage();
        }
      } else {
        // Handle raw base64 string
        try {
          final bytes = base64Decode(imageBase64);
          if (bytes.isNotEmpty) {
            return Container(
              height: 200,
              width: double.infinity,
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  print('Error displaying raw base64 image: $error');
                  return _buildFallbackImage();
                },
              ),
            );
          }
        } catch (e) {
          print('Error decoding raw base64 image: $e');
          print('Base64 length: ${imageBase64.length}');
          print('Base64 preview: ${imageBase64.substring(0, imageBase64.length > 50 ? 50 : imageBase64.length)}...');
        }
      }
    }

    // Return fallback image when no valid image data is available
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF8F8F).withOpacity(0.8),
            const Color(0xFFFF8F8F).withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer,
              size: 48,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              'Special Offer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOfferServices(Offer offer) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfferServicesScreen(offer: offer),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load offer details: ${e.toString()}'),
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
          'Special Offers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF8F8F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF8F8F),
              ),
            )
          : error != null
              ? Center(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : offers.isEmpty
                  ? Center(
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
                            'No offers available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for exciting deals!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOffers,
                      color: const Color(0xFFFF8F8F),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                _navigateToOfferServices(offer);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: _buildOfferImage(offer.imageBase64),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                offer.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Color(0xFF333333),
                                                ),
                                              ),
                                            ),
                                            if (offer.discountType == 'percentage')
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF8F8F),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${offer.discountValue.toInt()}% OFF',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            if (offer.discountType == 'fixed')
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF8F8F),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'Save AED ${offer.discountValue.toInt()}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          offer.description,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.grey[500],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Valid until ${offer.endDate.day}/${offer.endDate.month}/${offer.endDate.year}',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.green[200]!,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 16,
                                                    color: Colors.green[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Active',
                                                    style: TextStyle(
                                                      color: Colors.green[600],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _navigateToOfferServices(offer);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFF8F8F),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Book Now',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}