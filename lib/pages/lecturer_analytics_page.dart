import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LecturerAnalyticsPage extends StatefulWidget {
  const LecturerAnalyticsPage({super.key});

  @override
  State<LecturerAnalyticsPage> createState() => _LecturerAnalyticsPageState();
}

class _LecturerAnalyticsPageState extends State<LecturerAnalyticsPage> {
  final _api = ApiService();
  List<dynamic> _units = [];
  List<dynamic> _tasks = [];
  int _students = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final lecturerId = AuthService.instance.currentAppUser!.dbId;
      final units = await _api.listAllUnits(lecturerId: lecturerId);
      final tasks = <dynamic>[];
      final seenTasks = <String>{};
      final studentIds = <String>{};

      for (final unit in units) {
        final unitTasks = await _api.listTasksByUnit(unit['id']);
        for (final task in unitTasks) {
          final id = task['id']?.toString() ?? '';
          if (id.isNotEmpty && !seenTasks.contains(id)) {
            tasks.add(task);
            seenTasks.add(id);
          }
        }

        final enrollments = await _api.listEnrolledStudents(unit['id']);
        for (final enrollment in enrollments) {
          if (enrollment['status'] == 'active' && enrollment['studentId'] != null) {
            studentIds.add(enrollment['studentId'].toString());
          }
        }
      }

      setState(() {
        _units = units;
        _tasks = tasks;
        _students = studentIds.length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final done = _tasks.where((t) => t['status'] == 'Done').length;
    final inProgress = _tasks.where((t) => t['status'] == 'In Progress').length;
    final toDo = _tasks.where((t) => t['status'] == 'To Do').length;
    final high = _tasks.where((t) => t['priority'] == 'High').length;
    final completion = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Teaching Overview',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _stat('Units', '${_units.length}', Icons.school_outlined, const Color(0xFF4A7BFF)),
                      const SizedBox(width: 10),
                      _stat('Students', '$_students', Icons.people_outline, const Color(0xFF4CAF50)),
                      const SizedBox(width: 10),
                      _stat('Tasks', '$total', Icons.task_outlined, const Color(0xFFFFAA00)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Overall Task Completion',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$done completed', style: const TextStyle(color: Color(0xFF4CAF50))),
                            Text('${(completion * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(color: Color(0xFF4A7BFF), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: completion,
                          minHeight: 10,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFF4A7BFF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tasks by Status',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _statusRow('To Do', toDo, Colors.white38),
                  _statusRow('In Progress', inProgress, const Color(0xFFFFAA00)),
                  _statusRow('Done', done, const Color(0xFF4CAF50)),
                  _statusRow('High Priority', high, Colors.redAccent),
                ],
              ),
            ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, int value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15))),
          Text('$value', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
