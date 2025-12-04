import 'package:flutter/material.dart';
import 'package:skill_link/app/constant/network_utils.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'dart:io';

class NetworkDebugScreen extends StatefulWidget {
  const NetworkDebugScreen({super.key});

  @override
  State<NetworkDebugScreen> createState() => _NetworkDebugScreenState();
}

class _NetworkDebugScreenState extends State<NetworkDebugScreen> {
  String? _localIpAddress;
  bool _isConnected = false;
  bool _isTestingConnection = false;
  String _connectionResult = '';

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    final ip = await NetworkUtils.getLocalIpAddress();
    final connected = await NetworkUtils.isConnectedToInternet();

    setState(() {
      _localIpAddress = ip;
      _isConnected = connected;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionResult = 'Testing connection...';
    });

    try {
      final socket = await Socket.connect(
        InternetAddress(
          ApiEndpoints.serverAddress
              .replaceAll('http://', '')
              .replaceAll(':3001', ''),
        ),
        3001,
        timeout: const Duration(seconds: 5),
      );
      await socket.close();
      setState(() {
        _connectionResult = '✅ Connection successful!';
      });
    } catch (e) {
      setState(() {
        _connectionResult = '❌ Connection failed: $e';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Debug'),
        backgroundColor: const Color(0xFF003366),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Network Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Local IP: ${_localIpAddress ?? 'Unknown'}'),
                    Text('Internet Connected: ${_isConnected ? 'Yes' : 'No'}'),
                    Text('Platform: ${Platform.operatingSystem}'),
                    Text('Server Address: ${ApiEndpoints.serverAddress}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isTestingConnection ? null : _testConnection,
                      child: Text(
                        _isTestingConnection ? 'Testing...' : 'Test Connection',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_connectionResult),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'To access chat features on real devices:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Find your computer\'s IP address'),
                    const Text('2. Update the IP in api_endpoints.dart'),
                    const Text('3. Ensure phone and computer are on same WiFi'),
                    const Text('4. Start your backend server'),
                    const Text('5. Test the connection'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      'Server Address: ${ApiEndpoints.serverAddress}',
                    ),
                    SelectableText('Base URL: ${ApiEndpoints.baseUrl}'),
                    SelectableText(
                      'Real Device Address: ${ApiEndpoints.realDeviceAddress}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
