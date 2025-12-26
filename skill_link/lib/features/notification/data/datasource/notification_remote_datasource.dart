import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/notification/data/model/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService _apiService;

  NotificationRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getNotifications);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.dio.patch(ApiEndpoints.markNotificationRead(notificationId));
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }
}
