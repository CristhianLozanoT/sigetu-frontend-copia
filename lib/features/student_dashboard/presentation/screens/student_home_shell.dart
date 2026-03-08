import 'package:flutter/material.dart';
import 'package:sigetu/core/utils/responsive.dart';
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
    final isWide = !Responsive.isMobile(context);
    final isExtended = Responsive.isWeb(context);

    final pages = IndexedStack(
      index: _currentIndex,
      children: [
        _buildNavigator(0, const StudentDashboardScreen()),
        _buildNavigator(1, const TurnosScreen()),
        _buildNavigator(2, const PerfilScreen()),
      ],
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTap,
              extended: isExtended,
              labelType: isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Inicio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Mis Turnos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Perfil'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: pages),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
