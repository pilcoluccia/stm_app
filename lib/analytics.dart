import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/api_service.dart';
import 'study.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _api = ApiService();

  List<dynamic> _tasks = [];
  int _totalStudySeconds = 0;
  bool _loading = true;

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

      final studyTime = await _api.getTotalStudyTime(uid);

      setState(() {
        _tasks = allTasks;
        _totalStudySeconds = (studyTime['totalSeconds'] ?? 0).toInt();
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

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final done = _tasks.where((t) => t['status'] == 'Done').length;
    final pending = total - done;
    final highPriority = _tasks
        .where((t) => t['priority'] == 'High' && t['status'] != 'Done')
        .length;
    final studyHours = _totalStudySeconds / 3600;
    final completionRate = total == 0 ? 0.0 : (done / total * 100);

    // Priority breakdown for bar chart
    final highCount = _tasks.where((t) => t['priority'] == 'High').length;
    final medCount = _tasks.where((t) => t['priority'] == 'Medium').length;
    final lowCount = _tasks.where((t) => t['priority'] == 'Low').length;

    if (_loading) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────
                const Text('Analytics',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Your academic performance overview',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 20),

                // ── Summary cards ────────────────────────
                Row(
                  children: [
                    _statCard('Tasks Done', '$done/$total',
                        const Color(0xFF4A7BFF), Icons.task_alt),
                    const SizedBox(width: 10),
                    _statCard(
                        'Study Time',
                        '${studyHours.toStringAsFixed(1)}h',
                        Colors.green,
                        Icons.timer,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const StudyPage()))),
                    const SizedBox(width: 10),
                    _statCard(
                        'Urgent', '$highPriority', Colors.red, Icons.priority_high),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statCard('Completion', '${completionRate.toStringAsFixed(0)}%',
                        Colors.orange, Icons.pie_chart),
                    const SizedBox(width: 10),
                    _statCard('Pending', '$pending', const Color(0xFFFFAA00),
                        Icons.pending_actions),
                    const SizedBox(width: 10),
                    _statCard(
                        'Focus Time',
                        '${(_totalStudySeconds / 60).toStringAsFixed(0)}m',
                        const Color(0xFFDE90FE),
                        Icons.self_improvement),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Task Status Pie Chart ─────────────────
                const Text('Task Status',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: total == 0
                      ? const Center(
                          child: Text('No tasks yet',
                              style: TextStyle(color: Colors.white38)))
                      : Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: done.toDouble(),
                                      title: done > 0
                                          ? '${(done / total * 100).toStringAsFixed(0)}%'
                                          : '',
                                      color: Colors.green,
                                      radius: 70,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    PieChartSectionData(
                                      value: pending.toDouble(),
                                      title: pending > 0
                                          ? '${(pending / total * 100).toStringAsFixed(0)}%'
                                          : '',
                                      color: const Color(0xFF4A7BFF),
                                      radius: 70,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _legend(Colors.green, 'Completed', done),
                                  const SizedBox(height: 12),
                                  _legend(const Color(0xFF4A7BFF), 'Pending',
                                      pending),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Total: $total tasks',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),

                // ── Priority Bar Chart ────────────────────
                const Text('Tasks by Priority',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: total == 0
                      ? const Center(
                          child: Text('No tasks yet',
                              style: TextStyle(color: Colors.white38)))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (([highCount, medCount, lowCount]..sort()).last +
                                    2)
                                .toDouble(),
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (val, _) => Text(
                                    val.toInt().toString(),
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 11),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    const labels = ['High', 'Medium', 'Low'];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        labels[val.toInt()],
                                        style: const TextStyle(
                                            color: Colors.white54, fontSize: 11),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (_) => const FlLine(
                                  color: Colors.white10, strokeWidth: 1),
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _bar(0, highCount.toDouble(),
                                  const Color(0xFFFF4444)),
                              _bar(1, medCount.toDouble(),
                                  const Color(0xFFFFAA00)),
                              _bar(
                                  2, lowCount.toDouble(), const Color(0xFF4A7BFF)),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // ── Study time card ───────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StudyPage())),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C3FD0), Color(0xFF4A7BFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.self_improvement,
                            color: Colors.white, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Study With Me',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ${studyHours.toStringAsFixed(1)} hours studied',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _statCard(String label, String value, Color color, IconData icon,
      {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(14),
            border: onTap != null
                ? Border.all(color: color.withValues(alpha: 0.3))
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$label ($count)',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
