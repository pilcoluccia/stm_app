import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TaskGroupChatPage extends StatefulWidget {
  final Map<String, dynamic> group;
  final Map<String, dynamic>? task;
  final bool lecturerView;

  const TaskGroupChatPage({
    super.key,
    required this.group,
    this.task,
    this.lecturerView = false,
  });

  @override
  State<TaskGroupChatPage> createState() => _TaskGroupChatPageState();
}

class _TaskGroupChatPageState extends State<TaskGroupChatPage> {
  final _api = ApiService();
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;

  String get _groupId => widget.group['id']?.toString() ?? '';
  String get _groupName => widget.group['name']?.toString() ?? 'Group Chat';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_groupId.isEmpty) return;
    setState(() => _loading = true);
    try {
      final messages = await _api.listGroupMessages(_groupId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
      });
      _jumpToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading chat: $e')),
      );
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    final user = AuthService.instance.currentAppUser;
    setState(() => _sending = true);
    try {
      await _api.sendGroupMessage(
        groupId: _groupId,
        senderId: user?.dbId ?? user?.uid ?? 'unknown',
        senderName: user?.name ?? user?.email ?? 'User',
        text: text,
      );
      _ctrl.clear();
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(dynamic value) {
    final dt = DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final members = (widget.group['students'] as List?) ?? [];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_groupName, style: const TextStyle(fontSize: 16)),
            Text(
              '${members.length} members${widget.lecturerView ? ' • lecturer monitoring' : ''}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF111111),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: members.map<Widget>((member) {
                final name = member['name']?.toString() ?? member['email']?.toString() ?? member['id']?.toString() ?? 'Student';
                return Chip(
                  backgroundColor: const Color(0xFF1E1E1E),
                  avatar: const Icon(Icons.person, color: Color(0xFF4A7BFF), size: 16),
                  label: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet. Start the group discussion.', style: TextStyle(color: Colors.white38)),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final user = AuthService.instance.currentAppUser;
                          final senderId = msg['senderId']?.toString() ?? '';
                          final isMe = senderId == user?.dbId || senderId == user?.uid;
                          return _ChatBubble(
                            message: msg,
                            isMe: isMe,
                            time: _formatTime(msg['createdAt']),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: const Color(0xFF111111),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    enabled: !_sending,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a group message...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF4A7BFF),
                  child: IconButton(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;
  final String time;

  const _ChatBubble({required this.message, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    final senderName = message['senderName']?.toString() ?? 'User';
    final text = message['text']?.toString() ?? message['content']?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF4A7BFF).withOpacity(0.15),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style: const TextStyle(color: Color(0xFF4A7BFF), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(senderName, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF4A7BFF) : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
