import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/unit_model.dart';
import 'subject_detail_page.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});
  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _api = ApiService();

  List<dynamic> _allUnits = [];
  List<dynamic> _enrolledUnits = [];
  Set<String> _enrolledUnitIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final units = await _api.listAllUnits();
      final enrollments = await _api.listStudentEnrollments(uid);

      setState(() {
        _allUnits = units;
        _enrolledUnits = enrollments
            .map((e) => e['unit'])
            .where((u) => u != null)
            .toList();
        _enrolledUnitIds = enrollments.map((e) => e['unitId'] as String).toSet();
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

  UnitModel _unitFromMap(Map<String, dynamic> unit) {
    return UnitModel(
      id: unit['id']?.toString() ?? '',
      code: unit['code']?.toString() ?? '',
      name: unit['name']?.toString() ?? '',
      description: unit['description']?.toString() ?? '',
      lecturerName: unit['lecturerName']?.toString() ??
          unit['lecturer']?['name']?.toString() ??
          '',
    );
  }

  void _openUnitDetails(Map<String, dynamic> unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectDetailPage(unit: _unitFromMap(unit)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Units'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh units',
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF4A7BFF),
          labelColor: const Color(0xFF4A7BFF),
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'All Units'),
            Tab(text: 'My Units'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _AllUnitsTab(
                  units: _allUnits,
                  enrolledUnitIds: _enrolledUnitIds,
                  onView: _openUnitDetails,
                ),
                _MyUnitsTab(
                  units: _enrolledUnits,
                  onView: _openUnitDetails,
                ),
              ],
            ),
    );
  }
}

// ── All Units tab ─────────────────────────────────────────────────────────────

class _AllUnitsTab extends StatelessWidget {
  final List<dynamic> units;
  final Set<String> enrolledUnitIds;
  final Function(Map<String, dynamic>) onView;

  const _AllUnitsTab({
    required this.units,
    required this.enrolledUnitIds,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.white30),
            SizedBox(height: 16),
            Text('No units available yet',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: units.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'All available units are shown here. Enrolment is managed by Admin, so students can view units but cannot enrol or drop themselves.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          );
        }
        final unit = units[i - 1];
        final enrolled = enrolledUnitIds.contains(unit['id']);
        return _UnitCard(
          unit: unit,
          enrolled: enrolled,
          onView: onView,
        );
      },
    );
  }
}

class _UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  final bool enrolled;
  final Function(Map<String, dynamic>) onView;

  const _UnitCard({
    required this.unit,
    required this.enrolled,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onView(unit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: enrolled
              ? Border.all(color: const Color(0xFF4A7BFF), width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7BFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_outlined,
                    color: Color(0xFF4A7BFF), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(unit['code'] ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      if (enrolled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF4A7BFF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Enrolled by Admin',
                              style: TextStyle(
                                  color: Color(0xFF4A7BFF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ]),
                    const SizedBox(height: 2),
                    Text(unit['name'] ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                        '${unit['credits'] ?? 0} credits • Semester ${unit['semester'] ?? ''}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

// ── My Units tab ──────────────────────────────────────────────────────────────

class _MyUnitsTab extends StatelessWidget {
  final List<dynamic> units;
  final Function(Map<String, dynamic>) onView;

  const _MyUnitsTab({
    required this.units,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 56, color: Colors.white24),
            SizedBox(height: 16),
            Text('No units have been assigned to you yet.',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Please contact an Admin to be enrolled into a unit.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: units.length,
      itemBuilder: (context, i) => _MyUnitCard(unit: units[i], onView: onView),
    );
  }
}

class _MyUnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  final Function(Map<String, dynamic>) onView;
  const _MyUnitCard({required this.unit, required this.onView});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onView(unit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF4A7BFF).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit['code'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(unit['name'] ?? '',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13)),
                    Text(
                        '${unit['credits'] ?? 0} credits • Semester ${unit['semester'] ?? ''}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ]),
          ],
        ),
      ),
    );
  }
}
