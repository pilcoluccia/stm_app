import 'package:flutter/foundation.dart';

// Deprecated: Use ApiService instead  
// Stub service for backward compatibility
class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._();
  ChatService._();

  Future<void> loadMessages(String groupId) async {}
  Future<void> sendMessage({required String groupId, required String text}) async {}
  List<dynamic> messagesForGroup(String groupId) => [];
}
