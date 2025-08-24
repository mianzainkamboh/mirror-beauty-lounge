import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/services/firebase_service.dart';
import 'package:mirrorsbeautylounge/models/category.dart';
import 'package:mirrorsbeautylounge/models/offer.dart';
import 'package:mirrorsbeautylounge/services_by_category_screen.dart';
import 'package:mirrorsbeautylounge/branches.dart';
import 'package:mirrorsbeautylounge/models/branch.dart';
class WomenServicesScreen extends StatefulWidget {
  final String? categoryName;
  final Offer? preAppliedOffer;
  const WomenServicesScreen({super.key, this.categoryName, this.preAppliedOffer});

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Enhanced responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;
    
    // Dynamic sizing based on screen size
    final horizontalPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 20.0 : 32.0);
    final verticalPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    final titleFontSize = isSmallScreen ? 18.0 : (isMediumScreen ? 22.0 : 26.0);
    final sectionTitleSize = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final searchFontSize = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar - Enhanced responsive design
          SliverAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: isSmallScreen ? 20 : (isMediumScreen ? 24 : 28),
              ),
              color: AppColors.textColor,
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              'For Women',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
                color: AppColors.primaryColor,
              ),
            ),
            backgroundColor: Colors.white.withAlpha(230),
            elevation: 0,
            floating: true,
            snap: true,
            expandedHeight: isSmallScreen ? 56 : (isMediumScreen ? 60 : 64),
          ),

          // Pre-applied Offer Display
          if (widget.preAppliedOffer != null)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding * 0.5
                ),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor.withOpacity(0.1), AppColors.primaryColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: AppColors.primaryColor,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offer Applied: ${widget.preAppliedOffer!.title}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          if (widget.preAppliedOffer!.description.isNotEmpty)
                            Text(
                              widget.preAppliedOffer!.description,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: AppColors.textColor.withOpacity(0.8),
                              ),
                            ),
                          Text(
                            widget.preAppliedOffer!.discountType == 'percentage'
                                ? '${widget.preAppliedOffer!.discountValue.toInt()}% OFF'
                                : 'PKR ${widget.preAppliedOffer!.discountValue.toInt()} OFF',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Branches Section - Enhanced responsive design
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding * 0.75
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branches',
                    style: TextStyle(
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : (isMediumScreen ? 12 : 16)),
                  SizedBox(
                    height: isSmallScreen ? 180 : (isMediumScreen ? 210 : 240),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
                      itemCount: branches.length,
                      itemBuilder: (context, index) => _buildBranchCard(
                        branches[index], 
                        screenWidth, 
                        isSmallScreen, 
                        isMediumScreen
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories Section - Enhanced responsive design
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding * 0.75
              ),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: sectionTitleSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
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
                        fontSize: screenWidth < 360 ? 14 : 16,
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

  Widget _buildBranchCard(Map<String, dynamic> branch, double screenWidth, bool isSmallScreen, bool isMediumScreen) {
    final cardWidth = isSmallScreen ? 140.0 : (isMediumScreen ? 160.0 : 180.0);
    final imageHeight = isSmallScreen ? 100.0 : (isMediumScreen ? 120.0 : 140.0);
    final cardPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    final titleFontSize = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
    final marginRight = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    
    return GestureDetector(
      onTap: () => _navigateToBranchMap(branch['name']),
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: marginRight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isSmallScreen ? 6 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isSmallScreen ? 12 : 16)
              ),
              child: Image.asset(
                branch['image'],
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: imageHeight,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      size: isSmallScreen ? 30 : 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                      color: AppColors.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  // Add location icon to indicate it's tappable
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: isSmallScreen ? 12 : 14,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View on Map',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                preAppliedOffer: widget.preAppliedOffer,
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth < 360 ? 12 : 14,
                          color: AppColors.primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
  }

  void _navigateToCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesByCategoryScreen(
          categoryId: category.id ?? '',
          categoryName: category.name,
          preAppliedOffer: widget.preAppliedOffer,
        ),
      ),
    );
  }

  void _navigateToBranchMap(String branchName) {
    // Map the branch names to the Branch model
    Branch? branch;
    
    switch (branchName) {
      case 'Al Muraqqabat':
        branch = Branch.getBranchById('muraqabat');
        break;
      case 'IBN Battuta Mall':
        branch = Branch.getBranchById('batutta_mall');
        break;
      case 'Marina':
        branch = Branch.getBranchById('marina');
        break;
      case '"Al Bustan':
        branch = Branch.getBranchById('al_bustan');
        break;
      case 'Tecom-Dubai':
        branch = Branch.getBranchById('barsha_heights');
        break;
      default:
        branch = Branch.allBranches.first; // Fallback to first branch
    }
    
    if (branch != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BranchMapScreen(branch: branch!),
        ),
      );
    }
  }

}