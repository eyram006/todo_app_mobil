import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .order('created_at', ascending: true);
      setState(() {
        _messages = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Erreur chargement messages: $e');
    }
  }

  void _subscribeToMessages() {
    _supabase
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            setState(() {
              _messages.add(payload.newRecord);
            });
          },
        )
        .subscribe();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('messages').insert({
        'content': _messageController.text,
        'user_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur envoi message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe =
                    message['user_id'] == _supabase.auth.currentUser?.id;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Tapez un message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
