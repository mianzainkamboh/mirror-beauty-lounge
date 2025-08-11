import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/home.dart';
import 'phone_input.dart';
import 'social_button.dart';
import 'constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNumber = '';
  final String countryCode = 'United Kingdom (+44)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Log in or sign up to Mirrors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 30),

            PhoneInputField(
              countryCode: countryCode,
              onChanged: (value) => setState(() => phoneNumber = value),
            ),

            const SizedBox(height: 16),
            const Text(
              "We'll call or text you to confirm your number. Standard message and data rates apply.",
              style: TextStyle(color: AppColors.greyColor, fontSize: 14),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: phoneNumber.isEmpty ? null : () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) =>  HomePage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or', style: TextStyle(color: Colors.grey.shade600)),
                ),
                const Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 24),

            SocialButton(
              icon: Icons.email,
              text: 'Continue with Email',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SocialButton(
              icon: Icons.facebook,
              text: 'Continue with Facebook',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SocialButton(
              icon: Icons.g_mobiledata,
              text: 'Continue with Google',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SocialButton(
              icon: Icons.apple,
              text: 'Continue with Apple',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}