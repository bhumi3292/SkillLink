class NotificationModel {
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
  final dynamic data;

  NotificationModel({
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
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      recipientId: json['recipient'] ?? '',
      senderId: json['sender'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedId: json['relatedId'],
      relatedModel: json['relatedModel'],
      isRead: json['isRead'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipient': recipientId,
      'sender': senderId,
      'type': type,
      'title': title,
      'message': message,
      'relatedId': relatedId,
      'relatedModel': relatedModel,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }
}
