import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/booking_history_screen.dart' show BookingHistoryScreen;
import 'package:mirrorsbeautylounge/branch_selection_screen.dart';
import 'package:mirrorsbeautylounge/chat_screen.dart';
import 'package:mirrorsbeautylounge/home_services_screen.dart' show HomeServicesPage;
import 'package:mirrorsbeautylounge/men_services_screen.dart';

import 'package:mirrorsbeautylounge/women_services_screen.dart';
import 'package:mirrorsbeautylounge/notifications_screen.dart';
import 'package:mirrorsbeautylounge/profile_screen.dart';
import 'package:mirrorsbeautylounge/service_booking_screen.dart';
import 'cartscreen.dart';
import 'services/firebase_service.dart';
import 'models/category.dart';
import 'models/offer.dart';
import 'services_by_category_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Category> womenCategories = [];
  List<Category> menCategories = [];
  bool isLoadingCategories = true;
  String? categoriesError;
  
  List<Offer> offers = [];
  bool isLoadingOffers = true;
  String? offersError;

  // Offers are now loaded from Firebase

  final List<Map<String, String>> branches = [
    {
      "image": "images/1.jpeg",
      "title": "Al Muraqqabat",
      "subtitle": "M03-Buhaleeba Plaza, Muraqqabat Road Dubai",
      "tag": "10am to 10pm",
    },
    {
      "image": "images/1.jpg",
      "title": "IBN Battuta Mall",
      "subtitle": "Ibn Battuta Mall, Metro link area, Sheikh Zayed Rd - Dubai",
      "tag": "10am to 10pm",
    },
    {
      "image": "images/4.jpeg",
      "title": "Al Bustan",
      "subtitle": "Al Bustan center, Al Qusais First, Dubai",
      "tag": "10am to 10pm",
    },
    {
      "image": "images/3.jpeg",
      "title": "TECOM",
      "subtitle": "API Building, AL Barsha Heights, Tecom-Dubai",
      "tag": "10am to 10pm",
    },
    {
      "image": "images/5.jpeg",
      "title": "Marina",
      "subtitle": "Jannah Hotel Apartment, Marina, Dubai",
      "tag": "10am to 10pm",
    },
  ];

  final List<Map<String, String>> women_categories = [
    {'title': 'Hair & styling', 'image': 'images/hairs.png'},
    {'title': 'Nails', 'image': 'images/nails.png'},
    {'title': 'Eyebrows & eyelashes', 'image': 'images/eyebrows.png'},
    {'title': 'Massage', 'image': 'images/massage.png'},
    {'title': 'Barbering', 'image': 'images/barbering.png'},
    {'title': 'Waxing', 'image': 'images/waxing.png'},
    {'title': 'Facials & skincare', 'image': 'images/Facial.png'},
    {'title': 'Manicure', 'image': 'images/manicure.png'},
    {'title': 'Pedicure', 'image': 'images/pedicure.png'},
    {'title': 'Hair Extentions', 'image': 'images/extentions.png'},
    {'title': 'Makeup', 'image': 'images/makeup.png'},
    {'title': 'Hair Wash', 'image': 'images/hairwash.png'},
    {'title': 'Microblading', 'image': 'images/microblading.png'},
    {'title': 'Semi Permenant Makeup', 'image': 'images/samipermanent.png'},

  ];
  final List<Map<String, String>> men_categories = [
    {'title': 'Men Hair', 'image': 'images/menhair.png'},
    {'title': 'Men Nails', 'image': 'images/mennail.png'},
    {'title': 'Men Facial', 'image': 'images/menfacial.png'},
    {'title': 'Men Wax', 'image': 'images/menwax.png'},
  ];
  final List<Map<String, String>> womenspa = [
    {"image": "images/relaxationmassage.png", "title": "Relaxation Massage"},
    {"image": "images/painrelief.png", "title": "Pain Relief"},
    {"image": "images/addons.png", "title": "Add Ons"},
    {"image": "images/moroccanbath.png", "title": "Moroccan Bath"},
  ];
  final List<Map<String, String>> menspa = [
    {"image": "images/relaxmasssage.png", "title": "Relaxation Massage"},
    {"image": "images/deepmassage.png", "title": "Deep Massage"},
    {"image": "images/swedishmassage.png", "title": "Swedish Massage"},
    {"image": "images/aromatherapy.png", "title": "Aroma Therapy"},
  ];
  final List<Map<String, String>> spnm = [
    {"image": "images/microblading.png", "title": "Microblading"},
    {"image": "images/microshading.png", "title": "Microshading"},
    {"image": "images/eyeliner.png", "title": "Eyeliner"},
    {"image": "images/lip.png", "title": "Lip Tattoo"},
  ];
  final List<Map<String, String>> homeservices = [
    {"image": "images/hsircut.png", "title": "Hair Cut"},
    {"image": "images/hairwash.png", "title": "Hair Wash"},
    {"image": "images/styling.png", "title": "Styling"},
    {"image": "images/haircolor.png", "title": "Hair Coloring"},
    {"image": "images/makeup.png", "title": "Makeup"},
    {"image": "images/waxing.png", "title": "Waxing"},
  ];
  final List<Map<String, String>> nails= [
    {"image": "images/manicure.png", "title": "Manicure"},
    {"image": "images/pedicure.png", "title": "Pedicure"},
    {"image": "images/kmp.png", "title": "Kids Mani-Pedi"},
    {"image": "images/pcr.png", "title": "Polish Change & Remove"},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadOffers();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        isLoadingCategories = true;
        categoriesError = null;
      });
      
      final categories = await FirebaseService.getCategories();
      
      setState(() {
        womenCategories = categories.where((cat) => cat.gender == 'women').toList();
        menCategories = categories.where((cat) => cat.gender == 'men').toList();
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        categoriesError = 'Failed to load categories: $e';
        isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadOffers() async {
    try {
      setState(() {
        isLoadingOffers = true;
        offersError = null;
      });
      
      final firebaseOffers = await FirebaseService.getOffers();
      
      setState(() {
        offers = firebaseOffers.where((offer) => offer.isActive).toList();
        isLoadingOffers = false;
      });
    } catch (e) {
      setState(() {
        offersError = 'Failed to load offers: $e';
        isLoadingOffers = false;
      });
    }
  }

  Widget _buildOfferImage(String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      if (imageBase64.startsWith('data:image/')) {
        try {
          // Extract base64 string from data URL
          final base64String = imageBase64.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            height: 200,
            width: 320,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'images/salon.png',
                height: 220,
                width: 320,
                fit: BoxFit.cover,
              );
            },
          );
        } catch (e) {
          // If base64 decoding fails, show fallback
          return Image.asset(
            'images/salon.png',
            height: 200,
            width: 320,
            fit: BoxFit.cover,
          );
        }
      } else {
        // Try to decode raw base64 string
        try {
          final bytes = base64Decode(imageBase64);
          return Image.memory(
            bytes,
            height: 200,
            width: 320,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'images/salon.png',
                height: 200,
                width: 320,
                fit: BoxFit.cover,
              );
            },
          );
        } catch (e) {
          // If decoding fails, show fallback
          return Image.asset(
            'images/salon.png',
            height: 200,
            width: 320,
            fit: BoxFit.cover,
          );
        }
      }
    } else {
      // No image provided, show fallback
      return Image.asset(
        'images/salon.png',
        height: 200,
        width: 320,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildOffersSection() {
    if (isLoadingOffers) {
      return Container(
        height: 270,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF8F8F),
          ),
        ),
      );
    }

    if (offersError != null) {
      return Container(
        height: 260,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load offers',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
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
        ),
      );
    }

    if (offers.isEmpty) {
      return Container(
        height: 260,
        child: Center(
          child: Text(
            'No offers available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BranchSelectionScreen()),
        );
      },
      child: SizedBox(
        height: 280,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: offers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final offer = offers[index];
            return Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: _buildOfferImage(offer.imageBase64),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (offer.discountType == 'percentage')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8F8F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${offer.discountValue.toInt()}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (offer.discountType == 'fixed')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8F8F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Save \$${offer.discountValue.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    );
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingHistoryScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleSelection(BuildContext context, String value) {
    if (value == 'Male') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MenServicesScreen()),
      );
    } else if (value == 'Female') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WomenServicesScreen()),
      );
    }
  }

  Widget _buildMainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hey,',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              DropdownButton<String>(
                hint: const Text(
                  "Gender",
                  style: TextStyle(color: Colors.black),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child: Row(
                      children: [
                        Text('Male'),
                        Icon(Icons.male, color: Color(0xFFFF8F8F)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Row(
                      children: [
                        Text('Female'),
                        Icon(Icons.female, color: Color(0xFFFF8F8F)),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _handleSelection(context, value);
                  }
                },
              ),
              SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(),
                    ),
                  );
                },
                child: Icon(Icons.notifications, size: 28),
              ),
              SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(cartItems: []),
                    ),
                  );

                },
                child: Icon(Icons.shopping_cart, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Our Offers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BranchSelectionScreen(),
                    ),
                  );
                },
                child: Text(
                  "See All",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildOffersSection(),
          Row(
            children: [
              const Text(
                'Our Branches',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BranchSelectionScreen(),
                    ),
                  );
                },
                child: Text(
                  "See All",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>BranchSelectionScreen()));},
            child: SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: branches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.asset(
                            branch['image']!,
                            height: 120,
                            width: 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                branch['subtitle']!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  branch['tag']!,
                                  style: const TextStyle(fontSize: 11),
                                ),
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
          ),
          const SizedBox(height: 30),
          Row(
            children: [const Text(
              'Women Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8F8F),
              ),
            ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WomenServicesScreen(),
                    ),
                  );
                },
                child: Text(
                  "See All",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
          ]),
          const SizedBox(height: 16),
          GestureDetector(onTap: (){Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => WomenServicesScreen(),
    ));
    },
            child: isLoadingCategories
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8F8F),
                      ),
                    ),
                  )
                : categoriesError != null
                    ? Center(
                        child: Column(
                          children: [
                            Text(
                              categoriesError!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadCategories,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8F8F),
                              ),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : womenCategories.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'No women categories available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: womenCategories.length,
                            itemBuilder: (context, index) {
                              final category = womenCategories[index];
                              return CategoryCard(
                                title: category.name,
                                image: category.imageBase64 != null 
                                    ? category.imageBase64!
                                    : 'images/salon.png', // fallback image
                                categoryId: category.id ?? '',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServicesByCategoryScreen(
                                        categoryName: category.name,
                                        categoryId: category.id ?? '',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
          const SizedBox(height: 30),
          Row(
              children: [const Text(
                'Men Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenServicesScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(color: Color(0xFFFF8F8F)),
                  ),
                ),
              ]),
          const SizedBox(height: 16),
          GestureDetector(onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenServicesScreen(),
              ));
          },
            child: isLoadingCategories
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8F8F),
                      ),
                    ),
                  )
                : categoriesError != null
                    ? Center(
                        child: Column(
                          children: [
                            Text(
                              categoriesError!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadCategories,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8F8F),
                              ),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : menCategories.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'No men categories available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: menCategories.length,
                            itemBuilder: (context, index) {
                              final category = menCategories[index];
                              return CategoryCard(
                                title: category.name,
                                image: category.imageBase64 != null 
                                    ? category.imageBase64!
                                    : 'images/salon.png', // fallback image
                                categoryId: category.id ?? '',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServicesByCategoryScreen(
                                        categoryName: category.name,
                                        categoryId: category.id ?? '',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
          const SizedBox(height: 30),
          Image.asset("images/spa.png",),
          const SizedBox(height: 30),

          Row(
            children: [
              const Text(
                'Spa For Women',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicesByCategoryScreen(
                        categoryName: 'Massage',
                        categoryId: '',
                      ),
                    ),
                  );
                },
                child: Text(
                  "Book Now",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServicesByCategoryScreen(
                  categoryName: 'Massage',
                  categoryId: '',
                ),
              ));
    },
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: womenspa.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final women = womenspa[index];
                  return Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.asset(
                            women['image']!,
                            height: 120,
                            width: 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            women['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Text(
                'Spa For Men',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicesByCategoryScreen(
                        categoryName: 'Massage',
                        categoryId: '',
                      ),
                    ),
                  );
                },
                child: Text(
                  "Book Now",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => ServicesByCategoryScreen(
      categoryName: 'Massage',
      categoryId: '',
    ),
    ),
    );
    },
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: womenspa.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final mens = menspa[index];
                  return Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.asset(
                            mens['image']!,
                            height: 120,
                            width: 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            mens['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          Image.asset("images/see.png",),
          const SizedBox(height: 30),
          Row(
            children: [
              const Text(
                'Semi Permanent Makeup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicesByCategoryScreen(
                        categoryName: 'Semi Permanent Makeup',
                        categoryId: '',
                      ),
                    ),
                  );
                },
                child: Text(
                  "Book Now",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => ServicesByCategoryScreen(
      categoryName: 'Semi Permanent Makeup',
      categoryId: '',
    ),
    ),
    );
    },
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: spnm.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final spm = spnm[index];
                  return Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.asset(
                            spm['image']!,
                            height: 120,
                            width: 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            spm['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),SizedBox(height: 30,),
          Image.asset("images/salon.png",),
          SizedBox(height: 30,),
          Row(
            children: [
              const Text(
                'Home Services',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeServicesPage(),
                    ),
                  );
                },
                child: Text(
                  "Book Now",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServicesByCategoryScreen(
                  categoryName: 'Massage',
                  categoryId: '',
                ),
              ),
            );
          },
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: homeservices.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final hs = homeservices[index];
                  return Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.asset(
                            hs['image']!,
                            height: 120,
                            width: 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            hs['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),SizedBox(height: 30,),
          Row(
            children: [
              const Text(
                'Nail Services',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8F8F),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicesByCategoryScreen(
                        categoryName: 'Nails',
                        categoryId: '',
                      ),
                    ),
                  );
                },
                child: Text(
                  "Book Now",
                  style: TextStyle(color: Color(0xFFFF8F8F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => ServicesByCategoryScreen(
      categoryName: 'Nails',
      categoryId: '',
    ),
    ),
    );
    },
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nails.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final nail = nails[index];
                  return Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.asset(
                            nail['image']!,
                            height: 120,
                            width: 210,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            nail['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 30,),
          Image.asset("images/promise.png"),
          SizedBox(height: 30,),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child:
            _selectedIndex == 0
                ? _buildMainScreen()
                : Center(child: Text("Screen $_selectedIndex")),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFF8F8F),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final String? categoryId;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.title, 
    required this.image,
    this.categoryId,
    this.onTap,
  });

  Widget _buildImage() {
    // Check if it's an asset image path
    if (image.startsWith('images/')) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 50,
            ),
          );
        },
      );
    }
    
    // Handle base64 data (either with or without data URL prefix)
    try {
      String base64String;
      
      if (image.startsWith('data:image/')) {
        // Extract base64 data from data URL
        final parts = image.split(',');
        if (parts.length != 2) {
          throw Exception('Invalid data URL format');
        }
        base64String = parts[1];
      } else {
        // Assume it's raw base64 data
        base64String = image;
      }
      
      final bytes = base64Decode(base64String);
      
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default image if base64 decoding fails
          return Image.asset(
            'images/salon.png',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 50,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      // If base64 decoding fails, show fallback
      return Image.asset(
        'images/salon.png',
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 50,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xfff7f7f7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
