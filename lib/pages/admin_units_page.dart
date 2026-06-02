import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUnitsPage extends StatefulWidget {
  const AdminUnitsPage({super.key});

  @override
  State<AdminUnitsPage> createState() => _AdminUnitsPageState();
}

class _AdminUnitsPageState extends State<AdminUnitsPage> {
  final _api = ApiService();

  List<dynamic> _units = [];
  List<dynamic> _lecturers = [];
  List<dynamic> _students = [];
  Map<String, int> _studentCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final units = await _api.listAllUnits();
      final lecturers = await _api.listAllUsers(role: 'lecturer');
      final students = await _api.listAllUsers(role: 'student');
      final counts = <String, int>{};

      for (final unit in units) {
        final unitId = unit['id']?.toString() ?? '';
        if (unitId.isEmpty) continue;
        final enrolled = await _api.listEnrolledStudents(unitId);
        counts[unitId] = enrolled.where((e) => e['status'] == 'active').length;
      }

      setState(() {
        _units = units;
        _lecturers = lecturers;
        _students = students;
        _studentCounts = counts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading admin unit data: $e')),
        );
      }
    }
  }

  void _showCreateUnitDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final creditsCtrl = TextEditingController(text: '10');
    final semesterCtrl = TextEditingController(text: '2026-S1');
    final maxStudentsCtrl = TextEditingController(text: '30');
    String? selectedLecturerId;
    bool saving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Create Unit',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 430,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(codeCtrl, 'Unit Code', hint: 'ICT201'),
                  const SizedBox(height: 12),
                  _field(nameCtrl, 'Unit Name', hint: 'Database Systems'),
                  const SizedBox(height: 12),
                  _field(descCtrl, 'Description', maxLines: 3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          creditsCtrl,
                          'Credits',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _field(semesterCtrl, 'Semester')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(
                    maxStudentsCtrl,
                    'Maximum Students',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedLecturerId,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Assign Lecturer'),
                    items: _lecturers.map<DropdownMenuItem<String>>((lecturer) {
                      return DropdownMenuItem<String>(
                        value: (lecturer['id'] ?? lecturer['email'] ?? lecturer['uid']).toString(),
                        child: Text(
                          '${lecturer['name'] ?? 'Lecturer'} (${lecturer['email'] ?? ''})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _lecturers.isEmpty
                        ? null
                        : (value) => setDialogState(() => selectedLecturerId = value),
                  ),
                  if (_lecturers.isEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'No lecturers found. Ask the lecturer to log in once, then refresh this page.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
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
                      if (codeCtrl.text.trim().isEmpty ||
                          nameCtrl.text.trim().isEmpty ||
                          selectedLecturerId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter unit details and assign a lecturer')),
                        );
                        return;
                      }

                      setDialogState(() => saving = true);
                      try {
                        await _api.createUnit(
                          code: codeCtrl.text.trim().toUpperCase(),
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          credits: int.tryParse(creditsCtrl.text.trim()) ?? 10,
                          semester: semesterCtrl.text.trim(),
                          maxStudents: int.tryParse(maxStudentsCtrl.text.trim()) ?? 30,
                          lecturerId: selectedLecturerId!,
                        );

                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        await _loadData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unit created and lecturer assigned')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error creating unit: $e')),
                          );
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManageStudentsDialog(dynamic unit) async {
    final unitId = unit['id']?.toString() ?? '';
    if (unitId.isEmpty) return;

    List<dynamic> enrolled = [];
    String? selectedStudentId;
    bool loading = true;
    bool saving = false;

    Future<void> reload(StateSetter setDialogState) async {
      final data = await _api.listEnrolledStudents(unitId);
      setDialogState(() {
        enrolled = data;
        loading = false;
        saving = false;
        selectedStudentId = null;
      });
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          if (loading) {
            reload(setDialogState);
          }

          final activeStudentIds = enrolled
              .where((e) => e['status'] == 'active')
              .map((e) => (e['studentId'] ?? '').toString())
              .toSet();
          final availableStudents = _students.where((student) {
            final id = (student['uid'] ?? student['id']).toString();
            return !activeStudentIds.contains(id);
          }).toList();

          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Assign Students — ${unit['code'] ?? ''}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            content: SizedBox(
              width: 520,
              child: loading
                  ? const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit['name'] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedStudentId,
                                  dropdownColor: const Color(0xFF2A2A2A),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('Select student to enroll'),
                                  items: availableStudents.map<DropdownMenuItem<String>>((student) {
                                    return DropdownMenuItem<String>(
                                      value: (student['uid'] ?? student['id']).toString(),
                                      child: Text(
                                        '${student['name'] ?? 'Student'} (${student['email'] ?? ''})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: availableStudents.isEmpty
                                      ? null
                                      : (value) => setDialogState(() => selectedStudentId = value),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A7BFF)),
                                onPressed: saving || selectedStudentId == null
                                    ? null
                                    : () async {
                                        setDialogState(() => saving = true);
                                        try {
                                          await _api.enrollStudent(
                                            studentId: selectedStudentId!,
                                            unitId: unitId,
                                          );
                                          await reload(setDialogState);
                                          await _loadData();
                                        } catch (e) {
                                          setDialogState(() => saving = false);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error enrolling student: $e')),
                                            );
                                          }
                                        }
                                      },
                                icon: saving
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.person_add, size: 18),
                                label: const Text('Enroll'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Currently Enrolled Students',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (enrolled.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text('No students enrolled yet', style: TextStyle(color: Colors.white54)),
                              ),
                            )
                          else
                            ...enrolled.map((enrollment) {
                              final student = enrollment['student'];
                              final studentId = (enrollment['studentId'] ?? '').toString();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111111),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF2A2A2A)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.school, color: Color(0xFF4A7BFF), size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student?['name'] ?? studentId,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            student?['email'] ?? '',
                                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        try {
                                          await _api.dropEnrollment(
                                            studentId: studentId,
                                            unitId: unitId,
                                          );
                                          await reload(setDialogState);
                                          await _loadData();
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error removing student: $e')),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                                      label: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close', style: TextStyle(color: Colors.white70)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteUnit(dynamic unit) async {
    final unitId = unit['id']?.toString() ?? '';
    if (unitId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Unit?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will permanently delete ${unit['code'] ?? 'this unit'}, its enrolments, tasks, groups, and related group chat messages.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _api.deleteUnit(unitId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${unit['code'] ?? 'Unit'} deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting unit: $e')),
        );
      }
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Units & Enrollment'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4A7BFF),
        onPressed: _showCreateUnitDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create Unit'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _units.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Icon(Icons.school_outlined, size: 64, color: Colors.white30),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No units yet. Tap Create Unit to add your first unit.',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: _units.length,
                      itemBuilder: (context, index) {
                        final unit = _units[index];
                        final count = _studentCounts[unit['id']] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF4A7BFF).withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A7BFF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.school_outlined, color: Color(0xFF4A7BFF)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          unit['code'] ?? '',
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          unit['name'] ?? '',
                                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4A7BFF),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => _showManageStudentsDialog(unit),
                                        icon: const Icon(Icons.group_add, size: 18),
                                        label: const Text('Students'),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        tooltip: 'Delete Unit',
                                        onPressed: () => _confirmDeleteUnit(unit),
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if ((unit['description'] ?? '').toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  unit['description'],
                                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _chip('${unit['credits'] ?? 0} credits', Colors.white38),
                                  _chip('Semester ${unit['semester'] ?? ''}', Colors.white38),
                                  _chip('Lecturer: ${unit['lecturerName'] ?? 'Assigned'}', const Color(0xFF4CAF50)),
                                  _chip('$count students', const Color(0xFF4CAF50)),
                                  _chip('Max ${unit['maxStudents'] ?? 0}', const Color(0xFFFFAA00)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
