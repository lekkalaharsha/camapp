import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WiFiConnectScreen extends StatefulWidget {
  @override
  _WiFiConnectScreenState createState() => _WiFiConnectScreenState();
}

class _WiFiConnectScreenState extends State<WiFiConnectScreen> {
  List<WifiNetwork?> _wifiNetworks = [];
  bool _isConnected = false;
  final String _ssid = "YourDeviceSSID"; // Replace with your device SSID
  final String _password = "YourDevicePassword"; // Replace with your device password

  @override
  void initState() {
    super.initState();
    _scanForWiFiNetworks();
  }

  // Method to scan for available Wi-Fi networks
  Future<void> _scanForWiFiNetworks() async {
    try {
      List<WifiNetwork?> networks = await WiFiForIoTPlugin.loadWifiList();
      setState(() {
        _wifiNetworks = networks;
      });
    } catch (e) {
      print("Error scanning Wi-Fi networks: $e");
    }
  }

  // Method to connect to a specific Wi-Fi network
  Future<void> _connectToWiFi() async {
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
        print("Connected to Wi-Fi: $_ssid");
      } else {
        print("Failed to connect to Wi-Fi.");
      }
    } catch (e) {
      print("Error connecting to Wi-Fi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wi-Fi Connect"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _connectToWiFi,
            child: const Text("Connect to Wi-Fi"),
          ),
          const SizedBox(height: 20),
          _isConnected
              ? const Text("Connected to Wi-Fi!")
              : const Text("Not connected"),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _wifiNetworks.length,
              itemBuilder: (context, index) {
                final network = _wifiNetworks[index];
                return ListTile(
                  title: Text(network?.ssid ?? "Unknown SSID"),
                  subtitle: Text(network?.bssid ?? "Unknown BSSID"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
