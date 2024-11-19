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
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          displayName = userData['displayName'] ?? "N/A";
          email = userData['email'] ?? "N/A";
        });
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
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      QuerySnapshot devicesSnapshot = await userDoc.collection('devices').get();

      if (devicesSnapshot.docs.isEmpty) {
        setState(() {
          deviceNames = ["No devices paired"];
        });
        return;
      }

      deviceNames.clear();
      for (var doc in devicesSnapshot.docs) {
        Map<String, dynamic> deviceData = doc.data() as Map<String, dynamic>;
        deviceNames.add(deviceData['deviceName'] ?? "Unknown Device");
      }

      setState(() {});
    } catch (e) {
      print("Error fetching device data: $e");
      setState(() {
        deviceNames = ["Error fetching device data"];
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section
            Container(
              width: double.infinity,
              height: 300,
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
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // User Information Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildInfoCard(Icons.email, 'Email', email),
                  const SizedBox(height: 15),
                  _buildInfoCard(Icons.person, 'Display Name', displayName),
                  const SizedBox(height: 15),
                  _buildInfoCard(Icons.devices, 'Paired Devices', deviceNames.join(", ")),
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
                  const SizedBox(height: 20),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build information cards
  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
