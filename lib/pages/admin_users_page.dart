import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _api = ApiService();
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  bool _loading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await _api.listAllUsers();
      setState(() {
        _allUsers = users;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _applyFilter() {
    switch (_selectedFilter) {
      case 'students':
        _filteredUsers = _allUsers.where((u) => u['role'] == 'student').toList();
        break;
      case 'lecturers':
        _filteredUsers = _allUsers.where((u) => u['role'] == 'lecturer').toList();
        break;
      case 'admins':
        _filteredUsers = _allUsers.where((u) => u['role'] == 'admin').toList();
        break;
      default:
        _filteredUsers = _allUsers;
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  void _showEditRoleDialog(dynamic user) {
    String newRole = user['role'];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text('Edit Role: ${user['name']}',
              style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user['email'],
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: newRole,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'lecturer', child: Text('Lecturer')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (val) => setDialogState(() => newRole = val!),
              ),
            ],
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
              onPressed: () => _updateUserRole(context, user['uid'], newRole),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserRole(
      BuildContext dialogContext, String uid, String newRole) async {
    try {
      await _api.updateUserRole(uid: uid, role: newRole);
      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully!')),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User Management',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'View and manage all users in the system',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 24),

                  // ── Filter Tabs ────────────────────────
                  Row(
                    children: [
                      _FilterChip(
                          label: 'All Users',
                          isSelected: _selectedFilter == 'all',
                          onTap: () => _changeFilter('all')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Students',
                          isSelected: _selectedFilter == 'students',
                          onTap: () => _changeFilter('students')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Lecturers',
                          isSelected: _selectedFilter == 'lecturers',
                          onTap: () => _changeFilter('lecturers')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Admins',
                          isSelected: _selectedFilter == 'admins',
                          onTap: () => _changeFilter('admins')),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── User Count ─────────────────────────
                  Text(
                      '${_filteredUsers.length} ${_selectedFilter == 'all' ? 'users' : _selectedFilter}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 12),

                  // ── User List ──────────────────────────
                  if (_filteredUsers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.white30),
                            SizedBox(height: 16),
                            Text('No users found',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._filteredUsers.map((user) {
                      Color roleColor;
                      IconData roleIcon;
                      switch (user['role']) {
                        case 'admin':
                          roleColor = const Color(0xFFFF9800);
                          roleIcon = Icons.admin_panel_settings;
                          break;
                        case 'lecturer':
                          roleColor = const Color(0xFF4CAF50);
                          roleIcon = Icons.person;
                          break;
                        default:
                          roleColor = const Color(0xFF4A7BFF);
                          roleIcon = Icons.school;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  roleColor.withValues(alpha: 0.2),
                              child: Icon(roleIcon,
                                  color: roleColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(user['name'],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(user['email'],
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: roleColor
                                          .withValues(alpha: 0.2),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      (user['role'] as String).toUpperCase(),
                                      style: TextStyle(
                                          color: roleColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF4A7BFF)),
                              onPressed: () => _showEditRoleDialog(user),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4A7BFF)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: Colors.white12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
}
