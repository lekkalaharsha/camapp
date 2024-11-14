import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  _ConnectDeviceScreenState createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  bool _isConnected = false;
  String _macAddress = "";
  final String _ssid = "YourDeviceSSID";
  final String _password = "YourDevicePassword";

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _connectToDevice() async {
    try {
      bool isConnected = await WiFiForIoTPlugin.connect(
        _ssid,
        password: _password,
        joinOnce: true,
        security: NetworkSecurity.WPA,
      );

      if (isConnected) {
        setState(() {
          _isConnected = true;
        });
        _fetchMacAddress();
      } else {
        print("Failed to connect to the device hotspot.");
      }
    } catch (e) {
      print("Error connecting to Wi-Fi: $e");
    }
  }

  Future<void> _fetchMacAddress() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.4.1/mac"));

      if (response.statusCode == 200) {
        setState(() {
          _macAddress = response.body;
        });
        print("MAC Address: $_macAddress");
        await _storeMacAddressInFirebase();
      } else {
        print("Failed to fetch MAC address.");
      }
    } catch (e) {
      print("Error fetching MAC address: $e");
    }
  }

  Future<void> _storeMacAddressInFirebase() async {
    try {
      await _firebaseService.storeDeviceMacAddress(_macAddress);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Device paired successfully! MAC: $_macAddress")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error pairing device: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pair Device")),
      body: Center(
        child: _isConnected
            ? Text("Connected! MAC Address: $_macAddress")
            : ElevatedButton(
                onPressed: _connectToDevice,
                child: const Text("Connect to Device"),
              ),
      ),
    );
  }
}
