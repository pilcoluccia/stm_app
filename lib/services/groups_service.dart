import 'package:flutter/foundation.dart';

// Deprecated: Use ApiService instead
// Stub service for backward compatibility  
class GroupsService extends ChangeNotifier {
  static final GroupsService instance = GroupsService._();
  GroupsService._();

  Future<void> load() async {}
  dynamic forUnit(String unitId) => null;
}
