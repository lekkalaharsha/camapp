import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Import the camera screen file
import 'chatscreen.dart'; // Import the chat screen file

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // Method to handle navigation when a bottom nav bar item is tapped
  void _onBottomNavBarTapped(int index) async {
    if (index == 1) {
      // Navigate to the camera screen directly and capture an image
      final imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(),
        ),
      );

      // If an image was captured, navigate to the chat screen and pass the image path
      if (imagePath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chatscreen(imagePath: imagePath),
          ),
        );
      }
    } else {
      // Handle other navigation items if needed
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? const Center(child: Text('Home Page'))
          : const SizedBox.shrink(), // Prevent rendering if not on home page
      bottomNavigationBar: Container(
        color: Colors.blueAccent,
        height: 80, // Adjust height for a larger nav bar
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildNavBarItem(0, Icons.home, 'Home'),
              _buildNavBarItem(1, Icons.camera_alt, 'Camera'),
              _buildNavBarItem(2, Icons.search, 'Search'),
              _buildNavBarItem(3, Icons.settings, 'Settings'),
              // Add more items as needed
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build each item in the bottom navigation bar
  Widget _buildNavBarItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavBarTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0), // Increase horizontal padding
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 30, // Increase icon size
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4), // Space between icon and label
            Text(
              label,
              style: TextStyle(
                fontSize: 16, // Increase font size for labels
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
