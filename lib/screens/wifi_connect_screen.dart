import 'package:camapp/utils/colors_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

class WiFiConnectScreen extends StatefulWidget {
  const WiFiConnectScreen({super.key});

  @override
  _WiFiConnectScreenState createState() => _WiFiConnectScreenState();
}

class _WiFiConnectScreenState extends State<WiFiConnectScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  bool _isConnected = false;
  bool _isLoading = false;
  String _macAddress = "";
  final FirebaseService _firebaseService = FirebaseService();
  String _ssid = "";
  String _password = "";
  String connectionStatus = 'Not connected';
  

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool cameraGranted = await _requestCameraPermission();
    if (!cameraGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied.")),
      );
    }
  }

  Future<void> _speak(String message) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(1);
    await _flutterTts.speak(message);
  }


  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  void _onDetect(Barcode barcode) {
    final String? qrData = barcode.rawValue;
    if (qrData != null) {
      _parseQRCode(qrData);
      MobileScannerController().stop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No QR code detected.")),
      );
    }
  }


  void _parseQRCode(String qrData) {
    try {
      if (qrData.contains("SSID:") && qrData.contains("PASSWORD:")) {
        final ssidStart = qrData.indexOf("SSID:") + 5;
        final ssidEnd = qrData.indexOf(";", ssidStart);
        final passwordStart = qrData.indexOf("PASSWORD:") + 9;
        final passwordEnd = qrData.indexOf(";", passwordStart);

        _ssid = qrData.substring(ssidStart, ssidEnd).trim();
        _password = qrData.substring(passwordStart, passwordEnd).trim();

        if (_ssid.isNotEmpty && _password.isNotEmpty) {
          _connectToWiFi(_ssid, _password);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid QR Code Data")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid QR Code Format")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to parse QR code")),
      );
    }
  }

  Future<void> _connectToWiFi(String ssid, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool isConnected = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        joinOnce: true,
        security: NetworkSecurity.WPA,
      );

      setState(() {
        _isLoading = false;
      });

      if (isConnected) {
        setState(() {
          _isConnected = true;
          connectionStatus = 'Connected to $ssid';
        });

        // Show a success snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully connected to Wi-Fi: $ssid"),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
        await _speak("Successfully connected to Wi-Fi, SSID: $ssid");

        // Fetch the MAC address
        _fetchMacAddress();
      } else {
        _showRetryDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showRetryDialog();
    }
  }


  void _showConnectionDialog(String ssid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connection Successful"),
        content: Text("Successfully connected to Wi-Fi: $ssid"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchMacAddress() async {
    try {
      // Fetch the MAC address (BSSID) of the currently connected Wi-Fi network
      String? macAddress = await WiFiForIoTPlugin.getBSSID();

      if (macAddress != null && macAddress.isNotEmpty) {
        setState(() {
          _macAddress = macAddress;
        });

        // Store the device data in Firebase
        await _firebaseService.storeDeviceData(
          _macAddress,
          _ssid,
          "ESP32 Device",
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Device paired successfully! MAC: $_macAddress"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Handle case where MAC address is not fetched
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch MAC address.")),
        );
      }
    } catch (e) {
      // Error handling for unexpected issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching MAC address: $e")),
      );
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connection Failed"),
        content: const Text("Would you like to retry connecting to Wi-Fi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _connectToWiFi(_ssid, _password);
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Wi-Fi Pairing"),
      backgroundColor: Colors.blueAccent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hextStringToColor("CB2B93"),
              hextStringToColor("9546C4"),
              hextStringToColor("5E61F4"),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: Stack(
      children: [
        // Background gradient
        Container(
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
        ),
        // Main content
        Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Scan QR Code to Connect",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
              Text(
              connectionStatus,
              style: TextStyle(
                fontSize: 16,
                color: _isConnected ? Colors.green : Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // QR code scanner
            // Expanded camera view
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 200,top: 50,left: 20,right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    controller: MobileScannerController(),
                    onDetect: (capture) {
                      for (final barcode in capture.barcodes) {
                        if (barcode.rawValue != null) {
                          _onDetect(barcode);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          
          ],
        ),
        // Loading indicator
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    ),
  );
}

}
