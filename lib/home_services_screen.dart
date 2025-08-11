import 'package:flutter/material.dart';

class HomeServicesPage extends StatefulWidget {
  const HomeServicesPage ({super. key});

  @override
  State<HomeServicesPage> createState() => _HomeServicesPageState();
}

class _HomeServicesPageState extends State<HomeServicesPage> {
  String selectedLocation = "Al Muraqqabat";
  final List<String> womenServices = [
    "Hair", "Nails & Extensions", "Spa & Anti-cellulite",
    "Facial", "SMPU", "Wax & Threading",
    "Eyelash & Extensions", "Makeup & Henna", "Hair Extensions"
  ];

  final List<String> menServices = [
    "Hair Cut", "Hair Styling", "Beard Styling",
    "Clean Shave", "Facial", "Hair Treatment"
  ];

  final List<Map<String, dynamic>> bookedServices = [
    {"name": "Mani Pedi", "icon": Icons.spa},
    {"name": "Hair Color", "icon": Icons.color_lens},
    {"name": "Underarm Waxing", "icon": Icons.clean_hands},
    {"name": "Swedish Massage", "icon": Icons.medical_services},
  ];

  final List<Map<String, dynamic>> newServices = [
    {"name": "Anti Cellulite", "icon": Icons.water_drop},
    {"name": "Scalp Micropigmentation", "icon": Icons.brush},
    {"name": "Hair Extension", "icon": Icons.extension},
    {"name": "Microblading", "icon": Icons.face_retouching_natural},
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF8F8F);
    final backgroundColor = const Color(0xFFF5F5F5);
    final darkGrey = const Color(0xFF424242);
    final mediumGrey = const Color(0xFF757575);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                    children: [
                Row(
                children: [
                IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  "Home Services",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
                itemBuilder: (context) => [
                  "Al Muraqqabat",
                  "Downtown",
                  "Jumeirah",
                  "Business Bay"
                ].map((location) => PopupMenuItem(
                  value: location,
                  child: Text(location),
                )).toList(),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      selectedLocation,
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // Fixed: Added comma
              boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
              ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for services",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: mediumGrey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            ],
          ),
        ),

        // Hero Banner
        Stack(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0x99000000), // 60% opacity black
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Best Salon & Home Services in Dubai",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Get pampered from the comfort of your home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    onPressed: () {},
                    child: const Text("Book Now"),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Salon for Women
        _buildSectionHeader("Salon for Women"),
        _buildHorizontalScroll(womenServices),

        // Salon for Men
        _buildSectionHeader("Salon for Men"),
        _buildHorizontalScroll(menServices),

        // Most Booked Services
        _buildSectionHeader("Most Booked Services"),
        _buildServiceCards(bookedServices, primaryColor, mediumGrey),

        // New Services
        _buildSectionHeader("New Services"),
        _buildNewServiceCards(newServices, primaryColor, mediumGrey),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScroll(List<String> services) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // Fixed: Added comma
                boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
                ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.spa, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      services[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
          },
      ),
    );
  }

  Widget _buildServiceCards(List<Map<String, dynamic>> services, Color primaryColor, Color mediumGrey) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // Fixed: Added comma
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(services[index]['icon'], size: 32, color: primaryColor),
                const SizedBox(height: 8),
                Text(
                  services[index]['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: mediumGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 16),
                    const Text("4.8", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewServiceCards(List<Map<String, dynamic>> services, Color primaryColor, Color mediumGrey) {
    final newServiceColor = Color.alphaBlend(
      primaryColor.withAlpha(26),
      Colors.white,
    );

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // Fixed: Added comma
              border: Border.all(color: primaryColor, width: 1.5), // Fixed: Added comma
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(26),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: newServiceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(services[index]['icon'], size: 32, color: primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  services[index]['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: mediumGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "NEW",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}