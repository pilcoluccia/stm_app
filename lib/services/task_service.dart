import 'package:flutter/foundation.dart';

// Deprecated: Use ApiService instead
// Stub service for backward compatibility
class TaskService extends ChangeNotifier {
  static final TaskService instance = TaskService._();
  TaskService._();

  List<dynamic> get tasks => [];
  
  Future<void> load() async {}
  Future<void> create({
    required String title,
    String? description,
    required String priority,
    required DateTime dueDate,
    double? estimatedHours,
    required String unitId,
  }) async {}
  Future<void> update(dynamic task) async {}
  Future<void> delete(String id) async {}
  List<dynamic> forDate(DateTime date) => [];
}
