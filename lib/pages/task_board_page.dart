import 'package:flutter/material.dart';
import '../models/unit_model.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskBoardPage extends StatelessWidget {
  final UnitModel unit;
  const TaskBoardPage({super.key, required this.unit});

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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('${unit.code} — Board'),
          backgroundColor: const Color(0xFF000000),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: const Color(0xFF4A7BFF),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: _statuses.map((s) {
              final color = _statusColors[s]!;
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_statusIcons[s], size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(s,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        body: ListenableBuilder(
          listenable: TaskService.instance,
          builder: (context, _) {
            final unitTasks = TaskService.instance.tasks
                .where((t) => t.subject == unit.code)
                .toList();

            // ── Progress bar ──────────────────────────────
            final totalH = unitTasks.fold<double>(
                0, (s, t) => s + t.estimatedHours);
            final doneH = unitTasks.fold<double>(
                0, (s, t) => s + t.completedHours);
            final pct =
                totalH > 0 ? (doneH / totalH).clamp(0.0, 1.0) : 0.0;

            return Column(
              children: [
                // ── Hours progress ─────────────────────────
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _stat('Total', '${totalH.toStringAsFixed(1)}h',
                              Colors.white54),
                          _stat('Completed',
                              '${doneH.toStringAsFixed(1)}h',
                              const Color(0xFF4CAF50)),
                          _stat('Progress',
                              '${(pct * 100).toInt()}%',
                              const Color(0xFF4A7BFF)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF4A7BFF)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Kanban columns ─────────────────────────
                Expanded(
                  child: TabBarView(
                    children: _statuses.map((status) {
                      final col = unitTasks
                          .where((t) => t.status == status)
                          .toList()
                          .cast<Task>();
                      return _KanbanColumn(
                          tasks: col,
                          status: status,
                          color: _statusColors[status]!);
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stat(String label, String val, Color color) => Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
        ],
      );
}

// ── Kanban column ─────────────────────────────────────────────────────────────

class _KanbanColumn extends StatelessWidget {
  final List<Task> tasks;
  final String status;
  final Color color;
  const _KanbanColumn(
      {required this.tasks,
      required this.status,
      required this.color});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: color.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('No tasks in "$status"',
                style: const TextStyle(
                    color: Colors.white24, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _TaskCard(task: tasks[i], color: color),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final Color color;
  const _TaskCard({required this.task, required this.color});

  static const _priorityColors = {
    'High': Color(0xFFFF4444),
    'Medium': Color(0xFFFFAA00),
    'Low': Color(0xFF4A7BFF),
  };

  static const _nextStatus = {
    'To Do': 'In Progress',
    'In Progress': 'Done',
    'Done': 'To Do',
  };
  static const _nextLabel = {
    'To Do': 'Start',
    'In Progress': 'Mark Done',
    'Done': 'Reopen',
  };

  @override
  Widget build(BuildContext context) {
    final pc =
        _priorityColors[task.priority] ?? const Color(0xFF4A7BFF);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(task.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: task.isDone
                      ? TextDecoration.lineThrough
                      : null)),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(task.description,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),

          // Meta row
          Row(children: [
            _chip(task.priority, pc),
            _chip('${task.estimatedHours.toStringAsFixed(1)}h',
                Colors.white24),
            if (task.dueDate != null)
              _chip(
                  '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                  Colors.white24),
            const Spacer(),
            // Move button
            GestureDetector(
              onTap: () async {
                final next = _nextStatus[task.status] ?? 'To Do';
                task.status = next;
                if (next == 'Done') {
                  task.completedHours = task.estimatedHours;
                } else if (next == 'To Do') {
                  task.completedHours = 0;
                }
                await TaskService.instance.update(task);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_nextLabel[task.status] ?? 'Move',
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String label, Color c) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(color: c, fontSize: 10)),
      );
}
