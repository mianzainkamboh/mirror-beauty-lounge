import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/albustan_map_screen.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';
import 'package:mirrorsbeautylounge/models/category.dart';
import 'package:mirrorsbeautylounge/services_by_category_screen.dart';
class MenServicesScreen extends StatefulWidget {
  final String? categoryName;
  const MenServicesScreen({super.key, this.categoryName});

  @override
  State<MenServicesScreen> createState() => _MenServicesScreenState();
}

class _MenServicesScreenState extends State<MenServicesScreen> {
  // Branch data
  final Map<String, dynamic> branch = {
    'name': 'Marina Branch',
    'image': 'images/5.jpeg',
    'address': 'Jannah Hotel Apartment, Marina, Dubai',
  };

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
        // Filter categories for men
        categories = fetchedCategories.where((category) => 
          category.gender == 'men' || category.gender == 'unisex'
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textColor,
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              'For Men',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth < 360 ? 18 : 22,
                color: AppColors.primaryColor,
              ),
            ),
            backgroundColor: Colors.white.withAlpha(230),
            elevation: 0,
            floating: true,
            snap: true,
          ),

          // Branch Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 360 ? 16 : 24, 
                vertical: screenWidth < 360 ? 12 : 16
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branch',
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: screenWidth < 360 ? 12 : 16),
                  _buildBranchCard(screenWidth),
                ],
              ),
            ),
          ),

          // Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 360 ? 16 : 24
              ),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: screenWidth < 360 ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),

          // Categories Grid
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Center(
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 14 : 16,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(screenWidth < 360 ? 16 : 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth < 360 ? 1 : 2,
                  crossAxisSpacing: screenWidth < 360 ? 12 : 16,
                  mainAxisSpacing: screenWidth < 360 ? 12 : 16,
                  childAspectRatio: screenWidth < 360 ? 1.2 : 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCategoryCard(categories[index], screenWidth),
                  childCount: categories.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(double screenWidth) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (context)=>BranchMapScreen()));
        },
        child: Padding(
          padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                  branch['image'],
                  width: screenWidth < 360 ? screenWidth * 0.8 : 310,
                  height: screenWidth < 360 ? 120 : 160,
                  fit: BoxFit.cover,
              ),
              SizedBox(height: screenWidth < 360 ? 12 : 16),
              Text(
                branch['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 16 : 18,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: screenWidth < 360 ? 6 : 8),
              Text(
                branch['address'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth < 360 ? 12 : 14,
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(String? imageBase64, double screenWidth) {
    final imageSize = screenWidth < 360 ? 100.0 : 120.0;
    
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
        return ClipOval(
          child: Image.memory(
            bytes,
            height: imageSize,
            width: imageSize,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackImage(screenWidth);
            },
          ),
        );
      } catch (e) {
        return _buildFallbackImage(screenWidth);
      }
    } else {
      return _buildFallbackImage(screenWidth);
    }
  }

  Widget _buildFallbackImage(double screenWidth) {
    final imageSize = screenWidth < 360 ? 100.0 : 120.0;
    
    return ClipOval(
      child: Container(
        height: imageSize,
        width: imageSize,
        color: Colors.grey[300],
        child: Icon(
          Icons.spa,
          color: Colors.grey,
          size: screenWidth < 360 ? 40 : 50,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, double screenWidth) {
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
              padding: EdgeInsets.all(screenWidth < 360 ? 6 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: _buildCategoryImage(category.imageBase64, screenWidth),
                    ),
                  ),
                  SizedBox(height: screenWidth < 360 ? 6 : 8),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 13 : 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (category.serviceCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? 6 : 8, 
                    vertical: screenWidth < 360 ? 3 : 4
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.serviceCount}',
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 9 : 10,
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
