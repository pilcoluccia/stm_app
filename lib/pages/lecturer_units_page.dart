import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LecturerUnitsPage extends StatefulWidget {
  const LecturerUnitsPage({super.key});

  @override
  State<LecturerUnitsPage> createState() => _LecturerUnitsPageState();
}

class _LecturerUnitsPageState extends State<LecturerUnitsPage> {
  final _api = ApiService();
  List<dynamic> _units = [];
  Map<String, int> _studentCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() => _loading = true);
    try {
      final lecturerId = AuthService.instance.currentAppUser!.dbId;
      final units = await _api.listAllUnits(lecturerId: lecturerId);
      final counts = <String, int>{};

      for (final unit in units) {
        final enrollments = await _api.listEnrolledStudents(unit['id']);
        counts[unit['id']] = enrollments.where((e) => e['status'] == 'active').length;
      }

      setState(() {
        _units = units;
        _studentCounts = counts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading units: $e')),
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
    final maxCtrl = TextEditingController(text: '30');
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
              width: 420,
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
                    maxCtrl,
                    'Maximum Students',
                    keyboardType: TextInputType.number,
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
                      if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter unit code and name')),
                        );
                        return;
                      }

                      setDialogState(() => saving = true);
                      try {
                        final lecturerId = AuthService.instance.currentAppUser!.dbId;
                        await _api.createUnit(
                          code: codeCtrl.text.trim().toUpperCase(),
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          credits: int.tryParse(creditsCtrl.text.trim()) ?? 10,
                          semester: semesterCtrl.text.trim(),
                          maxStudents: int.tryParse(maxCtrl.text.trim()) ?? 30,
                          lecturerId: lecturerId,
                        );

                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        await _loadUnits();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unit created successfully')),
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
                  : const Text('Create Unit'),
            ),
          ],
        ),
      ),
    );
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Units'),
        backgroundColor: Colors.black,
        elevation: 0,
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
              onRefresh: _loadUnits,
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
                                    width: 42,
                                    height: 42,
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          unit['name'] ?? '',
                                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        ),
                                      ],
                                    ),
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
