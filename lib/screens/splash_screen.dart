import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _statusMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    debugPrint("SplashScreen: initState called");

    // Initialize the fade-in animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
    debugPrint("SplashScreen: Animation started");

    // Delay for logo visibility and then initialize Firebase
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _statusMessage = "Initializing ....";
      });
      _initializeAndNavigate();
    });
  }

  // Method to initialize Firebase and check user authentication status
  Future<void> _initializeAndNavigate() async {
    try {
      debugPrint("SplashScreen: Initializing Firebase...");
      await Firebase.initializeApp();
      debugPrint("SplashScreen: Firebase initialized");

      // Adding a small delay to ensure Firebase is ready
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint("SplashScreen: Delay completed");

      if (!mounted) {
        debugPrint("SplashScreen: Widget is not mounted, exiting _initializeAndNavigate");
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      debugPrint("SplashScreen: Current user: ${user?.email ?? 'No user logged in'}");

      setState(() {
        _statusMessage = user == null ? "Navigating to Sign In..." : "Navigating to Home...";
      });

      await Future.delayed(const Duration(seconds: 2));

      if (user == null) {
        debugPrint("SplashScreen: Navigating to SignIn screen");
        Navigator.of(context).pushReplacementNamed('/signin');
      } else {
        debugPrint("SplashScreen: Navigating to Home screen");
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      debugPrint("SplashScreen: Error during Firebase initialization: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    debugPrint("SplashScreen: dispose called");
    if (_animationController.isAnimating) {
      _animationController.stop();
      debugPrint("SplashScreen: Animation stopped");
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("SplashScreen: build called");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/import.jpg',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Smart build labs Wellcomes you  ',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
