import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _api = ApiService();
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  List<dynamic> _tasks = [];
  List<dynamic> _enrolledUnits = [];
  bool _loading = true;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static const _priorityColors = {
    'High': Color(0xFFFF4444),
    'Medium': Color(0xFFFFAA00),
    'Low': Color(0xFF4A7BFF),
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
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

  List<dynamic> _tasksForDate(DateTime date) {
    return _tasks.where((task) {
      try {
        final dueDate = task['dueDate'];
        if (dueDate == null) return false;

        DateTime taskDate;
        if (dueDate is String) {
          taskDate = DateTime.parse(dueDate);
        } else {
          return false;
        }

        return taskDate.year == date.year &&
            taskDate.month == date.month &&
            taskDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  void _previousMonth() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _nextMonth() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  void _openAddTask(DateTime day) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'Medium';
    DateTime dueDate = day;
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
                Text(
                    'New Task for ${_monthNames[day.month - 1]} ${day.day}, ${day.year}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
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
                                unitId: selectedUnitId ?? '',
                              );

                              if (ctx.mounted) Navigator.pop(ctx);
                              await _loadData();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Task created!')),
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

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final today = DateTime.now();
    final startOffset = firstDay.weekday - 1;
    final rows = ((startOffset + lastDay.day) / 7).ceil();

    return Column(
      children: [
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        for (int row = 0; row < rows; row++)
          Row(
            children: List.generate(7, (col) {
              final dayNum = row * 7 + col - startOffset + 1;
              if (dayNum < 1 || dayNum > lastDay.day) {
                return const Expanded(child: SizedBox(height: 44));
              }
              final day =
                  DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final isSelected = _selectedDay != null &&
                  day.year == _selectedDay!.year &&
                  day.month == _selectedDay!.month &&
                  day.day == _selectedDay!.day;
              final dayTasks = _tasksForDate(day);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A7BFF)
                          : dayTasks.isNotEmpty
                              ? const Color(0xFF4A7BFF).withValues(alpha: 0.25)
                              : isToday
                                  ? const Color(0xFF4A7BFF)
                                      .withValues(alpha: 0.15)
                                  : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: const Color(0xFF4A7BFF), width: 1.5)
                          : dayTasks.isNotEmpty && !isSelected
                              ? Border.all(
                                  color: const Color(0xFF4A7BFF)
                                      .withValues(alpha: 0.4),
                                  width: 1)
                              : null,
                    ),
                    child: Stack(
                      children: [
                        // Número del día y puntos
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$dayNum',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isToday || dayTasks.isNotEmpty
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                )),
                            if (dayTasks.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dayTasks
                                    .take(3)
                                    .map((t) => Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.only(
                                              top: 2, left: 1),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white
                                                : (_priorityColors[
                                                        t['priority']] ??
                                                    const Color(0xFF4A7BFF)),
                                            shape: BoxShape.circle,
                                          ),
                                        ))
                                    .toList(),
                              )
                            else
                              const SizedBox(height: 6),
                          ],
                        ),
                        // Badge de cantidad de tareas
                        if (dayTasks.length > 1 && !isSelected)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A7BFF),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '${dayTasks.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayTasks =
        _selectedDay != null ? _tasksForDate(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: const Color(0xFF000000),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Month grid ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: _previousMonth,
                                icon: const Icon(Icons.chevron_left,
                                    color: Colors.white),
                              ),
                              Text(
                                '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: _nextMonth,
                                icon: const Icon(Icons.chevron_right,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildCalendarGrid(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Day panel ───────────────────────────────
                    if (_selectedDay != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_monthNames[_selectedDay!.month - 1]} ${_selectedDay!.day}, ${_selectedDay!.year}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextButton.icon(
                                  onPressed: () => _openAddTask(_selectedDay!),
                                  icon: const Icon(Icons.add,
                                      color: Color(0xFF4A7BFF), size: 18),
                                  label: const Text('Add',
                                      style: TextStyle(
                                          color: Color(0xFF4A7BFF),
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white12),
                            if (dayTasks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'No tasks — tap "Add" to create one.',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 13),
                                ),
                              )
                            else
                              ...dayTasks.map((t) => _TaskTile(
                                    task: t,
                                    onDelete: () => _deleteTask(t['id']),
                                    onToggle: () => _toggleTaskStatus(t),
                                  )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _TaskTile({
    required this.task,
    required this.onDelete,
    required this.onToggle,
  });

  static const _priorityColors = {
    'High': Color(0xFFFF4444),
    'Medium': Color(0xFFFFAA00),
    'Low': Color(0xFF4A7BFF),
  };

  @override
  Widget build(BuildContext context) {
    final color = _priorityColors[task['priority']] ?? const Color(0xFF4A7BFF);
    final isDone = task['status'] == 'Done';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, color: color, size: 9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration:
                        isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                if (task['description'] != null &&
                    task['description'].isNotEmpty)
                  Text(task['description'],
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                Row(children: [
                  _chip(task['priority'] ?? 'Medium', color),
                  _chip(
                      '${(task['estimatedHours'] ?? 0).toStringAsFixed(1)}h',
                      Colors.white24),
                ]),
              ],
            ),
          ),
          Checkbox(
            value: isDone,
            onChanged: (_) => onToggle(),
            activeColor: const Color(0xFF4A7BFF),
            side: const BorderSide(color: Colors.white38),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        margin: const EdgeInsets.only(top: 3, right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 10)),
      );
}
