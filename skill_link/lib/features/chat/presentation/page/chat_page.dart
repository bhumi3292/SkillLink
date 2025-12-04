import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_link/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:skill_link/features/chat/data/model/chat_message_model.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';
import 'package:skill_link/features/chat/data/repository/chat_repository.dart';

import '../../../../app/constant/api_endpoints.dart';

class ChatPage extends StatefulWidget {
  final String? preselectChatId;
  final String currentUserId;
  const ChatPage({
    super.key,
    this.preselectChatId,
    required this.currentUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatBloc _chatBloc;
  String? _selectedChatId;

  @override
  void initState() {
    super.initState();
    _chatBloc = serviceLocator<ChatBloc>();
    _connectSocketAndLoadChats();
  }

  Future<void> _connectSocketAndLoadChats() async {
    // TODO: Replace with your actual backend IP and port
    final socketUrl = ApiEndpoints.localNetworkAddress;
    final tokenResult = await serviceLocator<TokenSharedPrefs>().getToken();
    final token = tokenResult.fold((failure) => '', (token) => token ?? '');
    print('[DEBUG] Dispatching ConnectSocketEvent with $socketUrl');
    _chatBloc.add(ConnectSocketEvent(baseUrl: socketUrl, token: token));
    _chatBloc.add(LoadMyChats());
    if (widget.preselectChatId != null) {
      _selectedChatId = widget.preselectChatId;
      _chatBloc.add(LoadMessages(widget.preselectChatId!));
    }
  }

  void _onChatSelect(String chatId) {
    print('[DEBUG] Chat selected: $chatId');
    setState(() {
      _selectedChatId = chatId;
    });
    _chatBloc.add(JoinChatEvent(chatId));
    _chatBloc.add(LoadMessages(chatId));
  }

  void _onBack() {
    print('[DEBUG] Back to chat list');
    setState(() {
      _selectedChatId = null;
    });
    _chatBloc.add(LoadMyChats());
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedChatId == null ? 'My Chats' : 'Chat'),
          leading:
              _selectedChatId != null
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _onBack,
                  )
                  : null,
          backgroundColor: const Color(0xFF003366),
          elevation: 2,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _selectedChatId == null
                  ? _ChatList(
                    onChatSelect: _onChatSelect,
                    currentUserId: widget.currentUserId,
                  )
                  : _ChatView(
                    chatId: _selectedChatId!,
                    currentUserId: widget.currentUserId,
                    chatBloc: _chatBloc,
                  ),
        ),
        backgroundColor: const Color(0xFFF4F8FB),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final void Function(String chatId) onChatSelect;
  final String currentUserId;
  const _ChatList({required this.onChatSelect, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] Building ChatList');
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        print('[DEBUG] ChatList BlocState: ${state.runtimeType}');
        if (state is ChatsLoading) {
          print('[DEBUG] ChatsLoading');
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatsLoaded) {
          final chats = state.chats;
          print('[DEBUG] ChatsLoaded: ${chats.length} chats');
          if (chats.isEmpty) {
            print('[DEBUG] No chats found');
            return const Center(
              child: Text(
                'No chats found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat['_id'] as String? ?? '';
              final participants =
                  (chat['participants'] as List?)
                      ?.where((p) => p['_id'] != currentUserId)
                      .toList() ??
                  [];
              final chatName =
                  participants.isNotEmpty
                      ? participants.map((p) => p['fullName']).join(', ')
                      : (chat['name'] ?? 'Untitled Chat');
              final lastMessage = chat['lastMessage'] ?? '';
              final lastMessageAt =
                  chat['lastMessageAt'] != null
                      ? DateTime.tryParse(chat['lastMessageAt'])
                      : null;
              final avatarUrl =
                  participants.isNotEmpty
                      ? participants.first['profilePicture']
                      : null;
              print(
                '[DEBUG] ChatList item: chatId=$chatId, chatName=$chatName, lastMessage=$lastMessage',
              );
              return Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    print('[DEBUG] ChatList onTap: $chatId');
                    onChatSelect(chatId);
                  },
                  leading:
                      avatarUrl != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(avatarUrl),
                            radius: 24,
                          )
                          : CircleAvatar(
                            backgroundColor: Colors.blueGrey[100],
                            radius: 24,
                            child: Text(
                              chatName.isNotEmpty ? chatName[0] : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                  title: Text(
                    chatName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    lastMessage.isNotEmpty ? lastMessage : 'No messages yet.',
                    style: TextStyle(
                      color:
                          lastMessage.isNotEmpty
                              ? Colors.grey[700]
                              : Colors.grey[400],
                      fontStyle:
                          lastMessage.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      lastMessageAt != null
                          ? Text(
                            '${lastMessageAt.hour.toString().padLeft(2, '0')}:${lastMessageAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                          : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
              );
            },
          );
        } else if (state is ChatError) {
          print('[DEBUG] ChatList error: ${state.message}');
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (state is ChatLoaded) {
          print(
            '[DEBUG] ChatList received ChatLoaded state, dispatching LoadMyChats',
          );
          BlocProvider.of<ChatBloc>(context).add(LoadMyChats());
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('No data or unknown state'));
      },
    );
  }
}

class _ChatView extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final ChatBloc chatBloc;
  const _ChatView({
    required this.chatId,
    required this.currentUserId,
    required this.chatBloc,
  });

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] Building ChatView for chatId=$chatId');
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        print('[DEBUG] ChatView BlocState: ${state.runtimeType}');
        if (state is ChatLoading) {
          print('[DEBUG] ChatView loading');
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatLoaded) {
          final chat = state.chat;
          final messages = state.messages;
          print('[DEBUG] ChatLoaded: ${messages.length} messages');
          final participants =
              (chat['participants'] as List?)
                  ?.where((p) => p['_id'] != currentUserId)
                  .toList() ??
              [];
          final other = participants.isNotEmpty ? participants.first : null;
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (other != null && other['profilePicture'] != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(other['profilePicture']),
                        radius: 26,
                      )
                    else
                      CircleAvatar(
                        backgroundColor: Colors.blueGrey[100],
                        radius: 26,
                        child: Text(
                          (other?['fullName'] ?? '?').toString().substring(
                            0,
                            1,
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          other?['fullName'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        if (other?['email'] != null)
                          Text(
                            other?['email'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        if (other?['phoneNumber'] != null)
                          Text(
                            other?['phoneNumber'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Messages
              Expanded(
                child: Container(
                  color: const Color(0xFFF4F8FB),
                  child:
                      messages.isEmpty
                          ? const Center(
                            child: Text(
                              'No messages yet. Start the conversation!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final ChatMessageModel msg =
                                  messages[messages.length - 1 - index];
                              final isMe = msg.sender.id == currentUserId;
                              print(
                                '[DEBUG] Message: sender=${msg.sender.fullName}, text=${msg.text}, isMe=$isMe',
                              );
                              return Align(
                                alignment:
                                    isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  constraints: const BoxConstraints(
                                    maxWidth: 280,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe
                                            ? const Color(0xFF003366)
                                            : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(
                                        isMe ? 16 : 4,
                                      ),
                                      bottomRight: Radius.circular(
                                        isMe ? 4 : 16,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.sender.fullName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color:
                                              isMe
                                                  ? Colors.white70
                                                  : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        msg.text,
                                        style: TextStyle(
                                          color:
                                              isMe
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        msg.createdAt
                                            .toLocal()
                                            .toString()
                                            .substring(0, 16),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              isMe
                                                  ? Colors.grey[200]
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
              // Input
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _ChatInput(
                  chatId: chatId,
                  currentUserId: currentUserId,
                  chatBloc: chatBloc,
                ),
              ),
            ],
          );
        } else if (state is ChatError) {
          print('[DEBUG] ChatView error: ${state.message}');
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ChatInput extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final ChatBloc chatBloc;
  const _ChatInput({
    required this.chatId,
    required this.currentUserId,
    required this.chatBloc,
  });

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final TextEditingController _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    print('[DEBUG] Sending message: $text');
    // Print socket connection status
    final repo = serviceLocator<ChatRepository>();
    if (repo.socketDataSource.socket != null) {
      print(
        '[DEBUG] Socket connected: ${repo.socketDataSource.socket!.connected}',
      );
    } else {
      print('[DEBUG] Socket is null');
    }
    if (text.isNotEmpty) {
      widget.chatBloc.add(
        SendMessageEvent(
          chatId: widget.chatId,
          senderId: widget.currentUserId,
          text: text,
        ),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF003366)),
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}
