import 'package:equatable/equatable.dart';
import 'package:skill_link/features/chat/domain/entity/chat_message_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

@JsonSerializable()
class ChatMessageModel extends Equatable {
  final String id;
  final ChatSenderModel sender;
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['_id'] ?? '',
        sender: ChatSenderModel.fromJson(json['sender'] ?? {}),
        text: json['text'] ?? '',
        createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
      );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'sender': sender.toJson(),
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  ChatMessageEntity toEntity() => ChatMessageEntity(
    id: id,
    sender: sender.toEntity(),
    text: text,
    createdAt: createdAt,
  );

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) =>
      ChatMessageModel(
        id: entity.id,
        sender: ChatSenderModel.fromEntity(entity.sender),
        text: entity.text,
        createdAt: entity.createdAt,
      );

  @override
  List<Object?> get props => [id, sender, text, createdAt];
}

class ChatSenderModel extends Equatable {
  final String id;
  final String fullName;
  final String profilePicture;

  const ChatSenderModel({
    required this.id,
    required this.fullName,
    required this.profilePicture,
  });

  factory ChatSenderModel.fromJson(Map<String, dynamic> json) =>
      ChatSenderModel(
        id: json['_id'] ?? '',
        fullName: json['fullName'] ?? '',
        profilePicture: json['profilePicture'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'fullName': fullName,
    'profilePicture': profilePicture,
  };

  ChatSenderEntity toEntity() => ChatSenderEntity(
    id: id,
    fullName: fullName,
    profilePicture: profilePicture,
  );

  factory ChatSenderModel.fromEntity(ChatSenderEntity entity) =>
      ChatSenderModel(
        id: entity.id,
        fullName: entity.fullName,
        profilePicture: entity.profilePicture,
      );

  @override
  List<Object?> get props => [id, fullName, profilePicture];
}
