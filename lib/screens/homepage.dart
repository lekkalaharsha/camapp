import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'chatscreen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e. Tap to retry.')),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController.pausePreview();
    } else if (state == AppLifecycleState.resumed) {
      _cameraController.resumePreview();
    }
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
        String prompt;
        switch (_selectedIndex) {
          case 0:
            prompt = "Describe the image?";
            break;
          case 1:
            prompt = "What is the food item?";
            break;
          case 2:
            prompt = "Read the text";
            break;
          case 3:
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
            } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera is not initialized')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Welcome BOB',
          style: TextStyle(color: Colors.blueAccent),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.blue),
            onPressed: () async {
              await _cameraController.pausePreview();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _initializeCamera());
            },
          ),
        ],
      ),
      body: _isCameraInitialized
          ? SizedBox.expand(child: CameraPreview(_cameraController))
          : Center(
              child: ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text("Retry Camera Initialization"),
              ),
            ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
        child: const Icon(Icons.camera),
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
            const SizedBox(height: 5),
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