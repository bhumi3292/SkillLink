import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:skill_link/features/chat/data/model/chat_message_model.dart';

class ChatSocketDataSource {
  IO.Socket? socket;

  void connect(String baseUrl, String token) {
    print('[DEBUG] Connecting to socket at $baseUrl');
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );
    socket?.onConnect((_) => print('[DEBUG] Socket connected!'));
    socket?.onConnectError(
      (err) => print('[DEBUG] Socket connect error: $err'),
    );
    socket?.onDisconnect((_) => print('[DEBUG] Socket disconnected'));
    socket?.connect();
  }

  void joinChat(String chatId) {
    print('[DEBUG] Joining chat: $chatId');
    socket?.emit('joinChat', chatId);
  }

  void sendMessage(String chatId, String senderId, String text) {
    print('[DEBUG] Sending message to chat: $chatId');
    print('[DEBUG] Sender ID: $senderId');
    print('[DEBUG] Text: $text');
    socket?.emit('sendMessage', {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
    });
  }

  void onNewMessage(void Function(ChatMessageModel) callback) {
    socket?.on('newMessage', (data) {
      print('[DEBUG] Received newMessage event: $data');
      callback(ChatMessageModel.fromJson(data));
    });
    socket?.on('messageError', (data) {
      print('[DEBUG] messageError: $data');
    });
  }

  void disconnect() {
    print('[DEBUG] Disconnecting socket');
    socket?.disconnect();
    socket = null;
  }
}
