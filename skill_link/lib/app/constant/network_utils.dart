import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  /// Get the local IP address of the device
  static Future<String?> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.address.startsWith('127.') &&
              !addr.address.startsWith('169.254.')) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting local IP address: $e');
      }
    }
    return null;
  }

  /// Check if the device is connected to the internet
  static Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Get the appropriate server address based on the platform
  static String getServerAddress() {
    if (Platform.isAndroid) {
      // For Android emulator
      if (kDebugMode) {
        return 'http://10.0.2.2:3001';
      }
      // For real Android device - you need to update this with your computer's IP
      return 'http://192.168.1.100:3001'; // Update this IP
    } else if (Platform.isIOS) {
      // For iOS simulator
      if (kDebugMode) {
        return 'http://localhost:3001';
      }
      // For real iOS device - you need to update this with your computer's IP
      return 'http://192.168.1.100:3001'; // Update this IP
    }
    return 'http://localhost:3001';
  }

  /// Instructions for setting up network for real devices
  static String getNetworkSetupInstructions() {
    return '''
Network Setup Instructions for Real Devices:

1. Find your computer's IP address:
   - Windows: Run 'ipconfig' in CMD
   - Mac/Linux: Run 'ifconfig' in Terminal
   - Look for IPv4 address (usually starts with 192.168.x.x)

2. Update the IP address in:
   - lib/app/constant/api_endpoints.dart
   - Change 'realDeviceAddress' to your computer's IP

3. Make sure your phone and computer are on the same WiFi network

4. Start your backend server on your computer

5. Test the connection by accessing http://YOUR_IP:3001 in your phone's browser

Example:
If your computer's IP is 192.168.1.50, update:
static const String realDeviceAddress = "http://192.168.1.50:3001";
''';
  }
} 