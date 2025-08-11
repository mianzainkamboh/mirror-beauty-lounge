import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/login_screen.dart';
import 'package:mirrorsbeautylounge/signup_screen.dart';
import 'home.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'images/1.jpg',
      'headline': '5 branches across Dubai – beauty at your convenience.',
      'subtext': 'From Jumeirah to Downtown, you’re always close to luxury.',
    },
    {
      'image': 'images/home_services.png',
      'headline': 'Bringing beauty to your doorstep',
      'subtext':
          'At Mirror Beauty Lounge, we understand that comfort and convenience matter. '
          'Our professional beauticians are ready to pamper you in the comfort of your home '
          '— whether it’s a bridal makeover, skincare treatment, or a relaxing massage.'
          ' Just book your service, sit back, and let us handle the glam!',
    },
    {
      'image': 'images/unwind.jpg',
      'headline': 'Unwind. Refresh. Glow',
      'subtext':
          'Indulge in relaxing spa treatments and premium salon services.',
    },
    {
      'image': 'images/male.png',
      'headline': 'More Than Just a Haircut',
      'subtext':
          'Indulge in a complete grooming experience — '
          'refreshing facials, expert trims, stress-relieving massages, and more. '
          'All in a calm, masculine space.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = onboardingData[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(color: Color(0xFF0D1C45)),
                        ),
                        TextSpan(
                          text: 'Mirror Beauty Lounge',
                          style: TextStyle(color: Color(0xFFFF8F8F)),
                        ),
                        TextSpan(
                          text: '!',
                          style: TextStyle(color: Color(0xFF0D1C45)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mirrors – Reflecting Your Beauty \nIndulge in self-care and confidence.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF0D1C45), fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // PageView for images
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    onboardingData[index]['image']!,
                    width: 220,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Dynamic Headline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                '“${current['headline']}”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1C45),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Dynamic Subtext
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Text(
                current['subtext']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFFFF8F8F)),
              ),
            ),

            const Spacer(),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => _buildDot(index == _currentPage),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          // MaterialPageRoute(builder: (context) =>  LoginScreen()),
                          MaterialPageRoute(builder: (context) =>  SignupScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F8F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Get started',
                        style: TextStyle(fontSize: 18, color: Color(0xFF0D1C45)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: active ? 20 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0D1C45) : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
