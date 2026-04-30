import 'package:flutter/material.dart';
import '../analytics.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';
import 'calendar_page.dart';
import 'tasks_page.dart';
import 'units_page.dart';
import 'profile_page.dart';
import 'lecturer_dashboard_page.dart';
import 'lecturer_tasks_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_users_page.dart';
import 'admin_units_page.dart';
import 'admin_notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> get _pages {
    final role = AuthService.instance.currentAppUser?.role;
    if (role == UserRole.admin) {
      return const [
        AdminDashboardPage(),
        AdminUsersPage(),
        AdminUnitsPage(),
        AdminNotificationsPage(),
      ];
    }
    if (role == UserRole.lecturer) {
      return const [
        LecturerDashboardPage(),
        LecturerTasksPage(),
        ProfilePage(),
      ];
    }
    return const [
      DashboardPage(),
      CalendarPage(),
      TasksPage(),
      UnitsPage(),
      AnalyticsPage(),
      ProfilePage(),
    ];
  }

  List<BottomNavigationBarItem> get _navItems {
    final role = AuthService.instance.currentAppUser?.role;
    if (role == UserRole.admin) {
      return const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users'),
        BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Units'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notify'),
      ];
    }
    if (role == UserRole.lecturer) {
      return const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile'),
      ];
    }
    return const [
      BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard'),
      BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Calendar'),
      BottomNavigationBarItem(
          icon: Icon(Icons.task_outlined),
          activeIcon: Icon(Icons.task),
          label: 'Tasks'),
      BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Units'),
      BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Analytics'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile'),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF0F0F0F),
        selectedItemColor: const Color(0xFF4A7BFF),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: _navItems,
      ),
    );
  }
}
