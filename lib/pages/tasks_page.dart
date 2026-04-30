import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _api = ApiService();
  String _filter = 'All'; // All, High, Medium, Low

  List<dynamic> _tasks = [];
  List<dynamic> _enrolledUnits = [];
  bool _loading = true;

  static const _priorityColors = {
    'High': Color(0xFFFF4444),
    'Medium': Color(0xFFFFAA00),
    'Low': Color(0xFF4A7BFF),
  };

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

      // Load enrolled units
      final enrollments = await _api.listStudentEnrollments(uid);
      final units =
          enrollments.map((e) => e['unit']).where((u) => u != null).toList();

      // Load personal tasks (assigned to this student)
      final personalTasks = await _api.listTasksByUser(uid);

      // Load unit tasks (tasks for all enrolled units)
      final allTasks = <dynamic>[...personalTasks];
      final seenTaskIds = <String>{};

      // Add personal task IDs to avoid duplicates
      for (final task in personalTasks) {
        if (task['id'] != null) seenTaskIds.add(task['id']);
      }

      // Load tasks from each enrolled unit
      for (final unit in units) {
        if (unit['id'] != null) {
          final unitTasks = await _api.listTasksByUnit(unit['id']);
          for (final task in unitTasks) {
            // Only add if not already in the list (avoid duplicates)
            if (task['id'] != null && !seenTaskIds.contains(task['id'])) {
              allTasks.add(task);
              seenTaskIds.add(task['id']);
            }
          }
        }
      }

      // Sort by due date
      allTasks.sort((a, b) {
        final dateA = a['dueDate'] != null ? DateTime.tryParse(a['dueDate']) : null;
        final dateB = b['dueDate'] != null ? DateTime.tryParse(b['dueDate']) : null;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      setState(() {
        _tasks = allTasks;
        _enrolledUnits = units;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  void _openAdd() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'Medium';
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    double estimatedHours = 2.0;
    String? selectedUnitId;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Personal Task',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Create your own study tasks and reminders',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Task title',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Priority
                DropdownButtonFormField<String>(
                  value: priority,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    labelText: 'Priority',
                    labelStyle: const TextStyle(color: Colors.white54),
                  ),
                  items: ['High', 'Medium', 'Low']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setModal(() => priority = v!),
                ),
                const SizedBox(height: 12),

                // Estimated hours
                TextField(
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Estimated hours',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null) estimatedHours = parsed;
                  },
                ),
                const SizedBox(height: 12),

                // Unit picker (OPTIONAL)
                DropdownButtonFormField<String>(
                  value: selectedUnitId,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    labelText: 'Related Unit (Optional)',
                    labelStyle: const TextStyle(color: Colors.white54),
                    helperText: 'Link to a unit if this task is for a class',
                    helperStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No unit (personal task)'),
                    ),
                    ..._enrolledUnits.map<DropdownMenuItem<String>>((u) =>
                        DropdownMenuItem<String>(
                            value: u['id'] as String,
                            child: Text('${u['code']} — ${u['name']}'))),
                  ],
                  onChanged: (v) => setModal(() => selectedUnitId = v),
                ),
                const SizedBox(height: 12),

                // Due date
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (c, child) => Theme(
                        data: ThemeData.dark(),
                        child: child!,
                      ),
                    );
                    if (picked != null) setModal(() => dueDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7BFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            if (titleCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter a title')),
                              );
                              return;
                            }

                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;

                            setModal(() => saving = true);

                            try {
                              await _api.createTask(
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                status: 'To Do',
                                priority: priority,
                                dueDate: dueDate,
                                estimatedHours: estimatedHours,
                                assignedToId: uid,
                                unitId: selectedUnitId ?? '', // Empty if no unit
                              );

                              if (ctx.mounted) Navigator.pop(ctx);
                              await _loadData();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Personal task created!')),
                                );
                              }
                            } catch (e) {
                              setModal(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                      content: Text('Error creating task: $e')),
                                );
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create Task',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _api.deleteTask(taskId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  Future<void> _toggleTaskStatus(dynamic task) async {
    try {
      final currentStatus = task['status'] ?? 'To Do';
      final newStatus = currentStatus == 'Done' ? 'To Do' : 'Done';

      await _api.updateTaskStatus(
        taskId: task['id'],
        status: newStatus,
        completedHours:
            newStatus == 'Done' ? (task['estimatedHours'] ?? 0.0) : 0.0,
      );

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? _tasks
        : _tasks.where((t) => t['priority'] == _filter).toList();

    final done = filtered.where((t) => t['status'] == 'Done').length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: const Color(0xFF000000),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A7BFF),
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Stats bar ──────────────────────────────
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Total', '${filtered.length}', Colors.white70),
                      _stat('Done', '$done', const Color(0xFF4CAF50)),
                      _stat('Pending', '${filtered.length - done}',
                          const Color(0xFFFFAA00)),
                    ],
                  ),
                ),

                // ── Priority filter ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ['All', 'High', 'Medium', 'Low'].map((f) {
                      final selected = _filter == f;
                      final color =
                          f == 'All' ? Colors.white : _priorityColors[f]!;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            margin: EdgeInsets.only(right: f == 'Low' ? 0 : 8),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      selected ? color : Colors.white24),
                            ),
                            child: Text(f,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selected ? color : Colors.white38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Task list ─────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No tasks yet — tap + to add one.',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 14)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final t = filtered[i];
                            final pc = _priorityColors[t['priority']] ??
                                const Color(0xFF4A7BFF);
                            final isDone = t['status'] == 'Done';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border(
                                    left: BorderSide(color: pc, width: 3)),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isDone,
                                    onChanged: (_) => _toggleTaskStatus(t),
                                    activeColor: const Color(0xFF4A7BFF),
                                    side: const BorderSide(
                                        color: Colors.white38),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(t['title'] ?? '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              decoration: isDone
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            )),
                                        if (t['description'] != null &&
                                            t['description'].isNotEmpty)
                                          Text(t['description'],
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          _chip(t['priority'], pc),
                                          _chip(
                                              '${(t['estimatedHours'] ?? 0).toStringAsFixed(1)}h',
                                              const Color(0xFF4A7BFF)),
                                          if (t['dueDate'] != null)
                                            _chip(
                                              _formatDate(t['dueDate']),
                                              Colors.white24,
                                            ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 20),
                                    onPressed: () => _deleteTask(t['id']),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Widget _stat(String label, String val, Color color) => Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      );

  Widget _chip(String label, Color color) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 10)),
      );
}
