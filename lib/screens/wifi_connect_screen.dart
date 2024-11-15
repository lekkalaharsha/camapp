import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';

class WiFiConnectScreen extends StatefulWidget {
  const WiFiConnectScreen({super.key});

  @override
  _WiFiConnectScreenState createState() => _WiFiConnectScreenState();
}

class _WiFiConnectScreenState extends State<WiFiConnectScreen> {
  bool _isConnected = false;
  String _macAddress = "";
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;
  String _ssid = "";
  String _password = "";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
  }

  // Method to manually start QR scanning
  void _startQRScanner() {
    _qrController?.resumeCamera();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Scanning for QR Code...")),
    );
  }

  // QR Code Scanner
  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      final qrData = scanData.code;
      if (qrData != null) {
        _parseQRCode(qrData);
        _qrController?.pauseCamera();
      }
    });
  }

  // Parse QR Code Data
  void _parseQRCode(String qrData) {
    try {
      final data = jsonDecode(qrData);
      _ssid = data['ssid'] ?? "";
      _password = data['password'] ?? "";

      if (_ssid.isNotEmpty && _password.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Wi-Fi Credentials Scanned: SSID=$_ssid")),
        );
        _connectToWiFi(_ssid, _password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid QR Code Data")),
        );
      }
    } catch (e) {
      print("Error parsing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to parse QR code")),
      );
    }
  }

  // Connect to Wi-Fi
  Future<void> _connectToWiFi(String ssid, String password) async {
    await _requestPermissions();

    try {
      bool isConnected = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        joinOnce: true,
        security: NetworkSecurity.WPA,
      );

      if (isConnected) {
        setState(() {
          _isConnected = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connected to Wi-Fi: $ssid")),
        );
        _fetchMacAddress();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to connect to Wi-Fi.")),
        );
      }
    } catch (e) {
      print("Error connecting to Wi-Fi: $e");
    }
  }

  // Fetch MAC Address
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
      print("Error fetching MAC address: $e");
    }
  }

  @override
  void dispose() {
    _qrController?.stopCamera();
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pair Device")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Click the button below to scan the QR code on your device.",
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: _startQRScanner,
            child: const Text("Scan QR Code"),
          ),
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blueAccent,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
