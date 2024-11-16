import 'dart:typed_data';
import 'package:camapp/utils/colors_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';

class WiFiConnectScreen extends StatefulWidget {
  const WiFiConnectScreen({super.key});

  @override
  _WiFiConnectScreenState createState() => _WiFiConnectScreenState();
}

class _WiFiConnectScreenState extends State<WiFiConnectScreen> {
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

  Future<void> _fetchMacAddress() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.4.1/mac"));

      if (response.statusCode == 200) {
        setState(() {
          _macAddress = response.body.trim();
        });
        await _firebaseService.storeDeviceData(_macAddress, _ssid, "ESP32 Device");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Device paired successfully! MAC: $_macAddress")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch MAC address.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("MAC address fetch error: $e")),
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
      ),
      body: Stack(
        children: [
          // Gradient Background
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Scan the QR code to connect to Wi-Fi.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Expanded(
                child: MobileScanner(
                  controller: MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates),
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
              const SizedBox(height: 20),
              Text(
                connectionStatus,
                style: TextStyle(
                  fontSize: 16,
                  color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
