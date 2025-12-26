import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:skill_link/app/constant/api_endpoints.dart'; // Adjust path

class SocketNotificationService {
  late IO.Socket socket;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  void init(String userId) {
    if (_isInitialized) {
       print('Socket already initialized. Emitting joinRoom for $userId');
       socket.emit('joinRoom', userId);
       return;
    }

    // initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
        
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Connect to Socket
    socket = IO.io(ApiEndpoints.serverAddress, <String, dynamic>{ 
      'transports': ['websocket'],
      'autoConnect': false,
    });
    
    socket.connect();
    
    socket.onConnect((_) {
      print('Connected to Socket');
      socket.emit('joinRoom', userId); // Listen to user specific room
    });

    socket.onDisconnect((_) => print('Disconnected from Socket'));

    socket.on('notification', (data) {
      _showNotification(data['title'], data['message']);
    });

    _isInitialized = true;
  }

  void disconnect() {
    if (_isInitialized) {
      socket.disconnect();
      _isInitialized = false;
    }
  }

  Future<void> _showNotification(String title, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('skilllink_channel', 'SkillLink Notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, message, platformChannelSpecifics,
        payload: 'item x');
  }
}
