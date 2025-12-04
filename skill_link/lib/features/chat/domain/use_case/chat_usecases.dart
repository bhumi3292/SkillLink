import 'package:skill_link/features/chat/data/model/chat_message_model.dart';
import 'package:skill_link/features/chat/data/repository/chat_repository.dart';

class GetMyChatsUsecase {
  final ChatRepository repository;
  GetMyChatsUsecase(this.repository);
  Future<List<Map<String, dynamic>>> call() => repository.getMyChats();
}

class CreateOrGetChatUsecase {
  final ChatRepository repository;
  CreateOrGetChatUsecase(this.repository);
  Future<Map<String, dynamic>> call({
    required String otherUserId,
    String? propertyId,
  }) => repository.createOrGetChat(
    otherUserId: otherUserId,
    propertyId: propertyId,
  );
}

class GetChatByIdUsecase {
  final ChatRepository repository;
  GetChatByIdUsecase(this.repository);
  Future<Map<String, dynamic>> call(String chatId) =>
      repository.getChatById(chatId);
}

class GetMessagesForChatUsecase {
  final ChatRepository repository;
  GetMessagesForChatUsecase(this.repository);
  Future<List<ChatMessageModel>> call(String chatId) =>
      repository.getMessagesForChat(chatId);
}

class SendMessageUsecase {
  final ChatRepository repository;
  SendMessageUsecase(this.repository);
  void call(String chatId, String senderId, String text) =>
      repository.sendMessage(chatId, senderId, text);
}

class ListenForNewMessagesUsecase {
  final ChatRepository repository;
  ListenForNewMessagesUsecase(this.repository);
  void call(void Function(ChatMessageModel) callback) =>
      repository.onNewMessage(callback);
}

class ConnectSocketUsecase {
  final ChatRepository repository;
  ConnectSocketUsecase(this.repository);
  void call(String baseUrl, String token) =>
      repository.connectSocket(baseUrl, token);
}

class DisconnectSocketUsecase {
  final ChatRepository repository;
  DisconnectSocketUsecase(this.repository);
  void call() => repository.disconnectSocket();
}

class JoinChatUsecase {
  final ChatRepository repository;
  JoinChatUsecase(this.repository);
  void call(String chatId) => repository.joinChat(chatId);
}
