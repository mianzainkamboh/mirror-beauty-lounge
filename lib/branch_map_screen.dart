import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';

class BranchMapScreen extends StatefulWidget {
  const BranchMapScreen({super.key});

  @override
  State<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends State<BranchMapScreen> {
  // Sample branch data
  final List<Map<String, dynamic>> branches = [
    {
      'name': 'Marina Branch',
      'address': '123 Beach Road, Marina',
      'hours': '9:00 AM - 10:00 PM',
      'phone': '+92 300 1234567',
      'coordinates': [24.8607, 67.0011],
      'isOpen': true,
    },
    {
      'name': 'City Center',
      'address': '456 Downtown Street',
      'hours': '8:00 AM - 9:00 PM',
      'phone': '+92 300 7654321',
      'coordinates': [24.8924, 67.0280],
      'isOpen': true,
    },
    {
      'name': 'Hillside Plaza',
      'address': '789 Mountain View',
      'hours': '10:00 AM - 8:00 PM',
      'phone': '+92 300 1122334',
      'coordinates': [24.9350, 67.0950],
      'isOpen': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top App Bar
          _buildAppBar(),

          // Map Placeholder (User will replace with actual map)
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined, size: 64, color: AppColors.primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Map Will Appear Here',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Replace this container with your map implementation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Branch List
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Branches',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: branches.length,
                    itemBuilder: (context, index) => _buildBranchCard(branches[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        'Branch Locations',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.textColor,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          color: AppColors.primaryColor,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          color: AppColors.primaryColor,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: const Icon(Icons.location_on, size: 32, color: AppColors.primaryColor),
        title: Text(
          branch['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              branch['address'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.greyColor),
                const SizedBox(width: 4),
                Text(
                  branch['hours'],
                  style: TextStyle(fontSize: 13, color: AppColors.greyColor),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: branch['isOpen'] ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    branch['isOpen'] ? 'OPEN NOW' : 'CLOSED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: branch['isOpen'] ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.directions, color: AppColors.primaryColor),
          onPressed: () {
            // Open directions to this branch
          },
        ),
        onTap: () {
          // Center map on this branch
        },
      ),
    );
  }
}