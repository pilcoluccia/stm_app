import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'tasks_page.dart';
import 'units_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _api = ApiService();
  List<dynamic> _tasks = [];
  List<dynamic> _units = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final enrollments = await _api.listStudentEnrollments(uid);
      final units = enrollments.map((e) => e['unit']).where((u) => u != null).toList();
      final personalTasks = await _api.listTasksByUser(uid);
      final allTasks = <dynamic>[...personalTasks];
      final seenTaskIds = <String>{};

      for (final task in personalTasks) {
        if (task['id'] != null) seenTaskIds.add(task['id'].toString());
      }

      for (final unit in units) {
        if (unit['id'] != null) {
          final unitTasks = await _api.listTasksByUnit(unit['id'].toString());
          for (final task in unitTasks) {
            final id = task['id']?.toString();
            if (id != null && !seenTaskIds.contains(id)) {
              allTasks.add(task);
              seenTaskIds.add(id);
            }
          }
        }
      }

      allTasks.sort((a, b) {
        final dateA = DateTime.tryParse((a['dueDate'] ?? '').toString());
        final dateB = DateTime.tryParse((b['dueDate'] ?? '').toString());
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      if (mounted) {
        setState(() {
          _tasks = allTasks;
          _units = units;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  String _daysLeft(DateTime due) {
    final today = DateTime.now();
    final cleanToday = DateTime(today.year, today.month, today.day);
    final cleanDue = DateTime(due.year, due.month, due.day);
    final diff = cleanDue.difference(cleanToday).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in $diff days';
  }

  Color _dueColor(DateTime due) {
    final diff = due.difference(DateTime.now()).inDays;
    if (diff < 0) return Colors.red;
    if (diff <= 2) return const Color(0xFFFFAA00);
    return Colors.white70;
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  DateTime? _date(dynamic value) => DateTime.tryParse(value?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((t) => t['status'] == 'Done').length;
    final totalHours = _tasks
        .where((t) => t['status'] == 'Done')
        .fold<double>(0, (sum, t) => sum + _num(t['estimatedHours']));
    final upcoming = _tasks.where((t) => t['status'] != 'Done' && _date(t['dueDate']) != null).toList()
      ..sort((a, b) => _date(a['dueDate'])!.compareTo(_date(b['dueDate'])!));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'My Units', value: '${_units.length}')),
                        Expanded(child: _StatCard(label: 'Tasks Done', value: '$done/${_tasks.length}')),
                        Expanded(child: _StatCard(label: 'Study Hours', value: '${totalHours.toStringAsFixed(1)}h')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
                      child: const Text(
                        'New lecturer units appear in All Units. After you enrol, lecturer tasks for that unit appear here, in Tasks, Calendar, and Subject Details.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Units', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitsPage())).then((_) => _loadData()),
                          child: const Text('See units', style: TextStyle(color: Color(0xFF4A7BFF))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_units.isEmpty)
                      const _EmptyBox(text: 'No enrolled units yet. Open Units and enrol in available units.')
                    else
                      ..._units.take(3).map((unit) => _UnitCard(unit: unit)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Upcoming Deadlines', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksPage())).then((_) => _loadData()),
                          child: const Text('See all', style: TextStyle(color: Color(0xFF4A7BFF))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (upcoming.isEmpty)
                      const _EmptyBox(text: 'No upcoming deadlines yet.')
                    else
                      ...upcoming.take(5).map((task) {
                        final due = _date(task['dueDate'])!;
                        return _DeadlineCard(task: task, daysLeft: _daysLeft(due), dueColor: _dueColor(due));
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(value, style: const TextStyle(color: Color(0xFF4A7BFF), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      );
}

class _UnitCard extends StatelessWidget {
  final dynamic unit;
  const _UnitCard({required this.unit});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.school_outlined, color: Color(0xFF4A7BFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${unit['code'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('${unit['name'] ?? ''}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ]),
      );
}

class _DeadlineCard extends StatelessWidget {
  final dynamic task;
  final String daysLeft;
  final Color dueColor;
  const _DeadlineCard({required this.task, required this.daysLeft, required this.dueColor});

  static const _priorityColors = {
    'High': Color(0xFFFF4444),
    'Medium': Color(0xFFFFAA00),
    'Low': Color(0xFF4A7BFF),
  };

  @override
  Widget build(BuildContext context) {
    final priority = task['priority']?.toString() ?? 'Medium';
    final pc = _priorityColors[priority] ?? const Color(0xFF4A7BFF);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: pc, width: 3))),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task['title']?.toString() ?? 'Untitled task', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.access_time, size: 12, color: dueColor),
              const SizedBox(width: 4),
              Text(daysLeft, style: TextStyle(color: dueColor, fontSize: 12)),
              if ((task['unitCode'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('· ${task['unitCode']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ]),
          ]),
        ),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ]),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      );
}
