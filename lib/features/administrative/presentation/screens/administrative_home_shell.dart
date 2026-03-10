import 'package:flutter/material.dart';
import 'package:sigetu/core/utils/responsive.dart';
import 'package:sigetu/features/headquarters/domain/appointment_contexts.dart';
import 'package:sigetu/features/secretary/presentation/screens/secretary_screen.dart';
import 'package:sigetu/features/student_dashboard/presentation/screens/perfil_screen.dart';

class AdministrativeHomeShell extends StatefulWidget {
  const AdministrativeHomeShell({super.key});

  @override
  State<AdministrativeHomeShell> createState() => _AdministrativeHomeShellState();
}

class _AdministrativeHomeShellState extends State<AdministrativeHomeShell> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);
    final isExtended = Responsive.isWeb(context);

    final pages = IndexedStack(
      index: _currentIndex,
      children: [
        // Reutiliza el dashboard operativo de secretary, filtrando por sede.
        _buildNavigator(
          0,
          const SecretaryScreen(
            sede: AppointmentContexts.sedeAdministrativa,
            appBarTitle: 'Administrativo - Citas',
          ),
        ),
        _buildNavigator(1, const PerfilScreen()),
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
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Citas'),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTap,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Citas',
            tooltip: 'Lista de citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
            tooltip: 'Mi perfil',
          ),
        ],
      ),
    );
  }
}
