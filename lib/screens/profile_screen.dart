import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camapp/utils/colors_utils.dart';
import 'wifi_connect_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

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
                // User Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                // User Display Name
                Text(
                  user?.displayName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                // User Email
                Text(
                  user?.email ?? 'N/A',
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
                  // Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blueAccent),
                      title: const Text('Email'),
                      subtitle: Text(user?.email ?? 'N/A'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blueAccent),
                      title: const Text('Display Name'),
                      subtitle: Text(user?.displayName ?? 'N/A'),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Pair Device Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WiFiConnectScreen()),
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

                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Placeholder for edit profile functionality
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  ElevatedButton(
                    onPressed: () async {
                      bool confirmLogout = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text('Logout'),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmLogout == true) {
                        try {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error logging out: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
