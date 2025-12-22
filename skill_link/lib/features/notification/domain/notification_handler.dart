import 'package:flutter/material.dart';

class NotificationHandler {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void handleNavigation(Map<String, dynamic> data) {
    // Example payload: { "type": "chat", "id": "123" }
    final String? type = data['type'];
    final String? id = data['id'];

    if (type == null) return;

    switch (type) {
      case 'message':
        // Navigate to Chat
        if (id != null) {
           // Ensure you have a route generator that handles '/chat' with arguments
           navigatorKey.currentState?.pushNamed('/chat', arguments: id);
        }
        break;
      case 'booking_new':
      case 'booking_update':
        // Navigate to Booking Detail
        if (id != null) {
           navigatorKey.currentState?.pushNamed('/booking_detail', arguments: id);
        }
        break;
      default:
        // Default or Home
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
        break;
    }
  }
}
