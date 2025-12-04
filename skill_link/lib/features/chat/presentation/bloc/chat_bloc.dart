import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/features/chat/data/model/chat_message_model.dart';
import 'package:skill_link/features/chat/domain/use_case/chat_usecases.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyChats extends ChatEvent {}

class CreateOrGetChatEvent extends ChatEvent {
  final String otherUserId;
  final String? propertyId;
  const CreateOrGetChatEvent({required this.otherUserId, this.propertyId});
  @override
  List<Object?> get props => [otherUserId, propertyId];
}

class LoadMessages extends ChatEvent {
  final String chatId;
  const LoadMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String senderId;
  final String text;
  const SendMessageEvent({
    required this.chatId,
    required this.senderId,
    required this.text,
  });
  @override
  List<Object?> get props => [chatId, senderId, text];
}

class NewMessageReceived extends ChatEvent {
  final ChatMessageModel message;
  const NewMessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

class ConnectSocketEvent extends ChatEvent {
  final String baseUrl;
  final String token;
  const ConnectSocketEvent({required this.baseUrl, required this.token});
  @override
  List<Object?> get props => [baseUrl, token];
}

class DisconnectSocketEvent extends ChatEvent {}

class JoinChatEvent extends ChatEvent {
  final String chatId;
  const JoinChatEvent(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatsLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<Map<String, dynamic>> chats;
  const ChatsLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final Map<String, dynamic> chat;
  final List<ChatMessageModel> messages;
  const ChatLoaded({required this.chat, required this.messages});
  @override
  List<Object?> get props => [chat, messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class MessageSending extends ChatState {}

class MessageSent extends ChatState {}

class MessageReceived extends ChatState {
  final ChatMessageModel message;
  const MessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMyChatsUsecase getMyChatsUsecase;
  final CreateOrGetChatUsecase createOrGetChatUsecase;
  final GetChatByIdUsecase getChatByIdUsecase;
  final GetMessagesForChatUsecase getMessagesForChatUsecase;
  final SendMessageUsecase sendMessageUsecase;
  final ListenForNewMessagesUsecase listenForNewMessagesUsecase;
  final ConnectSocketUsecase connectSocketUsecase;
  final DisconnectSocketUsecase disconnectSocketUsecase;
  final JoinChatUsecase joinChatUsecase;

  ChatBloc({
    required this.getMyChatsUsecase,
    required this.createOrGetChatUsecase,
    required this.getChatByIdUsecase,
    required this.getMessagesForChatUsecase,
    required this.sendMessageUsecase,
    required this.listenForNewMessagesUsecase,
    required this.connectSocketUsecase,
    required this.disconnectSocketUsecase,
    required this.joinChatUsecase,
  }) : super(ChatInitial()) {
    on<LoadMyChats>(_onLoadMyChats);
    on<CreateOrGetChatEvent>(_onCreateOrGetChat);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<ConnectSocketEvent>(_onConnectSocket);
    on<DisconnectSocketEvent>(_onDisconnectSocket);
    on<JoinChatEvent>(_onJoinChat);
  }

  Future<void> _onLoadMyChats(
    LoadMyChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatsLoading());
    try {
      final chats = await getMyChatsUsecase();
      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onCreateOrGetChat(
    CreateOrGetChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chat = await createOrGetChatUsecase(
        otherUserId: event.otherUserId,
        propertyId: event.propertyId,
      );
      final messages = await getMessagesForChatUsecase(chat['_id']);
      emit(ChatLoaded(chat: chat, messages: messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chat = await getChatByIdUsecase(event.chatId);
      final messages = await getMessagesForChatUsecase(event.chatId);
      emit(ChatLoaded(chat: chat, messages: messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    print('[DEBUG] _onSendMessage called');
    try {
      sendMessageUsecase(event.chatId, event.senderId, event.text);
      // Do not emit MessageSending or MessageSent; rely on NewMessageReceived for UI update
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      final updatedMessages = List<ChatMessageModel>.from(current.messages)
        ..add(event.message);
      emit(ChatLoaded(chat: current.chat, messages: updatedMessages));
    }
  }

  void _onConnectSocket(ConnectSocketEvent event, Emitter<ChatState> emit) {
    connectSocketUsecase(event.baseUrl, event.token);
  }

  void _onDisconnectSocket(
    DisconnectSocketEvent event,
    Emitter<ChatState> emit,
  ) {
    disconnectSocketUsecase();
  }

  void _onJoinChat(JoinChatEvent event, Emitter<ChatState> emit) {
    joinChatUsecase(event.chatId);
    listenForNewMessagesUsecase((message) {
      add(NewMessageReceived(message));
    });
  }
}
