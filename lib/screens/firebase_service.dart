import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeDeviceData(String macAddress, String ssid, String deviceName) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        String email = user.email ?? "unknown";
        DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

        // Store the user's email if it doesn't already exist
        await userDoc.set(
          {
            'email': email,
          },
          SetOptions(merge: true), // Merge option to avoid overwriting existing data
        );

        // Check if the device already exists
        DocumentSnapshot existingDevice = await userDoc.collection('devices').doc(macAddress).get();

        if (existingDevice.exists) {
          print("Device with MAC address $macAddress is already stored.");
          return;
        }

        // Store or update device data
        await userDoc.collection('devices').doc(macAddress).set({
          'macAddress': macAddress,
          'ssid': ssid,
          'pairedAt': FieldValue.serverTimestamp(),
          'deviceName': deviceName,
          'registeredBy': email,
        });

        print("Device data successfully stored in Firestore.");
      } catch (e) {
        print("Error storing device data: $e");
        throw Exception("Failed to store device data: $e");
      }
    } else {
      print("No user is currently logged in.");
      throw Exception("User not authenticated.");
    }
  }
}
