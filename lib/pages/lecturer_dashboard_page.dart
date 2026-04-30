import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'lecturer_tasks_page.dart';

class _UnitWithEnrollments {
  final String id;
  final String code;
  final String name;
  final int students;
  const _UnitWithEnrollments({
    required this.id,
    required this.code,
    required this.name,
    required this.students,
  });
}

class LecturerDashboardPage extends StatefulWidget {
  const LecturerDashboardPage({super.key});

  @override
  State<LecturerDashboardPage> createState() => _LecturerDashboardPageState();
}

class _LecturerDashboardPageState extends State<LecturerDashboardPage> {
  final _api = ApiService();
  List<_UnitWithEnrollments> _units = [];
  List<dynamic> _allTasks = [];
  bool _loading = true;

  static const _statusColors = {
    'To Do': Color(0xFF888888),
    'In Progress': Color(0xFFFFAA00),
    'Done': Color(0xFF4CAF50),
  };

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

      // Load all tasks for this lecturer's units
      final allTasks = <dynamic>[];
      final seenTaskIds = <String>{};

      for (final unit in units) {
        final unitTasks = await _api.listTasksByUnit(unit['id']);
        for (final task in unitTasks) {
          if (task['id'] != null && !seenTaskIds.contains(task['id'])) {
            allTasks.add(task);
            seenTaskIds.add(task['id']);
          }
        }
      }

      final unitsWithEnrollments = <_UnitWithEnrollments>[];
      for (final unit in units) {
        final enrollments = await _api.listEnrolledStudents(unit['id']);
        final activeStudents = enrollments
            .where((e) => e['status'] == 'active')
            .length;
        unitsWithEnrollments.add(_UnitWithEnrollments(
          id: unit['id'],
          code: unit['code'],
          name: unit['name'],
          students: activeStudents,
        ));
      }

      setState(() {
        _units = unitsWithEnrollments;
        _allTasks = allTasks;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task, color: Color(0xFF4A7BFF)),
            tooltip: 'Create Task',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LecturerTasksPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
        builder: (context) {
          final toDo =
              _allTasks.where((t) => t['status'] == 'To Do').length;
          final inProg =
              _allTasks.where((t) => t['status'] == 'In Progress').length;
          final done =
              _allTasks.where((t) => t['status'] == 'Done').length;
          final totalH =
              _allTasks.fold<double>(0, (s, t) => s + (t['estimatedHours'] ?? 0.0));
          final doneH =
              _allTasks.fold<double>(0, (s, t) => s + (t['completedHours'] ?? 0.0));
          final pct =
              totalH > 0 ? (doneH / totalH).clamp(0.0, 1.0) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome ───────────────────────────────
                const Text('Overview',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // ── Top stats ─────────────────────────────
                Row(children: [
                  _StatCard(
                      label: 'Units',
                      value: '${_units.length}',
                      icon: Icons.school_outlined,
                      color: const Color(0xFF4A7BFF)),
                  const SizedBox(width: 10),
                  _StatCard(
                      label: 'Students',
                      value: '${_units.fold<int>(0, (s, u) => s + u.students)}',
                      icon: Icons.people_outline,
                      color: const Color(0xFF4CAF50)),
                  const SizedBox(width: 10),
                  _StatCard(
                      label: 'Tasks',
                      value: '${_allTasks.length}',
                      icon: Icons.task_outlined,
                      color: const Color(0xFFFFAA00)),
                ]),
                const SizedBox(height: 20),

                // ── Overall progress ─────────────────────
                const Text('Overall Progress',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _progStat('Total Hours',
                            '${totalH.toStringAsFixed(1)}h',
                            Colors.white54),
                        _progStat('Completed',
                            '${doneH.toStringAsFixed(1)}h',
                            const Color(0xFF4CAF50)),
                        _progStat('Progress',
                            '${(pct * 100).toInt()}%',
                            const Color(0xFF4A7BFF)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF4A7BFF)),
                        minHeight: 10,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                // ── Task status ───────────────────────────
                const Text('Tasks by Status',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(children: [
                  _statusPill('To Do', toDo,
                      const Color(0xFF888888)),
                  const SizedBox(width: 8),
                  _statusPill('In Progress', inProg,
                      const Color(0xFFFFAA00)),
                  const SizedBox(width: 8),
                  _statusPill('Done', done,
                      const Color(0xFF4CAF50)),
                ]),
                const SizedBox(height: 20),

                // ── Units ─────────────────────────────────
                const Text('My Units',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._units.map((u) {
                  final unitTasks = _allTasks
                      .where((t) => t['unitId'] == u.id)
                      .toList();
                  final uTotalH = unitTasks.fold<double>(
                      0, (s, t) => s + (t['estimatedHours'] ?? 0.0));
                  final uDoneH = unitTasks.fold<double>(
                      0, (s, t) => s + (t['completedHours'] ?? 0.0));
                  final uPct = uTotalH > 0
                      ? (uDoneH / uTotalH).clamp(0.0, 1.0)
                      : 0.0;
                  final byStatus = {
                    'To Do': unitTasks
                        .where((t) => t['status'] == 'To Do')
                        .length,
                    'In Progress': unitTasks
                        .where((t) => t['status'] == 'In Progress')
                        .length,
                    'Done': unitTasks
                        .where((t) => t['status'] == 'Done')
                        .length,
                  };

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(u.code,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.bold)),
                                Text(u.name,
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text('${(uPct * 100).toInt()}%',
                                  style: const TextStyle(
                                      color: Color(0xFF4A7BFF),
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold)),
                              Text('${u.students} students',
                                  style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11)),
                            ],
                          ),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: uPct,
                            backgroundColor: Colors.white12,
                            valueColor:
                                const AlwaysStoppedAnimation(
                                    Color(0xFF4A7BFF)),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(children: byStatus.entries.map((e) {
                          final c = _statusColors[e.key] ??
                              Colors.white38;
                          return Expanded(
                            child: Row(children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('${e.value} ${e.key}',
                                  style: TextStyle(
                                      color: c, fontSize: 10)),
                            ]),
                          );
                        }).toList()),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
          ]),
        ),
      );
}

Widget _progStat(String label, String val, Color color) => Column(
      children: [
        Text(val,
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );

Widget _statusPill(String label, int count, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Text('$count',
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10)),
        ]),
      ),
    );
