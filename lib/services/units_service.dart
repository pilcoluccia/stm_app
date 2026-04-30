import 'package:flutter/foundation.dart';

// Deprecated: Use ApiService instead
// Stub service for backward compatibility
class UnitsService extends ChangeNotifier {
  static final UnitsService instance = UnitsService._();
  UnitsService._();

  List<dynamic> get allUnits => [];
  List<dynamic> get enrolledUnits => [];
  
  Future<void> loadAll() async {}
  Future<void> enroll(String unitId) async {}
  Future<void> drop(String unitId) async {}
  bool isEnrolled(String unitId) => false;
}
