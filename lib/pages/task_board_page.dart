import 'package:flutter/material.dart';
import '../models/unit_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TaskBoardPage extends StatefulWidget {
  final UnitModel unit;
  const TaskBoardPage({super.key, required this.unit});

  @override
  State<TaskBoardPage> createState() => _TaskBoardPageState();
}

class _TaskBoardPageState extends State<TaskBoardPage> {
  final _api = ApiService();
  List<dynamic> _tasks = [];
  bool _loading = true;

  static const _statuses = ['To Do', 'In Progress', 'Done'];
  static const _statusColors = {
    'To Do': Color(0xFF888888),
    'In Progress': Color(0xFFFFAA00),
    'Done': Color(0xFF4CAF50),
  };
  static const _statusIcons = {
    'To Do': Icons.radio_button_unchecked,
    'In Progress': Icons.timelapse,
    'Done': Icons.check_circle_outline,
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final uid = AuthService.instance.currentAppUser?.dbId;
      final tasks = await _api.listTasksByUnit(widget.unit.id, studentId: uid);
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading board: $e')));
      }
    }
  }

  Future<void> _moveTask(dynamic task, String status) async {
    try {
      final hours = status == 'Done' ? _num(task['estimatedHours']) : 0.0;
      await _api.updateTaskStatus(taskId: task['id'], status: status, completedHours: hours);
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
      }
    }
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final totalH = _tasks.fold<double>(0, (s, t) => s + _num(t['estimatedHours']));
    final doneH = _tasks.where((t) => t['status'] == 'Done').fold<double>(0, (s, t) => s + _num(t['estimatedHours']));
    final pct = totalH > 0 ? (doneH / totalH).clamp(0.0, 1.0) : 0.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('${widget.unit.code} — Board'),
          backgroundColor: const Color(0xFF000000),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: const Color(0xFF4A7BFF),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: _statuses.map((s) {
              final color = _statusColors[s]!;
              return Tab(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_statusIcons[s], size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList(),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadTasks,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          _stat('Total', '${totalH.toStringAsFixed(1)}h', Colors.white54),
                          _stat('Completed', '${doneH.toStringAsFixed(1)}h', const Color(0xFF4CAF50)),
                          _stat('Progress', '${(pct * 100).toInt()}%', const Color(0xFF4A7BFF)),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF4A7BFF)),
                            minHeight: 8,
                          ),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: _statuses.map((status) {
                          final col = _tasks.where((t) => (t['status'] ?? 'To Do') == status).toList();
                          return _KanbanColumn(
                            tasks: col,
                            status: status,
                            color: _statusColors[status]!,
                            onMove: _moveTask,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _stat(String label, String val, Color color) => Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]);
}

class _KanbanColumn extends StatelessWidget {
  final List<dynamic> tasks;
  final String status;
  final Color color;
  final Future<void> Function(dynamic task, String status) onMove;
  const _KanbanColumn({required this.tasks, required this.status, required this.color, required this.onMove});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.inbox_outlined, size: 48, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Center(child: Text('No tasks in "$status"', style: const TextStyle(color: Colors.white24, fontSize: 13))),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _TaskCard(task: tasks[i], color: color, onMove: onMove),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final dynamic task;
  final Color color;
  final Future<void> Function(dynamic task, String status) onMove;
  const _TaskCard({required this.task, required this.color, required this.onMove});

  static const _priorityColors = {
    'High': Color(0xFFFF4444),
    'Medium': Color(0xFFFFAA00),
    'Low': Color(0xFF4A7BFF),
  };

  static const _nextStatus = {'To Do': 'In Progress', 'In Progress': 'Done', 'Done': 'To Do'};
  static const _nextLabel = {'To Do': 'Start', 'In Progress': 'Mark Done', 'Done': 'Reopen'};

  DateTime? _date(dynamic value) => DateTime.tryParse(value?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    final priority = task['priority']?.toString() ?? 'Medium';
    final status = task['status']?.toString() ?? 'To Do';
    final pc = _priorityColors[priority] ?? const Color(0xFF4A7BFF);
    final due = _date(task['dueDate']);
    final estimated = task['estimatedHours'] is num ? (task['estimatedHours'] as num).toDouble() : double.tryParse('${task['estimatedHours']}') ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          task['title']?.toString() ?? 'Untitled task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: status == 'Done' ? TextDecoration.lineThrough : null,
          ),
        ),
        if ((task['description'] ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(task['description'].toString(), style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
        const SizedBox(height: 10),
        Row(children: [
          _chip(priority, pc),
          _chip('${estimated.toStringAsFixed(1)}h', Colors.white38),
          if (due != null) _chip('${due.day}/${due.month}/${due.year}', Colors.white38),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(side: BorderSide(color: color.withValues(alpha: 0.6)), foregroundColor: color),
            onPressed: () => onMove(task, _nextStatus[status] ?? 'To Do'),
            child: Text(_nextLabel[status] ?? 'Update'),
          ),
        ),
      ]),
    );
  }

  Widget _chip(String text, Color color) => Container(
        margin: const EdgeInsets.only(right: 6, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}
