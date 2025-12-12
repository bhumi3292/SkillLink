import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:skill_link/features/notification/data/model/notification_model.dart';

class NotificationSocketService {
  IO.Socket? socket;

  // Callbacks for different notification types
  void Function(NotificationModel)? onBookingRequest;
  void Function(NotificationModel)? onBookingConfirmed;
  void Function(NotificationModel)? onBookingRejected;
  void Function(NotificationModel)? onBookingCancelled;
  void Function(NotificationModel)? onMessage;

  void connect(String baseUrl, String token) {
    print('[NOTIFICATION] Connecting to socket at $baseUrl');
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket?.onConnect((_) {
      print('[NOTIFICATION] Socket connected!');
      _listenToNotifications();
    });

    socket?.onConnectError(
      (err) => print('[NOTIFICATION] Socket connect error: $err'),
    );

    socket?.onDisconnect((_) => print('[NOTIFICATION] Socket disconnected'));
    socket?.connect();
  }

  void _listenToNotifications() {
    socket?.on('newNotification', (data) {
      print('[NOTIFICATION] Received notification: $data');

      try {
        final type = data['type'] ?? '';
        final notification = NotificationModel(
          id: data['bookingId'] ?? '',
          recipientId: '',
          type: type,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          isRead: false,
          createdAt: DateTime.now(),
          data: data,
        );

        // Route to appropriate callback based on type
        switch (type) {
          case 'booking_request':
            onBookingRequest?.call(notification);
            break;
          case 'booking_confirmed':
            onBookingConfirmed?.call(notification);
            break;
          case 'booking_rejected':
            onBookingRejected?.call(notification);
            break;
          case 'booking_cancelled':
            onBookingCancelled?.call(notification);
            break;
          case 'message':
            onMessage?.call(notification);
            break;
        }
      } catch (e) {
        print('[NOTIFICATION] Error processing notification: $e');
      }
    });
  }

  void disconnect() {
    print('[NOTIFICATION] Disconnecting socket');
    socket?.disconnect();
    socket = null;
  }
}
