import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'lecturer_task_detail_page.dart';

class LecturerUnitsPage extends StatefulWidget {
  const LecturerUnitsPage({super.key});

  @override
  State<LecturerUnitsPage> createState() => _LecturerUnitsPageState();
}

class _LecturerUnitsPageState extends State<LecturerUnitsPage> {
  final _api = ApiService();
  List<dynamic> _units = [];
  List<dynamic> _tasks = [];
  Map<String, int> _studentCounts = {};
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
      final counts = <String, int>{};

      for (final unit in units) {
        final unitId = unit['id']?.toString() ?? '';
        if (unitId.isEmpty) continue;
        final enrollments = await _api.listEnrolledStudents(unitId);
        counts[unitId] = enrollments.where((e) => e['status'] == 'active').length;
      }

      if (!mounted) return;
      setState(() {
        _units = units;
        _studentCounts = counts;
        _loadingUnits = false;
      });

      if (_selectedUnitId != null && units.any((u) => u['id'] == _selectedUnitId)) {
        await _loadTasks(_selectedUnitId!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingUnits = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading assigned units: $e')),
      );
    }
  }

  Future<void> _loadTasks(String unitId) async {
    setState(() => _loadingTasks = true);
    try {
      final tasks = await _api.listTasksByUnit(unitId);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loadingTasks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingTasks = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tasks: $e')),
      );
    }
  }

  void _selectUnit(dynamic unit) {
    final unitId = unit['id']?.toString() ?? '';
    if (unitId.isEmpty) return;
    setState(() {
      _selectedUnitId = unitId;
      _tasks = [];
    });
    _loadTasks(unitId);
  }

  Map<String, dynamic> _studentFromEnrollment(dynamic enrollment) {
    final student = enrollment['student'];
    if (student is Map) {
      final id = (student['uid'] ?? student['id'] ?? enrollment['studentId'] ?? '').toString();
      return {
        'id': id,
        'uid': id,
        'name': (student['name'] ?? student['email'] ?? id).toString(),
        'email': (student['email'] ?? '').toString(),
      };
    }
    final id = (enrollment['studentId'] ?? '').toString();
    return {'id': id, 'uid': id, 'name': id, 'email': ''};
  }

  Future<void> _showCreateTaskDialog() async {
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a unit first')),
      );
      return;
    }

    List<dynamic> enrolled = [];
    try {
      enrolled = await _api.listEnrolledStudents(_selectedUnitId!);
      enrolled = enrolled.where((e) => e['status'] == 'active').toList();
    } catch (_) {
      enrolled = [];
    }

    final students = enrolled.map(_studentFromEnrollment).where((s) => (s['id'] ?? '').toString().isNotEmpty).toList();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '2.0');
    String priority = 'Medium';
    String taskType = 'Individual';
    final individualStudentIds = students.map((s) => s['id'].toString()).toSet();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    bool saving = false;
    final groupDrafts = <Map<String, dynamic>>[];

    void addGroup() {
      groupDrafts.add({
        'nameCtrl': TextEditingController(text: 'Group ${groupDrafts.length + 1}'),
        'studentIds': <String>{},
      });
    }

    void disposeDrafts() {
      for (final draft in groupDrafts) {
        (draft['nameCtrl'] as TextEditingController).dispose();
      }
      titleCtrl.dispose();
      descCtrl.dispose();
      hoursCtrl.dispose();
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          if (taskType == 'Group' && groupDrafts.isEmpty) addGroup();

          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Create Task for Unit',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Individual to assign this task to selected students, or Group to create groups and assign students.',
                      style: TextStyle(color: Color(0xFF4A7BFF), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: _dialogInput('Task Title')),
                    const SizedBox(height: 12),
                    TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: _dialogInput('Description')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: priority,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      decoration: _dialogInput('Priority'),
                      items: ['High', 'Medium', 'Low'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setDialogState(() => priority = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: taskType,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      decoration: _dialogInput('Task Type'),
                      items: const [
                        DropdownMenuItem(value: 'Individual', child: Text('Individual task')),
                        DropdownMenuItem(value: 'Group', child: Text('Group task')),
                      ],
                      onChanged: (v) => setDialogState(() {
                        taskType = v!;
                        if (taskType == 'Group' && groupDrafts.isEmpty) addGroup();
                      }),
                    ),
                    if (taskType == 'Individual') ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Assign this task to students:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${individualStudentIds.length} of ${students.length} enrolled students selected',
                        style: const TextStyle(color: Color(0xFF4A7BFF), fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      if (students.isEmpty)
                        const Text(
                          'No enrolled students found for this unit. Ask admin to enrol students first.',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        )
                      else ...[
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => setDialogState(() {
                                individualStudentIds
                                  ..clear()
                                  ..addAll(students.map((s) => s['id'].toString()));
                              }),
                              icon: const Icon(Icons.select_all, size: 16),
                              label: const Text('Select All'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => setDialogState(individualStudentIds.clear),
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Clear'),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Column(
                            children: students.map((student) {
                              final id = student['id'].toString();
                              final label = student['email']?.toString().isNotEmpty == true
                                  ? '${student['name']} (${student['email']})'
                                  : student['name'].toString();
                              return CheckboxListTile(
                                value: individualStudentIds.contains(id),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                activeColor: const Color(0xFF4A7BFF),
                                checkColor: Colors.white,
                                title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                onChanged: (checked) => setDialogState(() {
                                  if (checked == true) {
                                    individualStudentIds.add(id);
                                  } else {
                                    individualStudentIds.remove(id);
                                  }
                                }),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                    if (taskType == 'Group') ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Group Setup',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => setDialogState(addGroup),
                            icon: const Icon(Icons.group_add, size: 16),
                            label: const Text('Add Group'),
                          ),
                        ],
                      ),
                      if (students.isEmpty)
                        const Text(
                          'No enrolled students found for this unit. Ask admin to enrol students first.',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        ),
                      ...groupDrafts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final draft = entry.value;
                        final nameCtrl = draft['nameCtrl'] as TextEditingController;
                        final selected = draft['studentIds'] as Set<String>;
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: nameCtrl,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: _dialogInput('Group name'),
                                    ),
                                  ),
                                  if (groupDrafts.length > 1)
                                    IconButton(
                                      onPressed: () => setDialogState(() {
                                        nameCtrl.dispose();
                                        groupDrafts.removeAt(index);
                                      }),
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Assign students to this group:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              ...students.map((student) {
                                final id = student['id'].toString();
                                final label = student['email']?.toString().isNotEmpty == true
                                    ? '${student['name']} (${student['email']})'
                                    : student['name'].toString();
                                return CheckboxListTile(
                                  value: selected.contains(id),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: const Color(0xFF4A7BFF),
                                  checkColor: Colors.white,
                                  title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  onChanged: (checked) => setDialogState(() {
                                    if (checked == true) {
                                      selected.add(id);
                                    } else {
                                      selected.remove(id);
                                    }
                                  }),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: hoursCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _dialogInput('Estimated Hours'),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
                        );
                        if (picked != null) setDialogState(() => dueDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                          const SizedBox(width: 8),
                          Text('Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}', style: const TextStyle(color: Colors.white)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7BFF)),
                onPressed: saving
                    ? null
                    : () async {
                        if (titleCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a task title')));
                          return;
                        }

                        final groups = <Map<String, dynamic>>[];
                        final assignedStudentIds = individualStudentIds.toList();

                        if (taskType == 'Individual' && assignedStudentIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select at least one student for this individual task')),
                          );
                          return;
                        }

                        if (taskType == 'Group') {
                          for (final draft in groupDrafts) {
                            final selected = draft['studentIds'] as Set<String>;
                            final name = ((draft['nameCtrl'] as TextEditingController).text.trim().isEmpty)
                                ? 'Group ${groups.length + 1}'
                                : (draft['nameCtrl'] as TextEditingController).text.trim();
                            final groupStudents = students.where((s) => selected.contains(s['id'].toString())).toList();
                            if (groupStudents.isNotEmpty) {
                              groups.add({
                                'name': name,
                                'students': groupStudents,
                              });
                            }
                          }
                          if (groups.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please create at least one group with students')),
                            );
                            return;
                          }
                        }

                        setDialogState(() => saving = true);
                        try {
                          await _api.createTask(
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            status: 'To Do',
                            priority: priority,
                            dueDate: dueDate,
                            estimatedHours: double.tryParse(hoursCtrl.text.trim()) ?? 2.0,
                            assignedToId: '',
                            unitId: _selectedUnitId!,
                            taskType: taskType,
                            assignedStudentIds: taskType == 'Individual' ? assignedStudentIds : const [],
                            groups: groups,
                          );

                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                          await _loadTasks(_selectedUnitId!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(taskType == 'Group' ? 'Group task created with groups' : 'Individual task created')),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => saving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating task: $e')));
                          }
                        }
                      },
                child: saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Task'),
              ),
            ],
          );
        },
      ),
    );

    disposeDrafts();
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _api.deleteTask(taskId);
      if (_selectedUnitId != null) await _loadTasks(_selectedUnitId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
      }
    }
  }

  InputDecoration _dialogInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnit = _selectedUnitId == null
        ? null
        : _units.firstWhere((unit) => unit['id'] == _selectedUnitId, orElse: () => null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Assigned Units'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [IconButton(onPressed: _loadUnits, icon: const Icon(Icons.refresh), tooltip: 'Refresh')],
      ),
      floatingActionButton: _selectedUnitId == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFF4A7BFF),
              onPressed: _showCreateTaskDialog,
              icon: const Icon(Icons.add_task),
              label: const Text('Create Task'),
            ),
      body: _loadingUnits
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUnits,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Units assigned to you', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Select a unit to create individual or group tasks for enrolled students.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (_units.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No units assigned yet. Ask the admin to assign you to a unit.', style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 205,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _units.length,
                        itemBuilder: (context, index) {
                          final unit = _units[index];
                          final isSelected = _selectedUnitId == unit['id'];
                          final count = _studentCounts[unit['id']] ?? 0;
                          return GestureDetector(
                            onTap: () => _selectUnit(unit),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF4A7BFF).withOpacity(0.18) : const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? const Color(0xFF4A7BFF) : const Color(0xFF2A2A2A), width: isSelected ? 2 : 1),
                              ),
                              child: Row(children: [
                                Icon(isSelected ? Icons.check_circle : Icons.school_outlined, color: isSelected ? const Color(0xFF4A7BFF) : Colors.white38),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(unit['code'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                    Text(unit['name'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('$count enrolled students • ${unit['semester'] ?? ''}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                  ]),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Unit Tasks', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(
                          selectedUnit == null ? 'Select a unit to view tasks' : '${selectedUnit['code']} — tap a task to view groups and chats',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: _selectedUnitId == null
                          ? const Center(child: Text('Select a unit above to view and create tasks.', style: TextStyle(color: Colors.white54)))
                          : _loadingTasks
                              ? const Center(child: CircularProgressIndicator())
                              : _tasks.isEmpty
                                  ? const Center(child: Text('No tasks yet. Use Create Task to add homework.', style: TextStyle(color: Colors.white54)))
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                                      itemCount: _tasks.length,
                                      itemBuilder: (context, index) => _taskCard(_tasks[index]),
                                    ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _taskCard(dynamic task) {
    final groups = (task['groups'] as List?) ?? [];
    final type = (task['taskType'] ?? 'Individual').toString();
    final assignedStudentIds = (task['assignedStudentIds'] as List?) ?? (task['assignedToIds'] as List?) ?? [];
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => LecturerTaskDetailPage(task: task)));
        if (_selectedUnitId != null) _loadTasks(_selectedUnitId!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: _priorityColor(task['priority']), width: 3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(task['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
            _chip(type == 'Group' ? 'Group task' : 'Individual', type == 'Group' ? Colors.purpleAccent : const Color(0xFF4A7BFF)),
            _chip(task['priority'] ?? 'Medium', _priorityColor(task['priority'])),
          ]),
          if ((task['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(task['description'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _chip('${_hoursText(task['estimatedHours'])}h', Colors.white38),
            if (task['dueDate'] != null) _chip(_formatDate(task['dueDate']), Colors.white38),
            _chip(task['status'] ?? 'To Do', Colors.green),
            if (type == 'Group') _chip('${groups.length} groups', Colors.purpleAccent),
          ]),
          if (type == 'Group' && groups.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Groups: ${groups.map((g) => g['name'] ?? 'Group').join(', ')}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
          if (type != 'Group' && assignedStudentIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Assigned students: ${assignedStudentIds.length}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Delete task',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              onPressed: () => _deleteTask(task['id']),
            ),
          ),
        ]),
      ),
    );
  }

  String _hoursText(dynamic value) {
    final hours = value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0.0;
    return hours.toStringAsFixed(1);
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

  Widget _chip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10)),
    );
  }
}
