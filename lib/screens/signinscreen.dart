import 'package:smartbuildlabs/reuseable_wigit.dart/reuseable.dart';
import 'package:smartbuildlabs/screens/homepage.dart';
import 'package:smartbuildlabs/screens/signupscreen.dart';
import 'package:smartbuildlabs/utils/colors_utils.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  final CameraDescription camera;

  const SignInScreen({super.key, required this.camera});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Method to handle sign-in
  Future<void> _signIn() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    // Enhanced input validation
    if (_emailTextController.text.isEmpty || _passwordTextController.text.isEmpty) {
      _showSnackbar("Please fill in both email and password.");
      return;
    }

    final emailPattern = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailPattern.hasMatch(_emailTextController.text)) {
      _showSnackbar("Please enter a valid email address.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(camera: widget.camera),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        default:
          message = 'An unexpected error occurred. Please try again later.';
          break;
      }
      _showSnackbar(message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to show a Snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                // Logo Widget
                logoWidget('assets/images/import.jpg'),
                const SizedBox(height: 30),

                // Email TextField
                reusableTextField(
                  "Enter Email",
                  Icons.email_outlined,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),

                // Password TextField with visibility toggle
                reusableTextField(
                  "Enter Your Password",
                  Icons.lock_outline,
                  !_isPasswordVisible,
                  _passwordTextController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Sign In Button with Loading Indicator
                _isLoading
                    ? const CircularProgressIndicator()
                    : reusableButton(
                        context,
                        _signIn,
                        'Sign In',
                      ),
                const SizedBox(height: 20),

                // Sign Up Option
                SignUpOption(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpScreen(camera: widget.camera),
                      ),
                    );
                  },
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