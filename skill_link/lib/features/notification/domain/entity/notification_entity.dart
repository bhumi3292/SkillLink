class NotificationEntity {
  final String id;
  final String recipientId;
  final String? senderId;
  final String type;
  final String title;
  final String message;
  final String? relatedId;
  final String? relatedModel;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.relatedModel,
    required this.isRead,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    String? type,
    String? title,
    String? message,
    String? relatedId,
    String? relatedModel,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      relatedModel: relatedModel ?? this.relatedModel,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
