import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeDeviceMacAddress(String macAddress) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Reference to the user's document
        DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

        // Store the MAC address under the "devices" subcollection
        await userDoc.collection('devices').doc(macAddress).set({
          'macAddress': macAddress,
          'pairedAt': FieldValue.serverTimestamp(),
        });

        print("MAC address $macAddress successfully stored in Firestore.");
      } catch (e) {
        print("Error storing MAC address: $e");
        throw Exception("Failed to store MAC address.");
      }
    } else {
      print("No user is currently logged in.");
      throw Exception("User not authenticated.");
    }
  }
}
