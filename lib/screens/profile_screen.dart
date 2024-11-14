import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.blueAccent)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Email: ${user?.email ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Display Name: ${user?.displayName ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                // Show a confirmation dialog
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

                // If user confirms, sign out and navigate to sign-in screen
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
                primary: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
