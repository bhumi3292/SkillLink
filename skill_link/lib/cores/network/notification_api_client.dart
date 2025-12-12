import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';

class NotificationApiClient {
  final Dio _dio;

  NotificationApiClient(this._dio);

  // Get all notifications for the authenticated user
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.getNotifications);
      if (response.statusCode == 200) {
        return response.data['notifications'] ?? [];
      }
      throw Exception('Failed to fetch notifications');
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.put(ApiEndpoints.markNotificationRead(notificationId));
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _dio.put(ApiEndpoints.markAllNotificationsRead);
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete(ApiEndpoints.deleteNotification(notificationId));
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }
}
