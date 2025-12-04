import 'package:skill_link/features/chat/data/data_source/chat_rest_data_source.dart';
import 'package:skill_link/features/chat/data/data_source/chat_socket_data_source.dart';
import 'package:skill_link/features/chat/data/model/chat_message_model.dart';

class ChatRepository {
  final ChatRestDataSource restDataSource;
  final ChatSocketDataSource socketDataSource;

  ChatRepository({
    required this.restDataSource,
    required this.socketDataSource,
  });

  Future<Map<String, dynamic>> createOrGetChat({
    required String otherUserId,
    String? propertyId,
  }) {
    print(
      '[DEBUG] ChatRepository.createOrGetChat: otherUserId=$otherUserId, propertyId=$propertyId',
    );
    return restDataSource.createOrGetChat(
      otherUserId: otherUserId,
      propertyId: propertyId,
    );
  }

  Future<List<Map<String, dynamic>>> getMyChats() {
    print('[DEBUG] ChatRepository.getMyChats');
    return restDataSource.getMyChats();
  }

  Future<Map<String, dynamic>> getChatById(String chatId) {
    print('[DEBUG] ChatRepository.getChatById: chatId=$chatId');
    return restDataSource.getChatById(chatId);
  }

  Future<List<ChatMessageModel>> getMessagesForChat(String chatId) {
    print('[DEBUG] ChatRepository.getMessagesForChat: chatId=$chatId');
    return restDataSource.getMessagesForChat(chatId);
  }

  // Socket methods
  void connectSocket(String baseUrl, String token) {
    print('[DEBUG] ChatRepository.connectSocket: baseUrl=$baseUrl');
    socketDataSource.connect(baseUrl, token);
  }

  void joinChat(String chatId) {
    print('[DEBUG] ChatRepository.joinChat: chatId=$chatId');
    socketDataSource.joinChat(chatId);
  }

  void sendMessage(String chatId, String senderId, String text) {
    print(
      '[DEBUG] ChatRepository.sendMessage: chatId=$chatId, senderId=$senderId, text=$text',
    );
    socketDataSource.sendMessage(chatId, senderId, text);
  }

  void onNewMessage(void Function(ChatMessageModel) callback) {
    print('[DEBUG] ChatRepository.onNewMessage');
    socketDataSource.onNewMessage(callback);
  }

  void disconnectSocket() {
    print('[DEBUG] ChatRepository.disconnectSocket');
    socketDataSource.disconnect();
  }
}
