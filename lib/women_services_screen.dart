import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';
import 'package:mirrorsbeautylounge/models/category.dart';
import 'package:mirrorsbeautylounge/services_by_category_screen.dart';
class AppColors {
  static const primaryColor = Color(0xFFFF8F8F); // #ff8f8f
  static const textColor = Color(0xFF333333);    // Dark gray
  static const greyColor = Color(0xFF888888);    // Medium gray
  static const lightPink = Color(0xFFFEE7E7);    // Light blush
  static const lightLavender = Color(0xFFF2E7FE); // Light lavender
  static const lightGray = Color(0xFFF5F5F5);
  static const background = Color(0xFFF5F5F5);  // Light gray background
}
class WomenServicesScreen extends StatefulWidget {
  const WomenServicesScreen({super.key});

  @override
  State<WomenServicesScreen> createState() => _WomenServicesScreenState();
}

class _WomenServicesScreenState extends State<WomenServicesScreen> {
  // Sample branch data
  final List<Map<String, dynamic>> branches = [
    {'name': 'Al Muraqqabat', 'image': 'images/1.jpeg',},
    {'name': 'IBN Battuta Mall', 'image': 'images/1.jpg'},
    {'name': 'Marina', 'image': 'images/4.jpeg'},
    {'name': '"Al Bustan', 'image': 'images/3.jpeg'},
    {'name': 'Tecom-Dubai', 'image': 'images/5.jpeg'},
  ];

  // Firebase categories
  List<Category> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final fetchedCategories = await FirebaseService.getCategories();
      
      setState(() {
        // Filter categories for women
        categories = fetchedCategories.where((category) => 
          category.gender == 'women' || category.gender == 'unisex'
        ).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load categories: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar - Removed search icon
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textColor,
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              'For Women',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.primaryColor, // Changed to primary color
              ),
            ),
            backgroundColor: Colors.white.withAlpha(230),
            elevation: 0,
            floating: true,
            snap: true,
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ),

          // Branches Section - Changed title color
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor, // Changed to primary color
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: branches.length,
                      itemBuilder: (context, index) =>
                          _buildBranchCard(branches[index]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Services Section
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            )
          else if (error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCategories,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (categories.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Center(
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCategoryCard(categories[index]),
                  childCount: categories.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to branch services
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  branch['image'],
                  width: 180,
                  height: 135,
                  fit: BoxFit.cover,

                ),),
              const SizedBox(height: 16),
              Text(
                branch['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        // Handle both data URL format and raw base64
        String base64String;
        if (imageBase64.startsWith('data:image/')) {
          base64String = imageBase64.split(',')[1];
        } else {
          base64String = imageBase64;
        }
        
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 120,
          width: 210,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      } catch (e) {
        return _buildFallbackImage();
      }
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 120,
      width: 210,
      color: Colors.grey[300],
      child: const Icon(
        Icons.spa,
        color: Colors.grey,
        size: 50,
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: _buildCategoryImage(category.imageBase64),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (category.serviceCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.serviceCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}