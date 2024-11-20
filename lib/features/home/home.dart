import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/benefits/benefits_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/credits/credits_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/notifications/notifications_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/qr/qr_code_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/user_reservations_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/menu/menu_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/admin_reservations_screen.dart';
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
    await authService.createUserDocument();
    bool isAdmin = await authService.isAdmin;
    setState(() {
      _isAdmin = isAdmin;
      _loading = false;
    });
  }

  final List<Widget> _userScreens = [
    const UserReservationsScreen(),
    const QrCodeScreen(),
    const NotificationsScreen(),
    const BenefitsScreen(),
    const MenuScreen(),
  ];

  final List<Widget> _adminScreens = [
    const AdminReservationsScreen(),
    const QrCodeScreen(),
    const NotificationsScreen(),
    const CreditsScreen(),
    const BenefitsScreen(),
    const MenuScreen(),
  ];

  final List<Widget> _userIcons = const <Widget>[
    Icon(Icons.home, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.qr_code, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.notifications,
        size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.wallet, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.menu, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
  ];

  final List<Widget> _adminIcons = const <Widget>[
    Icon(Icons.home, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.qr_code, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.notifications,
        size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.money,
        size: 30,
        color: Color.fromARGB(255, 255, 187, 0)), // Icono para Créditos
    Icon(Icons.wallet, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
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
        items: _isAdmin
            ? _adminIcons
            : _userIcons, // Seleccionamos la lista correcta de iconos
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        color: const Color.fromARGB(255, 54, 32, 68),
        backgroundColor: const Color.fromARGB(255, 221, 213, 213),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}
