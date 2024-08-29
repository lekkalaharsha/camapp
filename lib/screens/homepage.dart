import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'chatscreen.dart'; // Import your chat screen here

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _takePicture() async {
    if (_isCameraInitialized && _cameraController.value.isInitialized) {
      try {
        XFile file = await _cameraController.takePicture();
        if (file != null) {
          String prompt;
          switch (_selectedIndex) {
            case 0: // Explore
              prompt = "Describe the image?";
              break;
            case 1: // Food labels
              prompt = "What is the food item?";
              break;
            case 2: // Text
              prompt = "Read the text";
              break;
            case 3: // Documents
              prompt = "Read the documents";
              break;
            default:
              prompt = "Describe the image?";
              break;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chatscreen(
                imagePath: file.path,
                prompt: prompt,
              ),
            ),
          );
        }
      } catch (e) {
        print('Error capturing image: $e');
      }
    } else {
      print('Camera is not initialized');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome BOB',
            style: TextStyle(color: Colors.blueAccent)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.blue),
            onPressed: () {
              // Handle profile or settings action here
            },
          ),
        ],
      ),
      body: _isCameraInitialized
          ? SizedBox.expand(child: CameraPreview(_cameraController))
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildNavItem(Icons.explore, 'Explore', 0),
              _buildNavItem(Icons.qr_code, 'Food labels', 1),
              _buildNavItem(Icons.text_fields, 'Text', 2),
              _buildNavItem(Icons.document_scanner, 'Documents', 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: _selectedIndex == index ? Colors.white : Colors.grey,
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
