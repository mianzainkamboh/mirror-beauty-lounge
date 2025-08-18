import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/auth_wrapper.dart';
import 'package:video_player/video_player.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  Timer? _fallbackTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen: initState called');

    // Set up fallback timer (5 seconds) to ensure app progresses
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('SplashScreen: Fallback timer triggered');
      _navigateToOnBoard();
    });

    _controller = VideoPlayerController.asset('assets/videos/2.mp4')
      ..initialize().then((_) {
        debugPrint('SplashScreen: Video initialized successfully');
        if (mounted) {
          setState(() {});
          _controller.play();
          debugPrint('SplashScreen: Video started playing');

          // Listen for when the video finishes
          _controller.addListener(_videoListener);
        }
      }).catchError((e) {
        debugPrint("SplashScreen: Error loading video: $e");
        // If video fails, navigate after a short delay
        Timer(const Duration(seconds: 2), () {
          _navigateToOnBoard();
        });
      });
  }

  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration &&
        _controller.value.isInitialized &&
        mounted) {
      debugPrint('SplashScreen: Video finished playing');
      _navigateToOnBoard();
    }
  }

  void _navigateToOnBoard() {
    if (_hasNavigated || !mounted) return;
    
    _hasNavigated = true;
    debugPrint('SplashScreen: Navigating to AuthWrapper');
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  void dispose() {
    debugPrint('SplashScreen: dispose called');
    _fallbackTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}


