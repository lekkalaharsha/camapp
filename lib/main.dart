import 'package:camapp/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:camapp/screens/constapi.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the list of available cameras
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // Initialize Gemini API
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );

  runApp(MyApp(camera: firstCamera));
}
class MyApp extends StatelessWidget {
  final CameraDescription camera;

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
      home: HomeScreen(camera: camera), // Pass the camera to HomeScreen
    );
  }
}
