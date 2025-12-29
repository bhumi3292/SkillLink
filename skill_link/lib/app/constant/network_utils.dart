import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  NetworkUtils._();

  static const int _port = 3001;

  /// MAIN source of truth
  static String get serverAddress {
    // Android
    if (Platform.isAndroid) {
      if (_isAndroidEmulator) {
        return 'http://10.0.2.2:$_port';
      }

      // REAL DEVICE
      // Choose ONE strategy:

      // ✅ USB (ADB reverse)
      return 'http://localhost:$_port';

      // ❌ Wi-Fi alternative (comment USB line above, uncomment below)
      // return 'http://10.1.16.114:$_port';
    }

    // iOS
    if (Platform.isIOS) {
      return 'http://localhost:$_port';
    }

    // Fallback (web / desktop)
    return 'http://localhost:$_port';
  }

  static bool get _isAndroidEmulator {
    return !kIsWeb &&
        Platform.isAndroid &&
        (const bool.fromEnvironment('dart.vm.product') == false) &&
        (Platform.environment.containsKey('ANDROID_EMULATOR'));
  }

  static Future<String?> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Failed to get local IP: $e');
    }
    return null;
  }

  static Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
