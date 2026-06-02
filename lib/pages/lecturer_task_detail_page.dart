import 'package:flutter/material.dart';

class LecturerTaskDetailPage extends StatelessWidget {
  final Map<String, dynamic> task;

  const LecturerTaskDetailPage({super.key, required this.task});

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final parsed = date is DateTime ? date : DateTime.parse(date.toString());
      return '${parsed.day}/${parsed.month}/${parsed.year}';
    } catch (_) {
      return date.toString();
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = task['title']?.toString() ?? 'Task detail';
    final description = task['description']?.toString() ?? 'No description provided';
    final priority = task['priority']?.toString() ?? 'Medium';
    final status = task['status']?.toString() ?? 'To Do';
    final estimated = task['estimatedHours']?.toString() ?? '0';
    final dueDate = _formatDate(task['dueDate']);
    final assignedTo = task['assignedTo'] ?? task['assignedToIds'] ?? task['assignedStudentIds'] ?? [];

    String assignedText;
    if (assignedTo is List && assignedTo.isNotEmpty) {
      assignedText = assignedTo.map((item) => item.toString()).join(', ');
    } else {
      assignedText = 'All students';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF111111),
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Status', status),
            _detailRow('Priority', priority),
            _detailRow('Estimated Hours', estimated),
            _detailRow('Due Date', dueDate),
            _detailRow('Assigned To', assignedText),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
