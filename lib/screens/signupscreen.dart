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

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hextStringToColor("CB2B93"),
          hextStringToColor("9546C4"),
          hextStringToColor("5E61F4")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("enter username", Icons.person_outline, false,
                    _userTextController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("enter your email", Icons.email_outlined,
                    false, _emailTextController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField(
                    "enter your password",
                    Icons.verified_user_outlined,
                    true,
                    _passwordTextController),
                const SizedBox(
                  height: 30,
                ),
                resuableButton(context, () {
FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailTextController.text , password: _passwordTextController.text).then((value) => {
  // ignore: avoid_print
  print("created new account"),
          Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) =>  HomeScreen(camera: widget.camera)))
                          }).catchError((error) => print("error $error"));
                },"SIGN UP")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
