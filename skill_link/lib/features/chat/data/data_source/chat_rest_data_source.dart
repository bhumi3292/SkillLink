import 'dart:convert';

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
    String? workerId,
  }) async {
    final token = await _getToken();
    final response = await dio.post(
      '${ApiEndpoints.baseUrl}chats/create-or-get',
      data: {
        'otherUserId': otherUserId,
        if (workerId != null) 'propertyId': workerId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final respData = response.data;
    // Debug log
    print(
      '[DEBUG] ChatRestDataSource.createOrGetChat response.type=${respData.runtimeType}',
    );
    print('[DEBUG] ChatRestDataSource.createOrGetChat response.data=$respData');

    dynamic candidate = respData;
    if (respData is Map && respData.containsKey('data')) {
      candidate = respData['data'];
    }

    // If backend returned JSON string, try to decode it
    if (candidate is String) {
      try {
        candidate = jsonDecode(candidate);
      } catch (_) {
        // leave as-is
      }
    }

    // If it's a list, pick the first item (common when returning arrays)
    if (candidate is List && candidate.isNotEmpty) {
      candidate = candidate.first;
    }

    if (candidate is Map<String, dynamic>) {
      return Map<String, dynamic>.from(candidate);
    }

    // Fallback: wrap non-map candidate into a map under 'value'
    return {'value': candidate};
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
