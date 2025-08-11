import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/splash_screen.dart';
import 'package:mirrorsbeautylounge/on_board.dart';
import 'package:video_player/video_player.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/1.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();

        // Listen for when the video finishes
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration &&
              _controller.value.isInitialized &&
              mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OnBoardScreen()),
            );
          }
        });
      }).catchError((e) {
        debugPrint("Error loading video: $e");
      });
  }

  @override
  void dispose() {
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


