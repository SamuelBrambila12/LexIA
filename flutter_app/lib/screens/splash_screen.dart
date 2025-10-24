import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/auth_service.dart';
import 'language_selection_screen.dart';
import 'auth/login_register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/intro.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isInitialized = true);
        _controller.play();
      });

    _controller.addListener(_onVideoChange);
  }

  void _onVideoChange() {
    if (_controller.value.isInitialized && !_controller.value.isPlaying && _controller.value.position >= _controller.value.duration) {
      _navigateNext();
    }
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;
    final loggedIn = await AuthService().isLoggedIn();
    final next = loggedIn ? const LanguageSelectionScreen() : const LoginRegisterScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          Positioned(
            bottom: 30,
            right: 20,
            child: TextButton(
              onPressed: _navigateNext,
              child: const Text('Saltar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}