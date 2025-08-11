import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/booking_history_screen.dart' show BookingHistoryScreen;
import 'package:mirrorsbeautylounge/chat_screen.dart';
import 'package:mirrorsbeautylounge/service_booking_screen.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFFFF8F8F),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF8F8F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const ProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppColors {
  static const primaryColor = Color(0xFFFF8F8F);
  static const textColor = Color(0xFF333333);
  static const greyColor = Color(0xFF888888);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            color: AppColors.primaryColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Personal Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryColor,
                      ),
                    ),


                ]),
                const SizedBox(height: 30),

                // Loyalty Points Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loyalty Points',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text(
                            '0.00',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.star, color: Colors.orangeAccent, size: 28)
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '(Redeem)',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,

                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: Column(
                      children: [
                        _buildProfileMenuItem(
                          icon: Icons.person,
                          label: 'Profile',

                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _buildProfileMenuItem(
icon:Icons.privacy_tip_outlined,
                          label: 'Privacy policy',
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _buildProfileMenuItem(
icon: Icons.logout,                          label: 'Logout',
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 10),
                        _buildProfileMenuItem(
icon: Icons.delete_outline,                          label: 'Delete Account',
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ✅ Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) =>  HomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) =>  ChatScreen()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) =>  BookingHistoryScreen()));
          } else if (index == 3) {
            // Already on Profile
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.greyColor,
          size: 28,
        ),
        const SizedBox(width: 20),
        GestureDetector(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: isDestructive ? Colors.red : AppColors.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

      ],
    );
  }
}
