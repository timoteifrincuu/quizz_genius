import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'dashboard_screen.dart'; 
import 'profile_screen.dart'; // <--- NOU: Am importat ecranul de profil!

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Lista actualizată de pagini
  final List<Widget> _pagini = [
    const HomeScreen(),
    const DashboardScreen(), 
    const ProfileScreen(), // <--- NOU: Am pus noul nostru ecran aici!
  ];

  @override
  Widget build(BuildContext context) {
    // Verificăm tema ca să știm ce culoare punem la meniul din stânga
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // Meniul Lateral
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            // NOU: Culoarea meniului se adaptează acum automat la Dark Mode!
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
            selectedIconTheme: const IconThemeData(color: Colors.deepPurple),
            selectedLabelTextStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.add_box_outlined),
                selectedIcon: Icon(Icons.add_box),
                label: Text('Generează'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Istoric Note'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profil Cont'),
              ),
            ],
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          Expanded(
            child: _pagini[_selectedIndex],
          ),
        ],
      ),
    );
  }
}