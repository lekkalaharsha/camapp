import 'package:smartbuildlabs/screens/homepage.dart';
import 'package:smartbuildlabs/screens/signinscreen.dart';
import 'package:flutter/material.dart';
import 'package:smartbuildlabs/screens/constapi.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartbuildlabs/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  CameraDescription? firstCamera;
  try {
    // Initialize the list of available cameras
    final cameras = await availableCameras();
    firstCamera = cameras.isNotEmpty ? cameras.first : null;
  } catch (e) {
    print("Error initializing camera: $e");
    firstCamera = null; // Fallback if camera initialization fails
  }

  // Initialize Gemini API
  try {
    Gemini.init(apiKey: GEMINI_API_KEY);
  } catch (e) {
    print("Error initializing Gemini API: $e");
  }

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription? camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => SignInScreen(camera: camera!),
        '/home': (context) => HomeScreen(camera: camera!), 
      },
    );
  }
}
