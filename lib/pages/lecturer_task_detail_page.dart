import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'task_group_chat_page.dart';

class LecturerTaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const LecturerTaskDetailPage({super.key, required this.task});

  @override
  State<LecturerTaskDetailPage> createState() => _LecturerTaskDetailPageState();
}

class _LecturerTaskDetailPageState extends State<LecturerTaskDetailPage> {
  final _api = ApiService();
  late Map<String, dynamic> _task;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _task = Map<String, dynamic>.from(widget.task);
    _reloadTask();
  }

  Future<void> _reloadTask() async {
    final id = _task['id']?.toString() ?? '';
    if (id.isEmpty) return;
    setState(() => _loading = true);
    try {
      final latest = await _api.getTask(id);
      if (!mounted) return;
      setState(() {
        _task = Map<String, dynamic>.from(latest);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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

  Future<void> _addGroup() async {
    final unitId = _task['unitId']?.toString() ?? '';
    List<dynamic> enrollments = [];
    if (unitId.isNotEmpty) {
      enrollments = await _api.listEnrolledStudents(unitId);
      enrollments = enrollments.where((e) => e['status'] == 'active').toList();
    }
    final students = enrollments.map(_studentFromEnrollment).where((s) => (s['id'] ?? '').toString().isNotEmpty).toList();
    final nameCtrl = TextEditingController(text: 'Group ${((_task['groups'] as List?) ?? []).length + 1}');
    final selected = <String>{};
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Create Group', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Group Name', labelStyle: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 14),
                  const Text('Assign enrolled students:', style: TextStyle(color: Colors.white70)),
                  if (students.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('No enrolled students found for this unit.', style: TextStyle(color: Colors.orangeAccent)),
                    ),
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
                      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
            ),
          ),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (selected.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one student')));
                        return;
                      }
                      setDialogState(() => saving = true);
                      final groupStudents = students.where((s) => selected.contains(s['id'].toString())).toList();
                      final result = await _api.createTaskGroup(
                        taskId: _task['id'].toString(),
                        name: nameCtrl.text.trim().isEmpty ? 'Group' : nameCtrl.text.trim(),
                        students: groupStudents,
                      );
                      if (!mounted) return;
                      setState(() => _task = Map<String, dynamic>.from(result['task']));
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
              child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add Group'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = (_task['groups'] as List?) ?? [];
    final taskType = (_task['taskType'] ?? 'Individual').toString();
    final assignedStudentIds = (_task['assignedStudentIds'] as List?) ?? (_task['assignedToIds'] as List?) ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_task['title']?.toString() ?? 'Task'),
        backgroundColor: Colors.black,
        actions: [IconButton(onPressed: _reloadTask, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: taskType == 'Group'
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF4A7BFF),
              onPressed: _addGroup,
              icon: const Icon(Icons.group_add),
              label: const Text('Add Group'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_task['description']?.toString() ?? '', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _chip(taskType == 'Group' ? 'Group task' : 'Individual task', taskType == 'Group' ? Colors.purpleAccent : const Color(0xFF4A7BFF)),
                      _chip(_task['status']?.toString() ?? 'To Do', Colors.green),
                      _chip('${_task['estimatedHours'] ?? 0}h', Colors.white54),
                    ]),
                  ]),
                ),
                const SizedBox(height: 20),
                Text(
                  taskType == 'Group' ? 'Student Groups' : 'Individual Task',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (taskType != 'Group')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('This task is assigned only to the selected students below.', style: TextStyle(color: Colors.white54)),
                        const SizedBox(height: 10),
                        if (assignedStudentIds.isEmpty)
                          const Text('No specific students selected.', style: TextStyle(color: Colors.orangeAccent))
                        else
                          ...assignedStudentIds.map((id) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, color: Color(0xFF4A7BFF), size: 16),
                                    const SizedBox(width: 8),
                                    Text(id.toString(), style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: groups.isEmpty
                        ? const Center(child: Text('No groups created yet. Use Add Group.', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: groups.length,
                            itemBuilder: (_, i) {
                              final g = Map<String, dynamic>.from(groups[i]);
                              final students = (g['students'] as List?) ?? [];
                              final names = students.map((e) => (e['name'] ?? e['email'] ?? e['id']).toString()).join(', ');
                              return Card(
                                color: const Color(0xFF1A1A1A),
                                child: ListTile(
                                  leading: const Icon(Icons.groups, color: Color(0xFF4A7BFF)),
                                  title: Text(g['name']?.toString() ?? 'Group', style: const TextStyle(color: Colors.white)),
                                  subtitle: Text(names.isEmpty ? 'No students assigned' : names, style: const TextStyle(color: Colors.white54)),
                                  trailing: TextButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => TaskGroupChatPage(group: g, task: _task, lecturerView: true)),
                                    ),
                                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                    label: const Text('Chat'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ]),
            ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
