import 'package:camapp/reuseable_wigit.dart/reuseable.dart';
import 'package:camapp/screens/homepage.dart';
import 'package:camapp/utils/colors_utils.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final CameraDescription camera;
  const SignUpScreen({super.key, required this.camera});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userTextController = TextEditingController();
  bool _isLoading = false;

  // Method to validate input fields
  bool _validateInputs() {
    if (_userTextController.text.isEmpty) {
      _showSnackbar("Username cannot be empty");
      return false;
    }
    if (_emailTextController.text.isEmpty || !_emailTextController.text.contains('@')) {
      _showSnackbar("Enter a valid email address");
      return false;
    }
    if (_passwordTextController.text.length < 6) {
      _showSnackbar("Password must be at least 6 characters long");
      return false;
    }
    return true;
  }

  // Method to show a Snackbar with error messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Method to handle user sign-up
  Future<void> _signUp() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text.trim(),
      );
      // Navigate to HomeScreen on successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(camera: widget.camera),
        ),
      );
    } catch (error) {
      _showSnackbar("Error: ${error.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hextStringToColor("CB2B93"),
              hextStringToColor("9546C4"),
              hextStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo or Title Text
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Username TextField
                reusableTextField(
                  "Enter Username",
                  Icons.person_outline,
                  false,
                  _userTextController,
                ),
                const SizedBox(height: 20),

                // Email TextField
                reusableTextField(
                  "Enter Your Email",
                  Icons.email_outlined,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),

                // Password TextField
                reusableTextField(
                  "Enter Your Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 30),

                // Sign-Up Button with Loading Indicator
                _isLoading
                    ? const CircularProgressIndicator()
                    : resuableButton(
                        context,
                        _signUp,
                        'SIGN UP',
                      ),
                const SizedBox(height: 20),

                // Redirect to Sign-In Page
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Already have an account? Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
