import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirrorsbeautylounge/booking_history_screen.dart' show BookingHistoryScreen;
import 'package:mirrorsbeautylounge/chat_screen.dart';
import 'package:mirrorsbeautylounge/service_booking_screen.dart';
import 'package:mirrorsbeautylounge/services/auth_service.dart';
import 'package:mirrorsbeautylounge/services/profile_picture_service.dart';
import 'package:mirrorsbeautylounge/auth_wrapper.dart';
import 'package:mirrorsbeautylounge/edit_profile_screen.dart';
import 'package:mirrorsbeautylounge/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _profilePictureUrl;
  bool _isUploadingPicture = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfilePicture();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _userData = userData;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfilePicture() async {
    try {
      final profilePictureUrl = await ProfilePictureService.getProfilePictureUrl();
      if (mounted) {
        setState(() {
          _profilePictureUrl = profilePictureUrl;
        });
      }
    } catch (e) {
      // Silently handle error - profile picture is optional
      print('Error loading profile picture: $e');
    }
  }

  Future<void> _handleProfilePictureUpload() async {
    try {
      setState(() {
        _isUploadingPicture = true;
      });

      final downloadUrl = await ProfilePictureService.pickAndUploadProfilePicture(context);
      
      if (downloadUrl != null && mounted) {
        setState(() {
          _profilePictureUrl = downloadUrl;
          _isUploadingPicture = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } else {
        setState(() {
          _isUploadingPicture = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPicture = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile picture: ${e.toString()}')),
        );
      }
    }
  }

  void _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show password confirmation dialog for re-authentication
      final password = await showDialog<String>(
        context: context,
        builder: (context) {
          final passwordController = TextEditingController();
          return AlertDialog(
            title: const Text('Confirm Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter your password to confirm account deletion:'),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(passwordController.text),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

      if (password != null && password.isNotEmpty) {
        try {
          // Re-authenticate user first
          await _authService.reauthenticateUser(password);
          // Then delete account
          await _authService.deleteAccount();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting account: ${e.toString()}')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive values based on screen width
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth <= 600;
    final isLargeScreen = screenWidth > 600;
    
    // Responsive padding and spacing
    final horizontalPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 24.0 : 32.0);
    final verticalPadding = isSmallScreen ? 30.0 : (isMediumScreen ? 40.0 : 50.0);
    final cardPadding = isSmallScreen ? 16.0 : 20.0;
    final spacingBetweenElements = isSmallScreen ? 20.0 : 30.0;
    
    // Responsive font sizes
    final nameFontSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
    final loyaltyTitleFontSize = isSmallScreen ? 16.0 : 18.0;
    final loyaltyPointsFontSize = isSmallScreen ? 28.0 : 32.0;
    final redeemFontSize = isSmallScreen ? 14.0 : 16.0;
    
    // Responsive avatar size
    final avatarRadius = isSmallScreen ? 40.0 : 50.0;
    final avatarIconSize = isSmallScreen ? 40.0 : 50.0;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
        children: [
          // Top section
          Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            color: AppColors.primaryColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: isSmallScreen ? 10 : 20),
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData?['name'] ?? 'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Personal Account',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 16),
                  GestureDetector(
                    onTap: _isUploadingPicture ? null : _handleProfilePictureUpload,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.white,
                          child: _isUploadingPicture
                              ? SizedBox(
                                  width: avatarIconSize * 0.6,
                                  height: avatarIconSize * 0.6,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryColor,
                                    ),
                                  ),
                                )
                              : _profilePictureUrl != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: _profilePictureUrl!,
                                        width: avatarRadius * 2,
                                        height: avatarRadius * 2,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Icon(
                                          Icons.person,
                                          size: avatarIconSize,
                                          color: AppColors.primaryColor,
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.person,
                                          size: avatarIconSize,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: avatarIconSize,
                                      color: AppColors.primaryColor,
                                    ),
                        ),
                        if (!_isUploadingPicture)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: isSmallScreen ? 12 : 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
                SizedBox(height: spacingBetweenElements),

                // Loyalty Points Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loyalty Points',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: loyaltyTitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      Row(
                        children: [
                          Text(
                            '0.00',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: loyaltyPointsFontSize,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.star, color: Colors.orangeAccent, size: isSmallScreen ? 24 : 28)
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '(Redeem)',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: redeemFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom section
          Container(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, 
                        vertical: isSmallScreen ? 24 : 40),
                    child: Column(
                      children: [
                        _buildProfileMenuItem(
                          context: context,
                          icon: Icons.person,
                          label: 'Profile',
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            // Refresh user data if profile was updated
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildProfileMenuItem(
                          context: context,
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy policy',
                          onTap: () {
                            // TODO: Navigate to privacy policy screen
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildProfileMenuItem(
                          context: context,
                          icon: Icons.logout,
                          label: 'Logout',
                          onTap: _handleLogout,
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        SizedBox(height: isSmallScreen ? 8 : 10),
                        _buildProfileMenuItem(
                          context: context,
                          icon: Icons.delete_outline,
                          label: 'Delete Account',
                          isDestructive: true,
                          onTap: _handleDeleteAccount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth <= 600;
    
    // Responsive sizes
    final iconSize = isSmallScreen ? 24.0 : 28.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final spacing = isSmallScreen ? 16.0 : 20.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.greyColor,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: isDestructive ? Colors.red : AppColors.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
