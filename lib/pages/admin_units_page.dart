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
      setState(() {
        _units = units;
        _lecturers = lecturers;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _showCreateUnitDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final creditsCtrl = TextEditingController();
    final semesterCtrl = TextEditingController();
    final maxStudentsCtrl = TextEditingController();
    String? selectedLecturerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Create New Unit',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(codeCtrl, 'Unit Code (e.g., ICT101)'),
                  const SizedBox(height: 12),
                  _buildField(nameCtrl, 'Unit Name'),
                  const SizedBox(height: 12),
                  _buildField(descCtrl, 'Description', maxLines: 3),
                  const SizedBox(height: 12),
                  _buildField(creditsCtrl, 'Credits',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildField(semesterCtrl, 'Semester (e.g., 2026-S1)'),
                  const SizedBox(height: 12),
                  _buildField(maxStudentsCtrl, 'Max Students',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  // Lecturer dropdown
                  DropdownButtonFormField<String>(
                    value: selectedLecturerId,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Lecturer',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4A7BFF)),
                      ),
                    ),
                    items: _lecturers.isEmpty
                        ? [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No lecturers available'),
                            )
                          ]
                        : _lecturers.map<DropdownMenuItem<String>>((lecturer) {
                            return DropdownMenuItem<String>(
                              value: lecturer['uid'],
                              child: Text(
                                '${lecturer['name']} (${lecturer['email']})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                    onChanged: _lecturers.isEmpty
                        ? null
                        : (value) {
                            setDialogState(() => selectedLecturerId = value);
                          },
                  ),
                  const SizedBox(height: 8),
                  if (_lecturers.isEmpty)
                    const Text(
                      'Create a user with role "lecturer" first',
                      style: TextStyle(color: Colors.orange, fontSize: 11),
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
              onPressed: () => _createUnit(
                context,
                codeCtrl.text,
                nameCtrl.text,
                descCtrl.text,
                creditsCtrl.text,
                semesterCtrl.text,
                maxStudentsCtrl.text,
                selectedLecturerId ?? '',
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUnit(
    BuildContext dialogContext,
    String code,
    String name,
    String description,
    String creditsStr,
    String semester,
    String maxStudentsStr,
    String lecturerId,
  ) async {
    if (code.isEmpty ||
        name.isEmpty ||
        creditsStr.isEmpty ||
        semester.isEmpty ||
        maxStudentsStr.isEmpty ||
        lecturerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final credits = int.parse(creditsStr);
      final maxStudents = int.parse(maxStudentsStr);

      await _api.createUnit(
        code: code,
        name: name,
        description: description.isEmpty ? null : description,
        lecturerId: lecturerId,
        credits: credits,
        semester: semester,
        maxStudents: maxStudents,
      );

      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit created successfully!')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating unit: $e')),
        );
      }
    }
  }

  Widget _buildField(TextEditingController ctrl, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4A7BFF)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manage Units'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A7BFF),
        onPressed: _showCreateUnitDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _units.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.white30),
                      SizedBox(height: 16),
                      Text('No units yet',
                          style: TextStyle(color: Colors.white70, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Tap + to create your first unit',
                          style: TextStyle(color: Colors.white38, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _units.length,
                  itemBuilder: (context, index) {
                    final unit = _units[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A7BFF)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(unit['code'],
                                    style: const TextStyle(
                                        color: Color(0xFF4A7BFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              Text('${unit['credits']} credits',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(unit['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          if (unit['description'] != null) ...[
                            const SizedBox(height: 6),
                            Text(unit['description'],
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: Colors.white38),
                              const SizedBox(width: 4),
                              Text(unit['semester'],
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                              const SizedBox(width: 16),
                              const Icon(Icons.people,
                                  size: 14, color: Colors.white38),
                              const SizedBox(width: 4),
                              Text('Max: ${unit['maxStudents']}',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
