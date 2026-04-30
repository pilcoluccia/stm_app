import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'admin_users_page.dart';
import 'admin_units_page.dart';
import 'admin_notifications_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _api = ApiService();
  bool _loading = true;

  int _totalStudents = 0;
  int _totalLecturers = 0;
  int _totalAdmins = 0;
  int _totalUnits = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final users = await _api.listAllUsers();
      _totalStudents = users.where((u) => u['role'] == 'student').length;
      _totalLecturers = users.where((u) => u['role'] == 'lecturer').length;
      _totalAdmins = users.where((u) => u['role'] == 'admin').length;

      final units = await _api.listAllUnits();
      _totalUnits = units.length;

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Overview',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // ── Statistics Grid ────────────────────
                  Row(children: [
                    _StatCard(
                        label: 'Students',
                        value: '$_totalStudents',
                        icon: Icons.school,
                        color: const Color(0xFF4A7BFF)),
                    const SizedBox(width: 10),
                    _StatCard(
                        label: 'Lecturers',
                        value: '$_totalLecturers',
                        icon: Icons.person,
                        color: const Color(0xFF4CAF50)),
                    const SizedBox(width: 10),
                    _StatCard(
                        label: 'Admins',
                        value: '$_totalAdmins',
                        icon: Icons.admin_panel_settings,
                        color: const Color(0xFFFF9800)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _StatCard(
                        label: 'Units',
                        value: '$_totalUnits',
                        icon: Icons.book,
                        color: const Color(0xFF9C27B0)),
                    const SizedBox(width: 10),
                    Expanded(child: Container()), // Spacer
                    const SizedBox(width: 10),
                    Expanded(child: Container()), // Spacer
                  ]),
                  const SizedBox(height: 32),

                  // ── Quick Actions ──────────────────────
                  const Text('Quick Actions',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: 'Manage Users',
                    description: 'View and edit user accounts, roles',
                    icon: Icons.people,
                    color: const Color(0xFF4A7BFF),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminUsersPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: 'Manage Units',
                    description: 'Create, edit, and assign units',
                    icon: Icons.school,
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminUnitsPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: 'Send Notifications',
                    description: 'Broadcast institutional messages',
                    icon: Icons.notifications,
                    color: const Color(0xFFFF9800),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminNotificationsPage()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        ),
      );
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description,
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      );
}
