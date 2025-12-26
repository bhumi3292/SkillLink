import 'package:skill_link/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:skill_link/features/notification/data/model/notification_model.dart';
import 'package:skill_link/features/notification/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationModel>> getNotifications() {
    return remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return remoteDataSource.markAsRead(notificationId);
  }
}
