import 'package:camapp/reuseable_wigit.dart/reuseable.dart';
import 'package:camapp/screens/homepage.dart';
import 'package:camapp/screens/signupscreen.dart';
import 'package:camapp/utils/colors_utils.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Signinscreen extends StatefulWidget {
  final CameraDescription camera; // Add this line

  const Signinscreen({super.key, required this.camera}); // Update constructor

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget('img/img.png'),
                const SizedBox(height: 30),
                reusableTextField(
                  "Enter Username",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 30),
                reusableTextField(
                  "Enter Your Password",
                  Icons.verified_user,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 30),
                resuableButton(
                  context,
                  () {
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text,
                        )
                        .then((value) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(camera: widget.camera,)
                              ),
                            ));
                  },
                  'Sign In',
                ),
                const SizedBox(height: 30),
                SignUpOption(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpScreen(camera: widget.camera,),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
