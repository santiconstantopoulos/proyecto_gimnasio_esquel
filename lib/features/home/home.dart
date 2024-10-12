import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/notifications/notifications_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/reservations_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/menu/menu_screen.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    AuthService authService = AuthService();
    bool isAdmin = await authService.isAdmin;
    setState(() {
      _isAdmin = isAdmin;
      _loading = false;
    });
  }

  // Pantallas para usuarios normales
  final List<Widget> _userScreens = [
    const ReservationsScreen(),
    const NotificationsScreen(),
    const Center(child: Text(AppStrings.beneficios)),
    const MenuScreen(),
  ];

  // Pantallas para administradores
  final List<Widget> _adminScreens = [
    const Center(child: Text('Admin Dashboard')),
    const NotificationsScreen(),
    const MenuScreen(),
  ];

  // Íconos para usuarios normales
  final List<Widget> _userIcons = const <Widget>[
    Icon(Icons.home, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.notifications,
        size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.shopping_bag, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.menu, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
  ];

  // Íconos para administradores
  final List<Widget> _adminIcons = const <Widget>[
    Icon(Icons.dashboard, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.notifications,
        size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.menu, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _isAdmin
          ? _adminScreens[_selectedIndex]
          : _userScreens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50,
        items: _isAdmin ? _adminIcons : _userIcons,
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
