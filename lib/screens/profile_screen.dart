import 'package:smartbuildlabs/screens/wifi_connect_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartbuildlabs/utils/colors_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String displayName = "N/A";
  String email = "N/A";
  List<String> deviceNames = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchDeviceData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      String userId = user!.uid;

      // Reference to the user's document
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      // Fetch user document
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

        // Fetch display name and email from Firestore
        setState(() {
          displayName = userData['displayName'] ?? "N/A";
          email = userData['email'] ?? "N/A";
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        displayName = "Error fetching display name";
        email = "Error fetching email";
      });
    }
  }

  Future<void> _fetchDeviceData() async {
    if (user == null) return;

    try {
      String userId = user!.uid;

      // Reference to the user's document
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      // Fetch all devices from the 'devices' sub-collection
      QuerySnapshot devicesSnapshot = await userDoc.collection('devices').get();

      // Check if there are any paired devices
      if (devicesSnapshot.docs.isEmpty) {
        print("No devices found for the user.");
        setState(() {
          deviceNames = ["No devices paired"];
        });
        return;
      }

      // Clear the existing list of device names
      deviceNames.clear();

      // Iterate over each document in the 'devices' sub-collection
      for (var doc in devicesSnapshot.docs) {
        Map<String, dynamic> deviceData = doc.data() as Map<String, dynamic>;

        // Log device details for debugging
        print("Device MAC: ${deviceData['macAddress']}");
        print("SSID: ${deviceData['ssid']}");
        print("Device Name: ${deviceData['deviceName']}");
        print("Paired At: ${deviceData['pairedAt']}");

        // Add the device name to the list
        deviceNames.add(deviceData['deviceName'] ?? "Unknown Device");
      }

      // Update the UI with the list of device names
      setState(() {});
    } catch (e) {
      print("Error fetching device data: $e");
      setState(() {
        deviceNames = ["Error fetching device data"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Null check for the user object
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not authenticated. Please sign in.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Top Header Section
          Container(
            width: double.infinity,
            height: 250,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                // Display Name from Firestore
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                // Email from Firestore
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // User Information Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Email Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blueAccent),
                      title: const Text('Email'),
                      subtitle: Text(email),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Display Name Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blueAccent),
                      title: const Text('Display Name'),
                      subtitle: Text(displayName),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Paired Devices Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.devices, color: Colors.blueAccent),
                      title: const Text('Paired Devices'),
                      subtitle: Text(deviceNames.join(", ")),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Pair Device Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      var status = await Permission.camera.status;
                      if (status.isDenied || status.isPermanentlyDenied) {
                        await Permission.camera.request();
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WiFiConnectScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Pair Device'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
