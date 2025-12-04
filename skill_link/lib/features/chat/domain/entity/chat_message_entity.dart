import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final ChatSenderEntity sender;
  final String text;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, sender, text, createdAt];
}

class ChatSenderEntity extends Equatable {
  final String id;
  final String fullName;
  final String profilePicture;

  const ChatSenderEntity({
    required this.id,
    required this.fullName,
    required this.profilePicture,
  });

  @override
  List<Object?> get props => [id, fullName, profilePicture];
} 