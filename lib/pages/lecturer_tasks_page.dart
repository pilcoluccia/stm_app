import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LecturerTasksPage extends StatefulWidget {
  const LecturerTasksPage({super.key});

  @override
  State<LecturerTasksPage> createState() => _LecturerTasksPageState();
}

class _LecturerTasksPageState extends State<LecturerTasksPage> {
  final _api = ApiService();
  List<dynamic> _units = [];
  List<dynamic> _tasks = [];
  bool _loadingUnits = true;
  bool _loadingTasks = false;

  String? _selectedUnitId;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() => _loadingUnits = true);
    try {
      final lecturerId = AuthService.instance.currentAppUser!.dbId;
      final units = await _api.listAllUnits(lecturerId: lecturerId);
      setState(() {
        _units = units;
        _loadingUnits = false;
      });
    } catch (e) {
      setState(() => _loadingUnits = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading units: $e')),
        );
      }
    }
  }

  Future<void> _loadTasks(String unitId) async {
    setState(() {
      _loadingTasks = true;
    });
    try {
      final tasks = await _api.listTasksByUnit(unitId);
      setState(() {
        _tasks = tasks;
        _loadingTasks = false;
      });
    } catch (e) {
      setState(() => _loadingTasks = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  void _showCreateTaskDialog() {
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a unit first')),
      );
      return;
    }

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '2.0');
    String priority = 'Medium';
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Create Unit Task',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This task will be visible to ALL students enrolled in this unit',
                    style: TextStyle(color: Color(0xFF4A7BFF), fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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
                      labelText: 'Priority',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['High', 'Medium', 'Low']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => priority = v!),
                  ),
                  const SizedBox(height: 12),

                  // Estimated hours
                  TextField(
                    controller: hoursCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Estimated Hours',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Due date
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                        builder: (c, child) => Theme(
                          data: ThemeData.dark(),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() => dueDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7BFF)),
              onPressed: saving
                  ? null
                  : () => _createTask(
                        context,
                        titleCtrl.text,
                        descCtrl.text,
                        priority,
                        dueDate,
                        double.tryParse(hoursCtrl.text) ?? 2.0,
                        setDialogState,
                      ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create for All Students'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTask(
    BuildContext dialogContext,
    String title,
    String description,
    String priority,
    DateTime dueDate,
    double estimatedHours,
    StateSetter setDialogState,
  ) async {
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setDialogState(() {});
    setState(() {});

    try {
      // Crear tarea vinculada a la UNIT, no a estudiante específico
      await _api.createTask(
        title: title,
        description: description,
        status: 'To Do',
        priority: priority,
        dueDate: dueDate,
        estimatedHours: estimatedHours,
        assignedToId: '', // Vacío - tarea de unit
        unitId: _selectedUnitId!,
      );

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Task created for all enrolled students!')),
        );
        _loadTasks(_selectedUnitId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnit = _selectedUnitId != null
        ? _units.firstWhere((u) => u['id'] == _selectedUnitId,
            orElse: () => null)
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Create Tasks'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
      ),
      floatingActionButton: _selectedUnitId != null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF4A7BFF),
              onPressed: _showCreateTaskDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: _loadingUnits
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Select Unit ────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Select Unit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),

                // Unit list
                if (_units.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No units assigned to you',
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _units.length,
                      itemBuilder: (context, index) {
                        final unit = _units[index];
                        final isSelected = _selectedUnitId == unit['id'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedUnitId = unit['id'];
                            });
                            _loadTasks(unit['id']);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4A7BFF)
                                      .withValues(alpha: 0.2)
                                  : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF4A7BFF), width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF4A7BFF), size: 20)
                                else
                                  const Icon(Icons.radio_button_unchecked,
                                      color: Colors.white38, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(unit['code'] ?? '',
                                          style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFF4A7BFF)
                                                  : Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      Text(unit['name'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13)),
                                      Text(
                                          '${unit['credits'] ?? 0} credits • ${unit['semester'] ?? ''}',
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // ── Unit Tasks ─────────────────────────────
                if (_selectedUnitId != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unit Tasks',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            Text(
                                '${selectedUnit != null ? selectedUnit['code'] : ''} - All enrolled students will see these',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loadingTasks
                        ? const Center(child: CircularProgressIndicator())
                        : _tasks.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.task_outlined,
                                        size: 48, color: Colors.white30),
                                    SizedBox(height: 12),
                                    Text('No tasks yet — tap + to create one',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 14)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _tasks.length,
                                itemBuilder: (context, index) {
                                  final task = _tasks[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border(
                                          left: BorderSide(
                                              color: _priorityColor(
                                                  task['priority']),
                                              width: 3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(task['title'] ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            _chip(task['priority'] ?? 'Medium',
                                                _priorityColor(
                                                    task['priority'])),
                                          ],
                                        ),
                                        if (task['description'] != null &&
                                            task['description'].isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(task['description'],
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13)),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _chip(
                                                '${(task['estimatedHours'] ?? 0).toStringAsFixed(1)}h',
                                                Colors.white38),
                                            if (task['dueDate'] != null)
                                              _chip(
                                                  _formatDate(task['dueDate']),
                                                  Colors.white38),
                                            const Spacer(),
                                            const Icon(Icons.people,
                                                size: 14,
                                                color: Color(0xFF4A7BFF)),
                                            const SizedBox(width: 4),
                                            const Text('All students',
                                                style: TextStyle(
                                                    color: Color(0xFF4A7BFF),
                                                    fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ] else
                  const Expanded(
                    child: Center(
                      child: Text('Select a unit to view and create tasks',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                  ),
              ],
            ),
    );
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFFF4444);
      case 'Medium':
        return const Color(0xFFFFAA00);
      case 'Low':
        return const Color(0xFF4A7BFF);
      default:
        return const Color(0xFF4A7BFF);
    }
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

  Widget _chip(String label, Color color) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 10)),
      );
}
