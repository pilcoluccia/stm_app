import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // URL del backend (cambiar según ambiente)
  static const String baseUrl = 'http://localhost:5000/api';

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Obtener token de autenticación
  Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  // Headers con autenticación
  Future<Map<String, String>> _headers() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================================
  // USERS
  // ============================================================================

  Future<Map<String, dynamic>> createUser({
    required String uid,
    required String email,
    required String name,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/create'),
      headers: await _headers(),
      body: jsonEncode({
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUser(String uid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$uid'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  Future<List<dynamic>> listAllUsers({String? role}) async {
    var url = '$baseUrl/users';
    if (role != null) {
      url += '?role=$role';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['users'] ?? [];
    } else {
      throw Exception('Failed to list users: ${response.body}');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? program,
    int? year,
    String? department,
    String? photoUrl,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$uid/profile'),
      headers: await _headers(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (program != null) 'program': program,
        if (year != null) 'year': year,
        if (department != null) 'department': department,
        if (photoUrl != null) 'photoUrl': photoUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$uid/role'),
      headers: await _headers(),
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update role: ${response.body}');
    }
  }

  Future<void> deleteUser(String uid) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$uid'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // ============================================================================
  // TASKS
  // ============================================================================

  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    required String status,
    required String priority,
    required DateTime dueDate,
    required double estimatedHours,
    required String assignedToId,
    required String unitId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'description': description ?? '',
        'status': status,
        'priority': priority,
        'dueDate': dueDate.toIso8601String(),
        'estimatedHours': estimatedHours,
        'assignedToId': assignedToId,
        'unitId': unitId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  Future<List<dynamic>> listTasksByUser(String userId, {String? status}) async {
    var url = '$baseUrl/tasks/user/$userId';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['tasks'] ?? [];
    } else {
      throw Exception('Failed to list tasks: ${response.body}');
    }
  }

  Future<List<dynamic>> listTasksByUnit(String unitId, {String? assignedToId}) async {
    var url = '$baseUrl/tasks/unit/$unitId';
    if (assignedToId != null) {
      url += '?assignedToId=$assignedToId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['tasks'] ?? [];
    } else {
      throw Exception('Failed to list tasks by unit: ${response.body}');
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String status,
    double? completedHours,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId/status'),
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
        if (completedHours != null) 'completedHours': completedHours,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task status: ${response.body}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

  // ============================================================================
  // UNITS
  // ============================================================================

  Future<Map<String, dynamic>> createUnit({
    required String code,
    required String name,
    String? description,
    required int credits,
    required String semester,
    required int maxStudents,
    required String lecturerId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/units'),
      headers: await _headers(),
      body: jsonEncode({
        'code': code,
        'name': name,
        'description': description ?? '',
        'credits': credits,
        'semester': semester,
        'maxStudents': maxStudents,
        'lecturerId': lecturerId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create unit: ${response.body}');
    }
  }

  Future<List<dynamic>> listAllUnits({String? lecturerId}) async {
    var url = '$baseUrl/units';
    if (lecturerId != null) {
      url += '?lecturerId=$lecturerId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['units'] ?? [];
    } else {
      throw Exception('Failed to list units: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUnitByCode(String code) async {
    final response = await http.get(
      Uri.parse('$baseUrl/units/code/$code'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unit'];
    } else {
      throw Exception('Failed to get unit: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUnit(String unitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/units/$unitId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unit'];
    } else {
      throw Exception('Failed to get unit: ${response.body}');
    }
  }

  // ============================================================================
  // ENROLLMENTS
  // ============================================================================

  Future<Map<String, dynamic>> enrollStudent({
    required String studentId,
    required String unitId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/enrollments'),
      headers: await _headers(),
      body: jsonEncode({
        'studentId': studentId,
        'unitId': unitId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to enroll student: ${response.body}');
    }
  }

  Future<List<dynamic>> listEnrolledStudents(String unitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/enrollments/unit/$unitId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['enrollments'] ?? [];
    } else {
      throw Exception('Failed to list enrolled students: ${response.body}');
    }
  }

  Future<List<dynamic>> listStudentEnrollments(String studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/enrollments/student/$studentId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['enrollments'] ?? [];
    } else {
      throw Exception('Failed to list student enrollments: ${response.body}');
    }
  }

  Future<void> dropEnrollment({
    required String studentId,
    required String unitId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/enrollments'),
      headers: await _headers(),
      body: jsonEncode({
        'studentId': studentId,
        'unitId': unitId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to drop enrollment: ${response.body}');
    }
  }

  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================

  Future<List<dynamic>> listNotifications(String userId, {bool unreadOnly = false}) async {
    var url = '$baseUrl/notifications/user/$userId';
    if (unreadOnly) {
      url += '?unreadOnly=true';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['notifications'] ?? [];
    } else {
      throw Exception('Failed to list notifications: ${response.body}');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/user/$userId/read-all'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read: ${response.body}');
    }
  }

  // ============================================================================
  // STUDY SESSIONS
  // ============================================================================

  Future<Map<String, dynamic>> createStudySession({
    required String userId,
    required int durationSeconds,
    String sessionType = 'focus',
    String? taskId,
    String? unitId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/study-sessions'),
      headers: await _headers(),
      body: jsonEncode({
        'userId': userId,
        'durationSeconds': durationSeconds,
        'sessionType': sessionType,
        if (taskId != null) 'taskId': taskId,
        if (unitId != null) 'unitId': unitId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create study session: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTotalStudyTime(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/study-sessions/total/$userId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get total study time: ${response.body}');
    }
  }

  Future<List<dynamic>> listStudySessions(String userId, {int? limit}) async {
    var url = '$baseUrl/study-sessions/user/$userId';
    if (limit != null) {
      url += '?limit=$limit';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['sessions'] ?? [];
    } else {
      throw Exception('Failed to list study sessions: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getStudyStats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/study-sessions/stats/$userId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get study stats: ${response.body}');
    }
  }
}
