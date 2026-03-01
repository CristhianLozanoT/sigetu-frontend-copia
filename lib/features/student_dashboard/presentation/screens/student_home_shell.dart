import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';
import 'turnos_screen.dart';
import 'perfil_screen.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class StudentHomeShell extends StatefulWidget {
  const StudentHomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<StudentHomeShell> createState() => _StudentHomeShellState();
}

class _StudentHomeShellState extends State<StudentHomeShell> {
  late int _currentIndex;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  void _onTap(int index) {
    if (_currentIndex == index) {
      // Si toca el mismo tab → vuelve al root
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // Solo cambia de tab
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNavigator(0, const StudentDashboardScreen()),
          _buildNavigator(1, const TurnosScreen()),
          _buildNavigator(2, const PerfilScreen()),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
