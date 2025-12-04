import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/features/chat/data/model/chat_message_model.dart';

class ChatRestDataSource {
  final Dio dio;
  ChatRestDataSource({required this.dio});

  Future<String?> _getToken() async {
    final tokenResult = await serviceLocator<TokenSharedPrefs>().getToken();
    return tokenResult.fold((failure) => null, (token) => token);
  }

  Future<Map<String, dynamic>> createOrGetChat({
    required String otherUserId,
    String? propertyId,
  }) async {
    final token = await _getToken();
    final response = await dio.post(
      '${ApiEndpoints.baseUrl}chats/create-or-get',
      data: {
        'otherUserId': otherUserId,
        if (propertyId != null) 'propertyId': propertyId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyChats() async {
    final token = await _getToken();
    final response = await dio.get(
      '${ApiEndpoints.baseUrl}chats',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> getChatById(String chatId) async {
    final token = await _getToken();
    final response = await dio.get(
      '${ApiEndpoints.baseUrl}chats/$chatId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<ChatMessageModel>> getMessagesForChat(String chatId) async {
    final token = await _getToken();
    final response = await dio.get(
      '${ApiEndpoints.baseUrl}chats/$chatId/messages',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = response.data['data'] as List;
    return data.map((json) => ChatMessageModel.fromJson(json)).toList();
  }
}
