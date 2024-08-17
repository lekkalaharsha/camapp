import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'chatscreen.dart'; // Import your chat screen here

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late CameraController _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Fetch the available cameras
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      // Initialize the first camera
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
      );

      try {
        await _cameraController.initialize();
      } catch (e) {
        print('Error initializing camera: $e');
      }

      if (mounted) {
        setState(() {});
      }
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

  Future<void> _openCamera(BuildContext context) async {
    if (_cameraController.value.isInitialized) {
      try {
        XFile file = await _cameraController.takePicture();
        if (file != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chatscreen(
                imagePath: file.path,
                // prompt: _selectedIndex == 2
                //     ? "Read the text"
                //     : "Describe the image?",
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
    // Define the screens to be displayed
    final List<Widget> _screens = [
      Center(child: Text('Explore Screen')),
      Center(child: Text('Food Labels Screen')),
      Center(child: Text('Text Screen')),
      Center(child: Text('Documents Screen')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: _selectedIndex == 0 && _cameraController.value.isInitialized
          ? SizedBox.expand(
              child: CameraPreview(_cameraController),
            )
          : _screens[_selectedIndex],
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
        onPressed: () => _openCamera(context),
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
