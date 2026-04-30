import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

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

      // Load all units
      final units = await _api.listAllUnits();

      // Load student's enrollments
      final enrollments = await _api.listStudentEnrollments(uid);

      setState(() {
        _allUnits = units;
        _enrolledUnits = enrollments.map((e) => e['unit']).where((u) => u != null).toList();
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

  Future<void> _enrollInUnit(String unitId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _api.enrollStudent(studentId: uid, unitId: unitId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrolled successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enrolling: $e')),
        );
      }
    }
  }

  Future<void> _dropUnit(String unitId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await _api.dropEnrollment(studentId: uid, unitId: unitId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dropped successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error dropping: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Units'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
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
                  onEnroll: _enrollInUnit,
                  onDrop: _dropUnit,
                ),
                _MyUnitsTab(
                  units: _enrolledUnits,
                  onTabChange: () => _tab.animateTo(0),
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
  final Function(String) onEnroll;
  final Function(String) onDrop;

  const _AllUnitsTab({
    required this.units,
    required this.enrolledUnitIds,
    required this.onEnroll,
    required this.onDrop,
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
              'Enrol in units to access tasks, your group, and the group chat.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          );
        }
        final unit = units[i - 1];
        final enrolled = enrolledUnitIds.contains(unit['id']);
        return _UnitCard(
          unit: unit,
          enrolled: enrolled,
          onEnroll: onEnroll,
          onDrop: onDrop,
        );
      },
    );
  }
}

class _UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  final bool enrolled;
  final Function(String) onEnroll;
  final Function(String) onDrop;

  const _UnitCard({
    required this.unit,
    required this.enrolled,
    required this.onEnroll,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Left: colour dot
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
            // Middle: info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(unit['code'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
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
                        child: const Text('Enrolled',
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
                  Text('${unit['credits'] ?? 0} credits • Semester ${unit['semester'] ?? ''}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            // Right: button
            TextButton(
              onPressed: () =>
                  enrolled ? onDrop(unit['id']) : onEnroll(unit['id']),
              style: TextButton.styleFrom(
                backgroundColor: enrolled
                    ? Colors.red.withValues(alpha: 0.12)
                    : const Color(0xFF4A7BFF).withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              ),
              child: Text(
                enrolled ? 'Drop' : 'Enrol',
                style: TextStyle(
                  color: enrolled ? Colors.red : const Color(0xFF4A7BFF),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── My Units tab ──────────────────────────────────────────────────────────────

class _MyUnitsTab extends StatelessWidget {
  final List<dynamic> units;
  final VoidCallback onTabChange;

  const _MyUnitsTab({
    required this.units,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 56, color: Colors.white24),
            const SizedBox(height: 16),
            const Text("You haven't enrolled in any units yet.",
                style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onTabChange,
              child: const Text('Browse units',
                  style: TextStyle(color: Color(0xFF4A7BFF))),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: units.length,
      itemBuilder: (context, i) => _MyUnitCard(unit: units[i]),
    );
  }
}

class _MyUnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  const _MyUnitCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
