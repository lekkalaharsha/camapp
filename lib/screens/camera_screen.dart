
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';// Import the display image screen file
//vsion code
class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera controller
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {}); // Refresh to show camera preview
  }

  // Method to capture an image and return the file path
  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (image != null) {
        Navigator.pop(context, image.path); // Return the image path to the previous screen
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _captureImage, // Capture the image when the camera icon is tapped
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller); // Show the camera preview
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator()); // Show a loading indicator while the camera initializes
          }
        },
      ),
    );
  }
}
