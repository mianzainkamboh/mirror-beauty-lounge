import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/branches.dart';
import 'package:mirrorsbeautylounge/models/branch.dart';

class BranchSelectionScreen extends StatefulWidget {
  const BranchSelectionScreen({super.key});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  // Sample branch data
  final List<Map<String, dynamic>> branches = [
    {
      "image": "images/6.jpg",
      'name': 'Al Muraqqabat',
      'address': 'M03-Buhaleeba Plaza, Muraqqabat Road Dubai',
      'timings': '10:00 AM - 10:00 PM',
      'maleServices': false,
      'femaleServices': true,
      'selected': false,
    },
    {
      "image": "images/1.jpg",
      'name': 'IBN Battuta Mall',
      'address': 'Ibn Battuta Mall, Metro link area, Sheikh Zayed Rd - Dubai',
      'timings': '10:00 AM - 10:00 PM',
      'maleServices': false,
      'femaleServices': true,
      'selected': false,
    },
    {
      "image": "images/8.jpg",
      'name': 'Al Bustan',
      'address': 'Al Bustan center, Al Qusais First, Dubai',
      'timings': '10:00 AM - 10:00 PM',
      'maleServices': false,
      'femaleServices': true,
      'selected': false,
    },
    {
      "image": "images/9.jpg",
      'name': 'Marina',
      'address': 'Jannah Hotel Apartment, Marina, Dubai',
      'timings': '10:00 AM - 10:00 PM',
      'maleServices': true,
      'femaleServices': true,
      'selected': false,
    },
    {
      "image": "images/2.jpg",
      'name': 'TECOM',
      'address': 'API Building, AL Barsha Heights, Tecom-Dubai',
      'timings': '10:00 AM - 10:00 PM',
      'maleServices': false,
      'femaleServices': true,
      'selected': false,
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredBranches = branches.where((branch) {
      return branch['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 28, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Choose Your Branch',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search bar
            _buildSearchBar(),
            const SizedBox(height: 20),

            // Branch list
            Expanded(
              child: ListView.builder(
                itemCount: filteredBranches.length,
                itemBuilder: (context, index) {
                  final branch = filteredBranches[index];
                  return _buildBranchCard(branch, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search branches...',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: branch['selected']
            ? const Color(0x1AFF8F8F) // Fixed: Use hex value for 10% opacity of primary color
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.asset("images/1.jpg"),
            // Branch name with icon
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                branch['image']!,
                // height: 120,
                // width: 210,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.business, size: 20, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  branch['name'],
                  style: TextStyle(
                    color: branch['selected'] ? AppColors.primaryColor : AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Address
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.greyColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch['address'],
                    style: TextStyle(
                      color: branch['selected'] ? AppColors.primaryColor : AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Timings
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.greyColor),
                const SizedBox(width: 8),
                Text(
                  branch['timings'],
                  style: TextStyle(
                    color: branch['selected'] ? AppColors.primaryColor : AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Services availability
            Row(
              children: [
                _buildServiceIndicator('Male', branch['maleServices']),
                const SizedBox(width: 16),
                _buildServiceIndicator('Female', branch['femaleServices']),
                const Spacer(),

                // Select button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Deselect all others
                      for (var b in branches) {
                        b['selected'] = false;
                      }
                      branch['selected'] = true;
                    });
                    _navigateToBranchMap(branch['name']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: branch['selected'] ? AppColors.primaryColor : Colors.white,
                    foregroundColor: branch['selected'] ? Colors.white : AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppColors.primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(branch['selected'] ? 'Selected' : 'View Location'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to branch map screen with selected branch data
  void _navigateToBranchMap(String branchName) {
    // Map branch names to match the Branch model
    String mappedBranchName;
    switch (branchName) {
      case 'Marina':
        mappedBranchName = 'Marina';
        break;
      case 'Al Bustan':
        mappedBranchName = 'Al Bustan Centre';
        break;
      case 'IBN Battuta Mall':
        mappedBranchName = 'Batutta Mall';
        break;
      case 'Al Muraqqabat':
        mappedBranchName = 'Muraqabat';
        break;
      case 'TECOM':
        mappedBranchName = 'Barsha Heights';
        break;
      default:
        mappedBranchName = branchName;
    }

    // Find the branch from the Branch model
    final branch = Branch.getBranchByName(mappedBranchName);
    
    if (branch != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BranchMapScreen(branch: branch),
        ),
      );
    } else {
      // Show error if branch not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Branch location not available for $branchName'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildServiceIndicator(String label, bool available) {
    return Row(
      children: [
        Icon(
          label == 'Male' ? Icons.man : Icons.woman,
          size: 16,
          color: available ? AppColors.primaryColor : AppColors.greyColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: available ? AppColors.textColor : AppColors.greyColor,
            fontWeight: available ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          available ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: available ? AppColors.primaryColor : AppColors.greyColor,
        ),
      ],
    );
  }
}