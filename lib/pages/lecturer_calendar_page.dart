import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LecturerCalendarPage extends StatefulWidget {
  const LecturerCalendarPage({super.key});

  @override
  State<LecturerCalendarPage> createState() => _LecturerCalendarPageState();
}

class _LecturerCalendarPageState extends State<LecturerCalendarPage> {
  final _api = ApiService();

  bool _loading = true;
  List<dynamic> _tasks = [];
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    setState(() => _loading = true);

    try {
      final lecturerId = AuthService.instance.currentAppUser!.dbId;
      final units = await _api.listAllUnits(lecturerId: lecturerId);

      final loadedTasks = <dynamic>[];
      final seenTaskIds = <String>{};

      for (final unit in units) {
        final unitId = unit['id']?.toString();
        if (unitId == null || unitId.isEmpty) continue;

        final unitTasks = await _api.listTasksByUnit(unitId);

        for (final task in unitTasks) {
          final taskId = task['id']?.toString() ?? '';
          if (taskId.isNotEmpty && seenTaskIds.contains(taskId)) continue;

          loadedTasks.add({
            ...task,
            'unitCode': unit['code'] ?? '',
            'unitName': unit['name'] ?? '',
          });

          if (taskId.isNotEmpty) {
            seenTaskIds.add(taskId);
          }
        }
      }

      loadedTasks.sort((a, b) {
        final aDate = _parseDate(a['dueDate']);
        final bDate = _parseDate(b['dueDate']);
        return aDate.compareTo(bDate);
      });

      setState(() {
        _tasks = loadedTasks;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lecturer calendar: $e')),
        );
      }
    }
  }

  DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime(9999);
    }
    return DateTime(9999);
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<dynamic> _tasksForDay(DateTime day) {
    return _tasks.where((task) {
      final due = _parseDate(task['dueDate']);
      return _sameDay(due, day);
    }).toList();
  }

  List<dynamic> _upcomingTasks() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 14));

    return _tasks.where((task) {
      final due = _parseDate(task['dueDate']);
      return due.isAfter(start.subtract(const Duration(days: 1))) &&
          due.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<dynamic> _overdueTasks() {
    final today = DateTime.now();
    final startToday = DateTime(today.year, today.month, today.day);

    return _tasks.where((task) {
      final due = _parseDate(task['dueDate']);
      final status = task['status']?.toString() ?? 'To Do';
      return due.isBefore(startToday) && status != 'Done';
    }).toList();
  }

  String _monthName(int month) {
    const names = [
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
      'December',
    ];
    return names[month - 1];
  }

  String _formatDate(DateTime date) {
    if (date.year == 9999) return 'No due date';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _priorityColor(dynamic priority) {
    final value = priority?.toString().toLowerCase() ?? '';

    if (value == 'high') return Colors.redAccent;
    if (value == 'low') return const Color(0xFF4A7BFF);

    return const Color(0xFFFFAA00);
  }

  Color _statusColor(dynamic status) {
    final value = status?.toString().toLowerCase() ?? '';

    if (value == 'done') return Colors.green;
    if (value == 'in progress') return Colors.orange;

    return Colors.white54;
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _tasksForDay(_selectedDate);
    final upcomingTasks = _upcomingTasks();
    final overdueTasks = _overdueTasks();
    final todayTasks = _tasksForDay(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Lecturer Calendar'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadCalendarData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCalendarData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(
                      todayTasks.length,
                      upcomingTasks.length,
                      overdueTasks.length,
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 900;

                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildCalendarCard(),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 2,
                                child: _buildSelectedDayPanel(selectedTasks),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _buildCalendarCard(),
                            const SizedBox(height: 18),
                            _buildSelectedDayPanel(selectedTasks),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    _buildUpcomingSection(upcomingTasks),
                    const SizedBox(height: 22),
                    _buildOverdueSection(overdueTasks),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards(int todayCount, int upcomingCount, int overdueCount) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.today,
            label: 'Due Today',
            value: todayCount.toString(),
            color: const Color(0xFF4A7BFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.event_note,
            label: 'Next 14 Days',
            value: upcomingCount.toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.warning_amber_rounded,
            label: 'Overdue',
            value: overdueCount.toString(),
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekDays(),
          const SizedBox(height: 8),
          _buildMonthGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final cells = <Widget>[];

    for (int i = 0; i < rows * 7; i++) {
      final dayNumber = i - startOffset + 1;

      if (dayNumber < 1 || dayNumber > daysInMonth) {
        cells.add(const SizedBox(height: 72));
      } else {
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        cells.add(_buildDateCell(date));
      }
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: cells,
    );
  }

  Widget _buildDateCell(DateTime date) {
    final dayTasks = _tasksForDay(date);
    final isToday = _sameDay(date, DateTime.now());
    final isSelected = _sameDay(date, _selectedDate);
    final hasHighPriority = dayTasks.any(
      (task) => task['priority']?.toString().toLowerCase() == 'high',
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A7BFF)
              : isToday
                  ? const Color(0xFF16264F)
                  : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A7BFF)
                : isToday
                    ? const Color(0xFF4A7BFF)
                    : const Color(0xFF2A2A2A),
          ),
        ),
        child: Column(
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (dayTasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hasHighPriority ? Colors.redAccent : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dayTasks.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayPanel(List<dynamic> selectedTasks) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasks & Deadlines',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(_selectedDate),
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 18),
          if (selectedTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available, color: Colors.white30, size: 44),
                    SizedBox(height: 12),
                    Text(
                      'No tasks or deadlines on this day.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            )
          else
            ...selectedTasks.map((task) => _taskCard(task)),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(List<dynamic> upcomingTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Lecturer Deadlines',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (upcomingTasks.isEmpty)
          _emptyWideCard(
            icon: Icons.event_note,
            text: 'No upcoming deadlines in the next 14 days.',
          )
        else
          ...upcomingTasks.take(8).map((task) => _taskCard(task)),
      ],
    );
  }

  Widget _buildOverdueSection(List<dynamic> overdueTasks) {
    if (overdueTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overdue Items',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...overdueTasks.map((task) => _taskCard(task)),
      ],
    );
  }

  Widget _emptyWideCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white30, size: 42),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(dynamic task) {
    final due = _parseDate(task['dueDate']);
    final priority = task['priority']?.toString() ?? 'Medium';
    final status = task['status']?.toString() ?? 'To Do';
    final title = task['title']?.toString() ?? 'Untitled Task';
    final description = task['description']?.toString() ?? '';
    final unitCode = task['unitCode']?.toString() ?? '';
    final unitName = task['unitName']?.toString() ?? '';
    final hours = task['estimatedHours']?.toString() ?? '0';

    final priorityColor = _priorityColor(priority);
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: priorityColor, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _chip(
                text: priority,
                color: priorityColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                icon: Icons.school,
                text: unitCode.isNotEmpty ? unitCode : unitName,
              ),
              _infoChip(
                icon: Icons.calendar_today,
                text: _formatDate(due),
              ),
              _infoChip(
                icon: Icons.access_time,
                text: '$hours hrs',
              ),
              _chip(
                text: status,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 15),
          const SizedBox(width: 5),
          Text(
            text.isEmpty ? 'N/A' : text,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
