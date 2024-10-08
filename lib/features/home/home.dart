import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/notifications/notifications_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/reservations_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/menu/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ReservationsScreen(),
    const NotificationsScreen(),
    const Center(child: Text('Beneficios')),
    const MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
          Icon(Icons.notifications,
              size: 30, color: Color.fromARGB(255, 255, 187, 0)),
          Icon(Icons.shopping_bag,
              size: 30, color: Color.fromARGB(255, 255, 187, 0)),
          Icon(Icons.menu, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        color: const Color.fromARGB(255, 54, 32, 68),
        backgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}
