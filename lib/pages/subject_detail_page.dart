import 'package:flutter/material.dart';
import '../models/unit_model.dart';
import '../services/api_service.dart';
import '../services/groups_service.dart';
import 'group_page.dart';
import 'task_board_page.dart';

class SubjectDetailPage extends StatefulWidget {
  final UnitModel unit;
  const SubjectDetailPage({super.key, required this.unit});

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  final _api = ApiService();
  List<dynamic> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final tasks = await _api.listTasksByUnit(widget.unit.id);
      tasks.sort((a, b) {
        final dateA = DateTime.tryParse((a['dueDate'] ?? '').toString());
        final dateB = DateTime.tryParse((b['dueDate'] ?? '').toString());
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading unit tasks: $e')),
        );
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
    final doneH = _tasks
        .where((t) => t['status'] == 'Done')
        .fold<double>(0, (s, t) => s + _num(t['estimatedHours']));
    final pct = totalH > 0 ? (doneH / totalH).clamp(0.0, 1.0) : 0.0;
    final group = GroupsService.instance.forUnit(widget.unit.id);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.unit.code),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4A7BFF).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.unit.name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        widget.unit.lecturerName,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ]),
                    if (widget.unit.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(widget.unit.description, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Progress', icon: Icons.trending_up),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ProgressStat(label: 'Total Hours', value: '${totalH.toStringAsFixed(1)}h', color: Colors.white70),
                        _ProgressStat(label: 'Completed', value: '${doneH.toStringAsFixed(1)}h', color: const Color(0xFF4CAF50)),
                        _ProgressStat(label: 'Progress', value: '${(pct * 100).toInt()}%', color: const Color(0xFF4A7BFF)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF4A7BFF)),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionHeader(title: 'Tasks (${_tasks.length})', icon: Icons.task_outlined),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TaskBoardPage(unit: widget.unit)),
                      );
                      _loadTasks();
                    },
                    child: const Text('Board view', style: TextStyle(color: Color(0xFF4A7BFF), fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_tasks.isEmpty)
                const _EmptyHint(text: 'No tasks assigned yet.')
              else
                ..._tasks.take(4).map((t) => _TaskRow(task: t)),
              if (_tasks.length > 4)
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaskBoardPage(unit: widget.unit)),
                    );
                    _loadTasks();
                  },
                  child: Text('See all ${_tasks.length} tasks →', style: const TextStyle(color: Color(0xFF4A7BFF), fontSize: 12)),
                ),
              const SizedBox(height: 20),
              _SectionHeader(title: 'My Group', icon: Icons.group_outlined),
              const SizedBox(height: 8),
              if (group == null)
                const _EmptyHint(text: 'No group assigned yet.')
              else
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupPage(group: group))),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.group, color: Color(0xFF4A7BFF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(group.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            Text('${group.members.length} members', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white38),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF4A7BFF)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      ]);
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ProgressStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]);
}

class _TaskRow extends StatelessWidget {
  final dynamic task;
  const _TaskRow({required this.task});

  DateTime? _date(dynamic value) => DateTime.tryParse(value?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    final due = _date(task['dueDate']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(
          task['status'] == 'Done' ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task['status'] == 'Done' ? const Color(0xFF4CAF50) : Colors.white38,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task['title']?.toString() ?? 'Untitled task', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            if (due != null)
              Text('Due ${due.day}/${due.month}/${due.year}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ]),
        ),
        Text(task['priority']?.toString() ?? 'Medium', style: const TextStyle(color: Color(0xFF4A7BFF), fontSize: 12)),
      ]),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      );
}
